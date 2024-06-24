import 'package:equatable/equatable.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';

sealed class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class DeviceNotConnected extends SettingEvent {
  const DeviceNotConnected();

  @override
  List<Object?> get props => [];
}

class DeviceConnected extends SettingEvent {
  const DeviceConnected();

  @override
  List<Object?> get props => [];
}
