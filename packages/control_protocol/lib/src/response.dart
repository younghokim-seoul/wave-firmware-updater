import 'package:equatable/equatable.dart';

sealed class WaveSensorResponse extends Equatable {
  const WaveSensorResponse();

  @override
  List<Object?> get props;
}

class WaveSensorHeartBeatResponse extends WaveSensorResponse {
  const WaveSensorHeartBeatResponse({
    required this.timeStamp,
    required this.batteryStatus,
    required this.sleepStatus,
    required this.temperature,
    required this.pitchReal,
    required this.doorMode,
    required this.rollReal,
    required this.rollSticky,
    required this.rfStatus,
    required this.putStatus,
  });

  final String timeStamp;
  final String batteryStatus;
  final String sleepStatus;
  final String temperature;
  final String pitchReal;
  final String doorMode;
  final String rollReal;
  final String rollSticky;
  final String rfStatus;
  final String putStatus;

  @override
  List<Object?> get props => [
        timeStamp,
        batteryStatus,
        sleepStatus,
        temperature,
        pitchReal,
        doorMode,
        rollReal,
        rollSticky,
        rfStatus,
        putStatus,
      ];
}

class FirmwareVersionResponse extends WaveSensorResponse {
  const FirmwareVersionResponse({
    required this.verCode,
  });

  final String verCode;

  @override
  List<Object?> get props => [verCode];
}

class FirmwareDownloadModeResponse extends WaveSensorResponse {
  const FirmwareDownloadModeResponse({
    required this.status,
  });

  final bool status;

  @override
  List<Object?> get props => [status];
}

class FirmwareDownloadingResponse extends WaveSensorResponse {
  const FirmwareDownloadingResponse({
    required this.status,
    required this.pageNum,
  });

  final bool status;
  final int pageNum;

  @override
  List<Object?> get props => [status, pageNum];
}


class WaveSensorUnknownResponse extends WaveSensorResponse {
  const WaveSensorUnknownResponse({
    required this.data,
  });

  final String data;

  @override
  List<Object?> get props => [data];
}
