import 'package:equatable/equatable.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraNotConnected extends CameraEvent {
  const CameraNotConnected();

  @override
  List<Object?> get props => [];
}

class CameraConnected extends CameraEvent {
  const CameraConnected();

  @override
  List<Object?> get props => [];
}
