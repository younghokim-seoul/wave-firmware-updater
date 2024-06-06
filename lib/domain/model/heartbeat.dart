import 'package:freezed_annotation/freezed_annotation.dart';

part 'heartbeat.freezed.dart';

@freezed
class Heartbeat with _$Heartbeat {
  const factory Heartbeat({
    required String timeStamp,
    required String batteryStatus,
    required String sleepStatus,
    required String temperature,
    required String pitchReal,
    required String doorMode,
    required String rollReal,
    required String rollSticky,
    required String rfStatus,
    required String putStatus,
  }) = _Heartbeat;
}