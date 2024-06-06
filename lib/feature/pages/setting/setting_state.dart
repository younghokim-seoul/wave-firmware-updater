import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/domain/model/heartbeat.dart';

part 'setting_state.freezed.dart';

@freezed
class SettingUiState with _$SettingUiState {
  const factory SettingUiState({
    required Heartbeat heartbeat,
  }) = _SettingUiState;
}

extension SettingUiStateX on SettingUiState {
  bool get isTiltAngle {
    int pitchReal = int.parse(heartbeat.pitchReal);
    return pitchReal >= 8 && pitchReal <= 12;
  }

  bool get isRollAngle {
    int rollReal = int.parse(heartbeat.rollReal);
    return rollReal >= -2 && rollReal <= 2;
  }
}
