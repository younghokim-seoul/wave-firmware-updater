import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';

part 'connection_state.freezed.dart';

@freezed
class ConnectionUiState with _$ConnectionUiState {
  const factory ConnectionUiState({
    required List<ScanUiModel> scanDevices,
  }) = _ConnectionUiState;
}


@freezed
class ScanUiModel with _$ScanUiModel {
  const factory ScanUiModel({
    required ConnectionMode connectionMode,
    required ScanDevice model,
    required bool isExpanded,
    required ConnectionStatus status,
  }) = _ScanUiModel;
}
