import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@lazySingleton
class MainViewModel {
  MainViewModel(this._wifiRepository, this._bluetoothRepository);

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bluetoothRepository;

  StreamSubscription<WaveSensorResponse>? _subscription;

  final navigateUiEvent = ArcSubject<MainViewEvent>();

  Future<void> subscribeToMessages() async {
    _subscription ??= _wifiRepository.responseMessage.listen((response) {
      if (response is WaveSensorHeartBeatResponse) {}
    });
  }

  void dispose() {
    navigateUiEvent.close();
    _subscription?.cancel();
    _subscription = null;
  }

  void navigateToConnectionPage() {
    navigateUiEvent.val = const MoveToConnectionPageEvent();
  }
}

sealed class MainViewEvent extends Equatable {
  const MainViewEvent();

  @override
  List<Object?> get props => [];
}

class MoveToConnectionPageEvent extends MainViewEvent {
  const MoveToConnectionPageEvent();

  @override
  List<Object?> get props => [];
}
