
import 'dart:typed_data';

const packetMaxLength = 40; //

class SocketNotifier {
  void Function(Close)? _onCloses;

  void addCloses(CloseSocket socket) {
    _onCloses = socket;
  }

  void notifyClose(Close err) {
    _onCloses?.call(err);
  }

  void dispose() {
    _onCloses = null;
  }
}

typedef OpenSocket = void Function();

typedef CloseSocket = void Function(Close);

class Close {
  final String message;
  final int reason;

  Close(this.message, this.reason);
}


extension PacketExtraction on Uint8List {
  List<List<int>> extractPackets(List<int> stx, List<int> etx, int packetSize) {
    List<List<int>> packets = [];
    int i = 0;

    while (i <= length - packetSize) {
      // Check for the start sequence and end sequence with correct packet size
      if (this[i] == stx[0] && this[i + 1] == stx[1] &&
          this[i + packetSize - 2] == etx[0] && this[i + packetSize - 1] == etx[1]) {
        packets.add(sublist(i, i + packetSize));
        i += packetSize; // Move to the next possible packet
      } else {
        i++;
      }
    }

    return packets;
  }
}