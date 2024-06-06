import 'package:control_protocol/control_protocol.dart';

class ResponseParseException implements Exception {
  const ResponseParseException(this.cause, this.stackTrace);

  final dynamic cause;

  final StackTrace stackTrace;
}

WaveSensorResponse parseResponse(String data) {
  try {
    if (isValidPacket(data)) {
      String content = data.substring(stx.length, data.indexOf(tail)).replaceAll(', ', ',');
      final values = content.split(' ').skip(1).toList();

      if (content.startsWith(heartBeatPrefix)) {
        final heartBeatInfo = values[0].split(',');

        return WaveSensorHeartBeatResponse(
          timeStamp: heartBeatInfo[0],
          batteryStatus: heartBeatInfo[1],
          sleepStatus: heartBeatInfo[2],
          temperature: heartBeatInfo[3],
          pitchReal: heartBeatInfo[4],
          doorMode: heartBeatInfo[5],
          rollReal: heartBeatInfo[6],
          rollSticky: heartBeatInfo[7],
          rfStatus: heartBeatInfo[8],
          putStatus: heartBeatInfo[9],
        );
      }
    }
    return WaveSensorUnknownResponse(data: data);
  } catch (e, t) {
    print('Error parsing response: $e');
    throw ResponseParseException(e, t);
  }
}

bool isValidPacket(String packet) {
  return packet.startsWith(stx) && packet.endsWith(etx);
}
