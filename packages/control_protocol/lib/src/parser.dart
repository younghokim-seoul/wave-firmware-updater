import 'package:control_protocol/control_protocol.dart';

class ResponseParseException implements Exception {
  const ResponseParseException(this.cause, this.stackTrace);

  final dynamic cause;

  final StackTrace stackTrace;
}

WaveSensorResponse parseResponse(String data) {
  try {

    print("parseResponse... " + data);
    if (data.isValidPacket()) {
      String content = data.substring(stx.length, data.indexOf(tail)).replaceAll(', ', ',');
      final values = content.split(' ').skip(1).toList();

      print("content... " + content);
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

      if (content.startsWith('SET')) {
        final status = data.status();
        return FirmwareDownloadModeResponse(status: status == 'OK');
      }

      if (content.startsWith('FWD')) {
        final response = data.downloadData().split(',');

        if (response.length < 3) {
           //파일다운로드 완료후.. 파일 유효성 체크할 차례 이과정에서 통과하면 마무리
        } else{
          final status = response[1];
          final pageNum = int.parse(response[2]);

          //만약 3번 패킷이 NG 발생했어...
          //그럼 다시 3번을 보내야하잖아..
          return FirmwareDownloadingResponse(status: status == 'OK', pageNum: pageNum);
        }

      }
    }
    return WaveSensorUnknownResponse(data: data);
  } catch (e, t) {
    print('Error parsing response: $e');
    throw ResponseParseException(e, t);
  }
}

extension PacketExtension on String {
  bool isValidPacket() {
    return startsWith(stx);
  }

  String status() {
    int startIndex = indexOf(',') + 1;
    int endIndex = indexOf('%');

    if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
      print("substring(startIndex, endIndex) " + substring(startIndex, endIndex));
      return substring(startIndex, endIndex);
    } else {
      return '';
    }
  }

  String downloadData() {
    int startIndex = indexOf('\$\$') + 2;
    int endIndex = indexOf('%');

    if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
      return substring(startIndex, endIndex);
    } else {
      return '';
    }
  }
}
