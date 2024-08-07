import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:modbus_client/modbus_client.dart';
import 'package:tcp_client/src/tcp_notifier.dart';

class TcpClientException implements Exception {
  const TcpClientException(this.cause, this.stackTrace);

  final dynamic cause;
  final StackTrace stackTrace;
}

class TcpClientRepository extends ModbusClient {
  final String serverAddress;
  final int serverPort;
  final Duration connectionTimeout;
  final Duration writeTimeout;
  final Duration? delayAfterConnect;
  final _requestQueue = Queue<Future<void> Function()>();
  bool _isProcessingQueue = false;
  Completer<WaveSensorResponse> _responseCompleter = Completer();
  SocketNotifier? socketNotifier = SocketNotifier();

  @override
  bool get isConnected => _socket != null;

  int _lastTransactionId = 0;

  int _getNextTransactionId() {
    _lastTransactionId++;
    if (_lastTransactionId > 65535) {
      _lastTransactionId = 0;
    }
    return _lastTransactionId;
  }

  Socket? _socket;

  bool get isClosed => _socket == null;

  TcpClientRepository(this.serverAddress,
      {this.serverPort = 4999,
      super.connectionMode = ModbusConnectionMode.autoConnectAndKeepConnected,
      this.connectionTimeout = const Duration(seconds: 3),
      this.writeTimeout = const Duration(seconds: 3),
      super.responseTimeout = const Duration(seconds: 3),
      this.delayAfterConnect,
      super.unitId});

  static Future<String?> discover(String startIpAddress,
      {int serverPort = 4999, Duration connectionTimeout = const Duration(milliseconds: 10)}) async {
    var serverAddress = InternetAddress.tryParse(startIpAddress);

    if (serverAddress == null) {
      throw ModbusException(context: "ModbusClientTcp.discover", msg: "[$startIpAddress] Invalid address!");
    }
    for (var i = serverAddress.rawAddress[3]; i < 256; i++) {
      var ip = serverAddress!.rawAddress;
      ip[3] = i;
      serverAddress = InternetAddress.fromRawAddress(ip);
      try {
        var socket = await Socket.connect(serverAddress, serverPort, timeout: connectionTimeout);
        socket.destroy();
        ModbusAppLogger.info("[${serverAddress.address}] Modbus server found!");
        return serverAddress.address;
      } catch (_) {}
    }
    ModbusAppLogger.info("[$startIpAddress] Modbus server not found!");
    return null;
  }

  @override
  Future<ModbusResponseCode> send(ModbusRequest request) async {
    return Future.error("Not implemented");
  }

  /// Connect the socket if not already done or disconnected
  @override
  Future<bool> connect({int attempts = 3}) async {
    if (isConnected) {
      return true;
    }
    print('Connecting TCP socket...$serverAddress:$serverPort');
    // New connection
    try {
      _socket = await Socket.connect(serverAddress, serverPort, timeout: connectionTimeout);
      // listen to the received data event stream
      _socket!.listen((Uint8List datagram) {
        List<List<int>> packets = datagram.extractPackets([36, 36], [35, 35], packetMaxLength);
        for (var packet in packets) {
          final data = utf8.decode(packet);
          _onSocketData(data);
        }
      }, onError: (error) {
        print("::::onerror.. " + error.toString());
        socketNotifier!.notifyClose(Close('Connection closed', 1));
        _onSocketError(error);
      }, onDone: () {
        print("::::onDone.. ");
        disconnect();
        socketNotifier!.notifyClose(Close('Connection closed', 1));
      }, cancelOnError: true);
    } catch (ex) {
      print("[error] Connection to $serverAddress:$serverPort");
      _socket = null;
      return false;
    }
    // Is a delay requested?
    if (delayAfterConnect != null) {
      await Future.delayed(delayAfterConnect!);
    }
    print("TCP socket connected");
    return true;
  }

  /// Handle received data from the socket
  void _onSocketData(String data) {
    try {
      // final data = utf8.decode(datagram);
      _responseCompleter.complete(parseResponse(data));
    } on ResponseParseException catch (e) {
      _responseCompleter.completeError(e);
    } catch (e, t) {
      _responseCompleter.completeError(TcpClientException(e, t));
    }
    _responseCompleter = Completer();
  }

  /// Handle an error from the socket
  void _onSocketError(dynamic error) {
    print("Unexpected error from TCP socket$error");
    disconnect();
  }

  /// Handle socket being closed
  @override
  Future<void> disconnect() async {
    print("Disconnecting TCP socket... ");
    if (_socket != null) {
      _socket!.destroy();
      _socket = null;
    }
  }

  Future<WaveSensorResponse> rawPacket(Uint8List event, {bool isAutoConnect = false, Duration? timeout}) async {
    final completer = Completer<WaveSensorResponse>();

    _requestQueue.add(() async {
      // Connect if needed
      try {
        if (connectionMode != ModbusConnectionMode.doNotConnect) {
          await connect();
        }
        if (!isConnected) {
          throw TcpClientException('Message was not sent', StackTrace.current);
        }

        // Flushes any old pending data
        await _socket!.flush();
        _socket!.add(event);

        // Create the new response handler
        var transactionId = _getNextTransactionId();

        String timestamp = '[${DateTime.now().toString()}] ';
        print("$timestamp transactionId $transactionId | ${utf8.decode(event)}");

        final response = await _responseCompleter.future.timeout(timeout ?? writeTimeout);
        completer.complete(response);
      } on ResponseParseException catch (e) {
        completer.completeError(e);
      } catch (e, t) {
        print("rawPacket error : $e");
        completer.completeError(TcpClientException('Unexpected exception in sending TCP message{$e}', t));
      }
    });

    if (!_isProcessingQueue) {
      unawaited(_processQueue());
    }

    return completer.future;
  }

  Future<void> _processQueue() async {
    _isProcessingQueue = true;

    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      await request();
    }

    _isProcessingQueue = false;
  }

  void onClose(CloseSocket fn) {
    socketNotifier!.addCloses(fn);
  }
}
