import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';

part 'connection_state.freezed.dart';

@freezed
class ConnectionUiState with _$ConnectionUiState {
  const factory ConnectionUiState({
    required List<ScanDevice> scanDevices,
  }) = _ConnectionUiState;
}
