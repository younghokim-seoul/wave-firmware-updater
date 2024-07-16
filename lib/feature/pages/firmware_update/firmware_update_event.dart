import 'package:equatable/equatable.dart';
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';

sealed class FirmwareUpdateEvent extends Equatable {
  const FirmwareUpdateEvent();

  @override
  List<Object?> get props => [];
}

class FirmwareAlreadyLatestVersion extends FirmwareUpdateEvent {
  const FirmwareAlreadyLatestVersion({required this.currentVersion});

  final String currentVersion;

  @override
  List<Object?> get props => [currentVersion];
}

class DeviceNotConnected extends FirmwareUpdateEvent {
  const DeviceNotConnected();

  @override
  List<Object?> get props => [];
}

class FirmwareVersionInfoRequested extends FirmwareUpdateEvent {
  const FirmwareVersionInfoRequested();

  @override
  List<Object?> get props => [];
}

class FirmwareVersionInfoReceived extends FirmwareUpdateEvent {
  final FirmwareVersion data;
  final String currentVersion;

  const FirmwareVersionInfoReceived({
    required this.data,
    required this.currentVersion
  });

  @override
  List<Object?> get props => [data,currentVersion];
}

class FirmwareDownloadProgress extends FirmwareUpdateEvent {
  final double? downloadProgress;

  const FirmwareDownloadProgress({
    required this.downloadProgress,
  });

  @override
  List<Object?> get props => [downloadProgress];
}

class FirmwareDownloadComplete extends FirmwareUpdateEvent {
  const FirmwareDownloadComplete();

  @override
  List<Object?> get props => [];
}

class FirmwareErrorNotify extends FirmwareUpdateEvent {
  final FirmwareError error;
  final ErrorCode code;

  const FirmwareErrorNotify({required this.error,required this.code});

  @override
  List<Object?> get props => [error];
}
