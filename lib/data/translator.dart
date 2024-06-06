import 'package:control_protocol/control_protocol.dart';
import 'package:wave_desktop_installer/domain/model/heartbeat.dart';

extension WaveHeartInfoResponseTranslator on WaveSensorHeartBeatResponse {
  Heartbeat toDomain() {
    return Heartbeat(
        timeStamp: timeStamp,
        batteryStatus: batteryStatus,
        sleepStatus: sleepStatus,
        temperature: temperature,
        pitchReal: pitchReal,
        doorMode: doorMode,
        rollReal: rollReal,
        rollSticky: rollSticky,
        rfStatus: rfStatus,
        putStatus: putStatus);
  }
}



