import 'package:equatable/equatable.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';

sealed class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

class NearByDeviceNotFound extends ConnectionEvent {
  const NearByDeviceNotFound();
}

class NearByDevicesHelp extends ConnectionEvent {
  const NearByDevicesHelp();
}

class NearByDevicesRequested extends ConnectionEvent {
  const NearByDevicesRequested();
}

class NearByDevicesUpdate extends ConnectionEvent {
  final ConnectionUiState data;

  const NearByDevicesUpdate({
    required this.data,
  });

  @override
  List<Object?> get props => [data];
}
