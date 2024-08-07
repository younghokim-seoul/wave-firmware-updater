import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/domain/model/heartbeat.dart';

part 'camera_state.freezed.dart';

@freezed
class CameraUiState with _$CameraUiState {
  const factory CameraUiState({
    required Heartbeat heartbeat,
  }) = _CameraUiState;
}

extension CameraUiStateX on CameraUiState {
  bool get isTiltAngle {
    int pitchReal = int.parse(heartbeat.pitchReal);
    return pitchReal >= 8 && pitchReal <= 12;
  }

  bool get isRollAngle {
    int rollReal = int.parse(heartbeat.rollReal);
    return rollReal >= -2 && rollReal <= 2;
  }
}
