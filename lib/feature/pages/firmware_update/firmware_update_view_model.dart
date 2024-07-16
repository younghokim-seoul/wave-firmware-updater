import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_listener.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';
import 'package:wave_desktop_installer/data/network/token/token_manager.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/patch_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_event.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

import '../../../data/connection_status.dart';

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

  ConnectionMode connectionMode = ConnectionMode.wifi;

  bool get isClosed => connectionMode == ConnectionMode.wifi ? _wifiRepository.isClosed : _bleRepository.isClosed;

  final firmwareUiEvent = ArcSubject<FirmwareUpdateEvent>();
  final percentage = ArcSubject<double>(seed: 0.0);
  StreamSubscription? _statusesSubscription;


  FirmwareVersion? _firmwareVersion;

  void setConnectionMode(ConnectionMode mode) {
    connectionMode = mode;
  }

  Future<void> subscribeToStatuses() async {
    _statusesSubscription ??= _wifiRepository.statuses.listen(
      (state) {
        Log.i('::::: wifi 연결상태 콜백 $state ${_fwupdService.status}');
        if (state.item2 == ConnectionStatus.disconnected && _fwupdService.status == FwupdStatus.complete) {
          loadState(const FirmwareDownloadComplete());
        }

        if (state.item2 == ConnectionStatus.disconnected && _fwupdService.status == FwupdStatus.downloading) {
          loadState(const FirmwareErrorNotify(error: FirmwareError.firmwareDownloadFail,code: ErrorCode.uploadFail));
        }
        if (state.item2 == ConnectionStatus.disconnected && _fwupdService.status == FwupdStatus.idle) {
          loadState(const DeviceNotConnected());
        }
      },
    );
  }

  Future<void> _unsubscribeSubscription() async {
    await _statusesSubscription?.cancel();
    _statusesSubscription = null;
  }

  _changeLatestStatus() {
    if (isClosed) {
      Log.i("not connected Device");
      loadState(const DeviceNotConnected());
      return;
    }

    if (_fwupdService.status == FwupdStatus.downloading) {
      loadState(FirmwareDownloadProgress(downloadProgress: _fwupdService.percentage));
    }
  }

  registerPercentageCallback() {
    _fwupdService.addFirmWareChannelListener(
      FirmWareChannelListener(
        onPercentageChanged: (progress) {
          Log.d('[ViewModel Receive] onPercentageChanged $progress');
          if (percentage.subject.isClosed) return;
          percentage.val = progress;
        },
      ),
    );
  }

  void checkFirmwareVersion() async {
    Log.i('[checkFirmwareVersion] ${_fwupdService.status} | isCloned $isClosed | connectionMode $connectionMode');

    _changeLatestStatus();
    registerPercentageCallback();

    if (_fwupdService.status != FwupdStatus.idle || isClosed) {
      Log.i('checkFirmwareVersion status is not idle or not connected Device');
      return;
    }

    try {
      loadState(const FirmwareVersionInfoRequested());
      _firmwareVersion = await _patchRepository.fetchPatchDetails();

      final response = await _wifiRepository.send(VersionDataRequest().rawBytes, timeout: const Duration(seconds: 5));

      if(response is FirmwareVersionResponse){
        final serverVersion = int.parse(_firmwareVersion!.versionNumber.replaceAll('.', ''));
        final deviceVersion = int.parse(response.verCode);

        Log.d('serverVersion: $serverVersion, deviceVersion: $deviceVersion');

        if (serverVersion > deviceVersion) {
          loadState(FirmwareVersionInfoReceived(data: _firmwareVersion!, currentVersion: response.verCode));
        } else {
          loadState(FirmwareAlreadyLatestVersion(currentVersion: response.verCode));
        }
      }
    } catch (e) {
      Log.e('[checkFirmwareUpdate] error: $e');
      loadState(const FirmwareErrorNotify(error: FirmwareError.serverDownloadFail,code: ErrorCode.deviceTimeout));
    }
  }

  void installFirmware() async {
    if (firmwareUiEvent.val is FirmwareVersionInfoReceived) {
      try {
        final firmwareVersion = (firmwareUiEvent.val as FirmwareVersionInfoReceived).data;

        if (!firmwareVersion.isNullOrEmpty) {
          loadState(const FirmwareDownloadProgress(downloadProgress: null));
          await _fwupdService.wifiInstall(firmwareVersion!);
          await _wifiRepository.send(RebootDataRequest().getRawBytes(), isAutoConnect: true);
          loadState(const FirmwareDownloadComplete());
        }
      } catch (e) {
        Log.e('[installFirmware] error... $e');
        loadState(const FirmwareErrorNotify(error: FirmwareError.firmwareDownloadFail,code: ErrorCode.uploadFail));
      }
    }
  }

  void loadState(state) {
    if (firmwareUiEvent.subject.isClosed) {
      return;
    }
    firmwareUiEvent.val = state;
  }

  void dispose() {
    CancelTokenManager.cancelAll();
    firmwareUiEvent.close();
    percentage.close();
    _fwupdService.reboot();
    _unsubscribeSubscription();
  }
}
