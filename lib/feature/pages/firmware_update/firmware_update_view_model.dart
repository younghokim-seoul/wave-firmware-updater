import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
import 'package:ftp_connect/ftpconnect.dart';
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
import 'package:wave_desktop_installer/main.dart';
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



  bool get isClosed => _wifiRepository.isClosed;

  final firmwareUiEvent = ArcSubject<FirmwareUpdateEvent>();
  final percentage = ArcSubject<double>(seed: 0.0);
  StreamSubscription? _statusesSubscription;

  // FirmwareVersion? _firmwareVersion;


  Future<void> subscribeToStatuses() async {
    _wifiRepository.setRetryConnectMode(false);
    _statusesSubscription ??= _wifiRepository.statuses.listen(
      (state) async {
        realLog.info('[FirmwareUpdateViewModel] Connection Callback $state | ${_fwupdService.status}');
        if (state.item2 == ConnectionStatus.disconnected && _fwupdService.status == FwupdStatus.complete) {
          loadState(const FirmwareDownloadComplete());
        }

        if (state.item2 == ConnectionStatus.disconnected && _fwupdService.status == FwupdStatus.downloading) {
          await _fwupdService.cancelInstall();
          loadState(const FirmwareErrorNotify(code: ErrorCode.deviceTimeout));
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
      realLog.info('Wave Not Connect');
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
          realLog.info('[ViewModel Receive] onPercentageChanged $progress');
          if (percentage.subject.isClosed) return;
          percentage.val = progress;
        },
      ),
    );
  }

  void checkFirmwareVersion({bool isForced = false}) async {
    realLog.info('[checkFirmwareVersion] ${_fwupdService.status} | isCloned $isClosed');

    _changeLatestStatus();
    registerPercentageCallback();

    if (_fwupdService.status != FwupdStatus.idle || isClosed) {
      realLog.info('checkFirmwareVersion status is not idle or not connected Device');
      return;
    }

    try {
      loadState(const FirmwareVersionInfoRequested());

      final versionConfig = await _fwupdService.readConfig();

      realLog.info('current versionConfig $versionConfig');

      if (versionConfig.isNullOrEmpty) {
        realLog.error('version config empty');
        loadState(const FirmwareErrorNotify(code: ErrorCode.notFoundBinaryFile));
        return;
      }

      realLog.info('GET SW VER Request...........');
      final response = await _wifiRepository.send(VersionDataRequest().rawBytes, timeout: const Duration(seconds: 5));
      realLog.info('GET SW VER Response..$response');
      if (response is FirmwareVersionResponse) {
        final serverVersion = int.parse(versionConfig.replaceAll('.', ''));
        final deviceVersion = int.parse(response.verCode);

        realLog.info('serverVersion: $serverVersion, deviceVersion: $deviceVersion');

        if (serverVersion > deviceVersion) {
          loadState(FirmwareVersionInfoReceived(localVersion: versionConfig, currentVersion: response.verCode));
        } else {
          loadState(FirmwareAlreadyLatestVersion(currentVersion: response.verCode));
        }
      } else {
        loadState(const FirmwareErrorNotify(code: ErrorCode.deviceTimeout));
      }
    } catch (e) {
      realLog.error('[checkFirmwareUpdate] error: $e');
      loadState(const FirmwareErrorNotify(code: ErrorCode.deviceTimeout));
    }
  }

  void installFirmware() async {
    if (firmwareUiEvent.val is FirmwareVersionInfoReceived) {
      try {

        loadState(const FirmwareDownloadProgress(downloadProgress: null));
        await _fwupdService.wifiInstall();
        await _wifiRepository.cancelPing();
        await _wifiRepository.send(RebootDataRequest().getRawBytes(), isAutoConnect: true);
        loadState(const FirmwareDownloadComplete());
      } catch (e) {
        Log.e('[installFirmware] error... $e');
        ErrorCode errorCode = ErrorCode.undefinedErrorCode;
        if (e is FTPConnectException) {
          errorCode = ErrorCode.serverConnectFail;
        } else if (e is FwupdException) {
          errorCode = ErrorCode.fromCode(e.code);
        }
        loadState(FirmwareErrorNotify(code: errorCode));
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
    // CancelTokenManager.cancelAll();
    firmwareUiEvent.close();
    percentage.close();
    _fwupdService.reboot();
    _unsubscribeSubscription();
  }
}
