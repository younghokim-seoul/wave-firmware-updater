import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:ftp_connect/ftpconnect.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_listener.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

@LazySingleton(as: FwupdService)
class FwupdImp extends FwupdService {
  FwupdImp(this._bluetoothRepository)
      : _dio = Dio(),
        _fs = const LocalFileSystem();

  // _ftp = FTPConnect(
  //   Const.waveIp,
  //   port: Const.ftpPort,
  //   user: Const.ftpUser,
  //   pass: Const.ftpPass,
  //   showLog: true,
  // );

  final Dio _dio;
  final FileSystem _fs;
  FTPConnect? _ftp;
  final BluetoothRepository _bluetoothRepository;

  double? _downloadProgress;
  FwupdStatus _currentState = FwupdStatus.idle;

  FirmWareChannelListener? _firmWareChannelListener;

  String get parentPath => p.join(p.dirname(Platform.resolvedExecutable), '..', '..', 'BinaryPatch');

  Future<File> _downloadRelease(String url) async {
    final path = p.join(_fs.systemTempDirectory.path, p.basename(url));
    Log.d('download $url to $path');
    try {
      return await _dio.download(url, path).then(
        (response) {
          final file = _fs.file(path);
          final newPath = p.join(_fs.systemTempDirectory.path, 'patch${p.extension(path)}');
          return file.rename(newPath);
        },
      );
    } finally {
      _setDownloadProgress(null);
    }
  }

  void _setDownloadProgress(double? progress) {
    if (_downloadProgress == progress) return;
    _downloadProgress = progress;

    Log.d("_setDownloadProgress..... $_downloadProgress");
    Log.d('_firmWareChannelListener..... $_firmWareChannelListener');
    _firmWareChannelListener?.onPercentageChanged?.call((progress ?? 0));
  }

  @override
  // TODO: implement status
  FwupdStatus get status => _downloadProgress != null ? FwupdStatus.downloading : _currentState;

  @override
  Future<void> wifiInstall() async {
    Log.d('::::wifi Firmware Install...');
    try {
      if (_currentState == FwupdStatus.downloading) {
        return;
      }

      _currentState = FwupdStatus.downloading;
      // final patchFile = await _downloadRelease(release.patchDownloadUrl);
      final zipPath = p.join(parentPath, 'patch.zip');
      Log.d("zipPath... $zipPath");
      final patchFile = _fs.file(zipPath);
      if (!patchFile.existsSync()) {
        throw FwupdException('file not exist', ErrorCode.notFoundBinaryFile.code);
      }
      final fileSize = await patchFile.readAsBytes();
      Log.d('::::patchFile fileSize... ${fileSize.length}');
      await _installBinary(patchFile);
      _currentState = FwupdStatus.complete;
    } on Exception catch (e) {
      Log.e('::::install error... $e');
      _setDownloadProgress(null);
      _currentState = FwupdStatus.idle;
      rethrow;
    }
  }

  @override
  Future<void> bluetoothInstall(FirmwareVersion release) async {
    Log.d('::::bluetoothInstall... $release');
    try {
      _currentState = FwupdStatus.downloading;
      final patchFile = await _downloadRelease(release.patchDownloadUrl);
      // final fileSize = await patchFile.readAsBytes();
      // Log.d("::::patchFile fileSize... ${fileSize.length}");
      await _bluetoothRepository.startOTA(patchFile, (progress) {
        Log.d("블루투스 퍼센테이지... $progress");
        _setDownloadProgress(progress);
      });
      Log.d('::::블루투스 펌웨어 업데이트 완료....');
      _currentState = FwupdStatus.complete;
    } on Exception catch (e) {
      Log.e('::::install error... $e');
      _bluetoothRepository.failOTA();
      _setDownloadProgress(null);
      _currentState = FwupdStatus.idle;
      rethrow;
    }
  }

  Future<void> _installBinary(File file) async {
    try {
      Log.i('Connecting to FTP ...');

      _ftp = FTPConnect(Const.waveIp, port: Const.ftpPort, user: Const.ftpUser, pass: Const.ftpPass, showLog: true);
      await _ftp!.connect();
      final status = await _ftp!.changeDirectory('GRadar_DLL');
      Log.i('status to FTP ...$status');
      Log.i('Uploading ...');
      await _ftp!.uploadFile(file, onProgress: (progress, total, fileSize) {
        print('progress: $progress' + ' total: $total ' + ' filesize: $fileSize ');
        _setDownloadProgress(progress);
      });
      Log.i('file uploaded sucessfully');
      await _ftp!.disconnect();
    } catch (e) {
      Log.i('Error: ${e.toString()}');
      rethrow;
    } finally {
      _setDownloadProgress(null);
    }
  }

  @override
  double get percentage => _downloadProgress ?? 0;

  @override
  void addFirmWareChannelListener(FirmWareChannelListener listener) {
    _firmWareChannelListener = listener;
  }

  @override
  Future<void> reboot() async {
    if (_currentState == FwupdStatus.complete) {
      _currentState = FwupdStatus.idle;
    }
  }

  @override
  void removeFirmWareChannelListener() {
    _firmWareChannelListener = null;
  }

  @override
  Future<void> cancelInstall() async {
    try {
      await _ftp?.disconnect();
    } catch (e) {
      Log.i('Error: ${e.toString()}');
    } finally {
      _setDownloadProgress(null);
      _currentState = FwupdStatus.idle;
    }
  }

  @override
  Future<void> writeConfig(FirmwareVersion version) async {
    final dir = _fs.file(p.join(parentPath, 'config.txt'));

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await dir.writeAsString(version.versionNumber);
  }

  @override
  Future<String> readConfig() async {
    final dir = _fs.file(p.join(parentPath, 'config.txt'));

    realLog.info('readConfig... $dir');
    if (!dir.existsSync()) {
      return '';
    }
    return await dir.readAsString();
  }
}
