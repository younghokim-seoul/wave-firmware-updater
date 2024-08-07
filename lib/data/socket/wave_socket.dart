

import 'dart:collection';
import 'dart:io';

import 'package:wave_desktop_installer/data/socket/socket.dart';
import 'package:wave_desktop_installer/data/socket/wave_socket_impl.dart';




abstract class WaveSocket {
  factory WaveSocket.fromRaw(
      Socket ws,
      Map<String, HashSet<WaveSocket>> rooms,
      HashSet<WaveSocket> sockets,
      ) {
    return WaveSocketImpl(ws, rooms, sockets);
  }
  Map<String?, HashSet<WaveSocket>> get rooms;
  HashSet<WaveSocket> get sockets;
  void send(dynamic message);

  void add(dynamic rawPacket,int id);

  void emit(String event, Object data);

  void close([int? status, String? reason]);

  bool join(String? room);

  bool leave(String room);

  dynamic operator [](String key);

  void operator []=(String key, dynamic value);

  Socket get rawSocket;

  int get id;

  int get length;

  WaveSocket? getSocketById(int id);

  void broadcast(Object message);

  void broadcastEvent(String event, Object data);

  void sendToAll(Object message);

  void emitToAll(String event, Object data);

  void sendToRoom(String? room, Object message);

  void emitToRoom(String event, String? room, Object message);

  void broadcastToRoom(String room, Object message);

  void onOpen(OpenSocket fn);

  void onClose(CloseSocket fn);

  void onError(CloseSocket fn);

  void onMessage(MessageSocket fn);

  void on(String event, MessageSocket message);

}
