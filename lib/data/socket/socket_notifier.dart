part of socket;

class SocketNotifier {
  List<void Function(dynamic,int)>? _onMessages = <MessageSocket>[];
  Map<String, void Function(dynamic,int)>? _onEvents = <String, MessageSocket>{};
  List<void Function(Close)>? _onCloses = <CloseSocket>[];
  List<void Function(Close)>? _onErrors = <CloseSocket>[];

  void addMessages(MessageSocket socket) {
    _onMessages!.add(socket);
  }

  void addEvents(String event, MessageSocket socket) {
    _onEvents![event] = socket;
  }

  void addCloses(CloseSocket socket) {
    _onCloses!.add(socket);
  }

  void addErrors(CloseSocket socket) {
    _onErrors!.add(socket);
  }

  void notifyData(dynamic data,WaveSocket newWs) {

    final socketId = newWs.id;

    for (var item in _onMessages!) {
      item(data,socketId);
    }
    // _tryOn(data,socketId);
  }

  void notifyClose(Close err, WaveSocket newWs) {
    Log.d('Socket ${newWs.id} is been disposed');

    for (var item in _onCloses!) {
      item(err);
    }
  }

  void notifyError(Close err) {
    // rooms.removeWhere((key, value) => value.contains(_ws));
    for (var item in _onErrors!) {
      item(err);
    }
  }

  void _tryOn(dynamic message,int id) {
    try {
      String jsonData = String.fromCharCodes(message);
      Map<String, dynamic> msg = jsonDecode(jsonData);
      final event = msg['type'];
      final data = jsonData;
      if (_onEvents!.containsKey(event)) {
        _onEvents![event]!(data,id);
      }
    } catch (e) {
      Log.d(":::::::::::try on Error $e");
      return;
    }
  }

  void dispose() {
    _onMessages = null;
    _onEvents = null;
    _onCloses = null;
    _onErrors = null;
  }
}

typedef OpenSocket = void Function(WaveSocket socket);

typedef CloseSocket = void Function(Close);

typedef MessageSocket = void Function(dynamic val,int id);


class Close {
  final WaveSocket socket;
  final String message;
  final int reason;

  Close(this.socket, this.message, this.reason);
}
