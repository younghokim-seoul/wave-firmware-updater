import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_listener.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/patch_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_event.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class FirmwareUpdateViewModel {
  FirmwareUpdateViewModel(
    this._wifiRepository,
    this._bleRepository,
    this._patchRepository,
    this._fwupdService,
  );

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bleRepository;
  final PatchRepository _patchRepository;
  final FwupdService _fwupdService;

  final firmwareUiEvent = ArcSubject<FirmwareUpdateEvent>();
  final percentage = ArcSubject<double>(seed: 0.0);
  StreamSubscription? _statusesSubscription;

  Future<void> subscribeToStatuses() async {
    Log.i(":::::: subscribeToMessages");
    _statusesSubscription ??= _wifiRepository.statuses.listen(
      (state) {
        Log.i('::::: subscribeToMessages $state');
      },
      onDone: () {
        Log.i('::::: subscribeToMessages onDone');
      },
    );
  }
  Future<void> _unsubscribeFromStatuses() async {
    Log.i(":::::: _unsubscribeFromStatuses");
    await _statusesSubscription?.cancel();
    _statusesSubscription = null;
  }

  rememberLatestState(ConnectionMode mode) {
    bool isClosed = _wifiRepository.isClosed;

    if (isClosed) {
      Log.i("not connected Device");
      firmwareUiEvent.val = const DeviceNotConnected();
      return;
    }


    Log.i("addFirmWareChannelListener");
    _fwupdService.addFirmWareChannelListener(
      FirmWareChannelListener(
        onPercentageChanged: (progress) {
          Log.d('[ViewModel Receive] onPercentageChanged $progress');
          percentage.val = progress;
        },
        onDownloadStateChanged: (status) {
          Log.d('onStatusChanged $status');
        },
      ),
    );
  }

  void checkFirmwareVersion(ConnectionMode mode) async {
    Log.i('[checkFirmwareVersion]' + _fwupdService.status.toString() + " | " + _wifiRepository.isClosed.toString());

    rememberLatestState(mode);

    if (_fwupdService.status != FwupdStatus.idle || _wifiRepository.isClosed) {
      Log.i('checkFirmwareVersion status is not idle or not connected Device');
      return;
    }
    try {
      firmwareUiEvent.val = const FirmwareVersionInfoRequested();
      final response = await _patchRepository.fetchPatchDetails();
      Log.i('[checkFirmwareUpdate] response $response');

      //todo : 최신 버전 체크 과 다운로드 분기처리 필요
      firmwareUiEvent.val = FirmwareVersionInfoReceived(data: response);
    } catch (e) {
      Log.e('[checkFirmwareUpdate] error: $e');
      firmwareUiEvent.val = const FirmwareVersionInfoReceived(data: null);
    }
  }

  void installFirmware() async {
    //todo : 블루투스와  WIFI 분기처리 필요..
    if (firmwareUiEvent.val is FirmwareVersionInfoReceived) {
      try {
        final firmwareVersion = (firmwareUiEvent.val as FirmwareVersionInfoReceived).data;

        if (!firmwareVersion.isNullOrEmpty) {
          firmwareUiEvent.val = const FirmwareDownloadProgress(downloadProgress: null);
          await _fwupdService.install(firmwareVersion!);
          await _wifiRepository.send(RebootDataRequest().getRawBytes(), isAutoConnect: true);
          firmwareUiEvent.val = const FirmwareDownloadComplete();
        }
      } catch (e) {
        Log.e("[installFirmware] error... $e");
        firmwareUiEvent.val = const FirmwareErrorNotify(error: FirmwareError.firmwareDownloadFail);
      }
    }
  }

  void dispose() {
    firmwareUiEvent.close();
    percentage.close();
    _unsubscribeFromStatuses();
  }
}
