import 'dart:async';

import 'package:control_protocol/control_protocol.dart';
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

  ConnectionMode connectionMode = ConnectionMode.wifi;

  bool get isClosed => connectionMode == ConnectionMode.wifi ? _wifiRepository.isClosed : _bleRepository.isClosed;

  final firmwareUiEvent = ArcSubject<FirmwareUpdateEvent>();
  final percentage = ArcSubject<double>(seed: 0.0);
  StreamSubscription? _statusesSubscription;

  void setConnectionMode(ConnectionMode mode) {
    connectionMode = mode;
  }

  Future<void> subscribeToStatuses() async {
    Log.i(":::::: subscribeToMessages");

    if (connectionMode == ConnectionMode.wifi) {
      _statusesSubscription ??= _wifiRepository.statuses.listen(
        (state) {
          Log.i('::::: wifi 연결상태 콜백 $state');
          rememberLatestState();
        },
        onDone: () {
          Log.i('::::: subscribeToMessages onDone');
        },
      );
    } else {
      _statusesSubscription ??= _bleRepository.statuses.listen(
        (state) {
          Log.i('::::: bluetooth 연결상태 콜백 ${state.state} ${state.address}');
          rememberLatestState();
        },
        onDone: () {
          Log.i('::::: subscribeToMessages onDone');
        },
      );
    }
  }

  Future<void> _unsubscribeFromStatuses() async {
    Log.i(":::::: _unsubscribeFromStatuses");
    await _statusesSubscription?.cancel();
    _statusesSubscription = null;
  }

  rememberLatestState() {
    if (isClosed) {
      Log.i("not connected Device");
      loadState(const DeviceNotConnected());
      return;
    }

    Log.i("addFirmWareChannelListener");
    _fwupdService.addFirmWareChannelListener(
      FirmWareChannelListener(
        onPercentageChanged: (progress) {
          Log.d('[ViewModel Receive] onPercentageChanged $progress');
          if(percentage.subject.isClosed)return;
          percentage.val = progress;
        },
      ),
    );
  }

  void checkFirmwareVersion() async {
    Log.i('[checkFirmwareVersion]' +
        _fwupdService.status.toString() +
        " | isCloed " +
        isClosed.toString() +
        " | connectionMode " +
        connectionMode.toString());

    rememberLatestState();

    if (_fwupdService.status != FwupdStatus.idle || isClosed) {
      Log.i('checkFirmwareVersion status is not idle or not connected Device');
      return;
    }
    try {
      loadState(const FirmwareVersionInfoRequested());
      final response = await _patchRepository.fetchPatchDetails();
      Log.i('[checkFirmwareUpdate] response $response');

      //todo : 최신 버전 체크 과 다운로드 분기처리 필요
      loadState(FirmwareVersionInfoReceived(data: response));
    } catch (e) {
      Log.e('[checkFirmwareUpdate] error: $e');
      loadState(const FirmwareVersionInfoReceived(data: null));
    }
  }

  void installFirmware() async {
    //todo : 블루투스와  WIFI 분기처리 필요..
    if (firmwareUiEvent.val is FirmwareVersionInfoReceived) {
      try {
        final firmwareVersion = (firmwareUiEvent.val as FirmwareVersionInfoReceived).data;

        if (!firmwareVersion.isNullOrEmpty) {
          loadState(const FirmwareDownloadProgress(downloadProgress: null));
          if (connectionMode == ConnectionMode.bluetooth) {
            await _fwupdService.bluetoothInstall(firmwareVersion!);
            await _bleRepository.send(RebootDataRequest().getRawBytes());
            loadState(const FirmwareDownloadComplete());
          } else {
            await _fwupdService.wifiInstall(firmwareVersion!);
            await _wifiRepository.send(RebootDataRequest().getRawBytes(), isAutoConnect: true);
           loadState(const FirmwareDownloadComplete());
          }
        }
      } catch (e) {
        Log.e("[installFirmware] error... $e");
        loadState(const FirmwareErrorNotify(error: FirmwareError.firmwareDownloadFail));
      }
    }
  }

  void loadState(state) {
    if(firmwareUiEvent.subject.isClosed)return;
    firmwareUiEvent.val = state;
  }

  void dispose() {
    firmwareUiEvent.close();
    percentage.close();
    _unsubscribeFromStatuses();
  }
}
