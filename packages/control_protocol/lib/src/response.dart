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

class WaveSensorUnknownResponse extends WaveSensorResponse {
  const WaveSensorUnknownResponse({
    required this.data,
  });

  final String data;

  @override
  List<Object?> get props => [data];
}
