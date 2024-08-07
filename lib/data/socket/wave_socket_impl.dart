import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:wave_desktop_installer/data/socket/socket.dart';
import 'package:wave_desktop_installer/data/socket/wave_socket.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';



class WaveSocketImpl implements WaveSocket {
  final Socket _ws;

  late StreamSubscription _subs;

  SocketNotifier? socketNotifier = SocketNotifier();

  bool isDisposed = false;

  @override
  final Map<String?, HashSet<WaveSocket>> rooms;

  @override
  final HashSet<WaveSocket> sockets;



  WaveSocketImpl(this._ws, this.rooms, this.sockets) {
    sockets.add(this);
    _subs = _ws.listen((data) {
      socketNotifier!.notifyData(data,this);
    }, onError: (err) {
      socketNotifier!.notifyError(Close(this, err.toString(), 0));
      close();
    }, onDone: () {
      sockets.remove(this);
      rooms.removeWhere((key, value) => value.contains(this));
      socketNotifier!.notifyClose(Close(this, 'Connection closed', 1), this);
      socketNotifier!.dispose();
      socketNotifier = null;
      isDisposed = true;
    });
  }





  @override
  void send(dynamic message) {
    _checkAvailable();
    _ws.writeln(message);
  }

  final _value = <String, dynamic>{};

  @override
  dynamic operator [](String key) {
    return _value[key];
  }

  @override
  void operator []=(String key, dynamic value) {
    _value[key] = value;
  }

  @override
  Socket get rawSocket => _ws;

  @override
  int get id => _ws.hashCode;

  @override
  int get length => sockets.length;

  @override
  WaveSocket? getSocketById(int id) {
    return sockets.firstWhereOrNull((element) => element.id == id);
  }

  @override
  void broadcast(Object message) {
    if (sockets.contains(this)) {
      for (var element in sockets) {
        if (element != this) {
          element.send(message);
        }
      }
    }
  }

  @override
  void broadcastEvent(String event, Object data) {
    if (sockets.contains(this)) {
      for (var element in sockets) {
        if (element != this) {
          element.emit(event, data);
        }
      }
    }
  }

  @override
  void sendToAll(Object message) {
    if (sockets.contains(this)) {
      for (var element in sockets) {
        element.send(message);
      }
    }
  }

  @override
  void emitToAll(String event, Object data) {
    if (sockets.contains(this)) {
      for (var element in sockets) {
        element.emit(event, data);
      }
    }
  }

  @override
  void sendToRoom(String? room, Object message) {
    _checkAvailable();
    if (rooms.containsKey(room) && rooms[room]!.contains(this)) {
      for (var element in rooms[room]!) {
        element.send(message);
      }
    }
  }

  @override
  void emitToRoom(String event, String? room, Object message) {
    _checkAvailable();
    if (rooms.containsKey(room) && rooms[room]!.contains(this)) {
      for (var element in rooms[room]!) {
        element.emit(event, message);
      }
    }
  }

  void _checkAvailable() {
    if (isDisposed) throw 'Cannot add events to closed Socket';
  }

  @override
  void broadcastToRoom(String room, Object message) {
    _checkAvailable();

    if (rooms.containsKey(room) && rooms[room]!.contains(this)) {
      for (var element in rooms[room]!) {
        if (element != this) {
          element.send(message);
        }
      }
    }
  }

  @override
  void emit(String event, Object data) {
    send(jsonEncode({'type': event, 'data': data}));
  }

  @override
  bool join(String? room) {
    _checkAvailable();
    if (rooms.containsKey(room)) {
      return rooms[room]!.add(this);
    } else {
      Log.d("Room [$room] don't exists, creating it");
      rooms[room] = HashSet();
      return rooms[room]!.add(this);
    }
  }

  @override
  bool leave(String room) {
    _checkAvailable();
    if (rooms.containsKey(room)) {
      return rooms[room]!.remove(this);
    } else {
      Log.d("Room $room don't exists");
      return false;
    }
  }

  @override
  void onOpen(OpenSocket fn) {
    fn(this);
  }

  @override
  void onClose(CloseSocket fn) {
    socketNotifier!.addCloses(fn);
  }

  @override
  void onError(CloseSocket fn) {
    socketNotifier!.addErrors(fn);
  }

  @override
  void onMessage(MessageSocket fn) {
    socketNotifier!.addMessages(fn);
  }

  @override
  void on(String event, MessageSocket message) {
    socketNotifier!.addEvents(event, message);
  }

  @override
  void close([int? status, String? reason]) async {
    await _ws.close();
    await _subs.cancel();
  }

  @override
  void add(dynamic rawPacket,int id) {
    // _ws.add(rawPacket);

   final hasSocket =  sockets.where((item) => item.id == id).firstOrNull;

   if(hasSocket != null){
     hasSocket.rawSocket.add(rawPacket);
   }

    // if (sockets.contains(this)) {
    //   for (var element in sockets) {
    //     element.rawSocket.add(rawPacket);
    //   }
    // }
  }


}
