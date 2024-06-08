import 'package:freezed_annotation/freezed_annotation.dart';

part 'firmware_version.freezed.dart';

@freezed
class FirmwareVersion with _$FirmwareVersion {
  const factory FirmwareVersion({
    required String versionNumber,
    required String fileName,
    required String fileSize,
    required String versionCode,
    required String osCode,
    required String patchDownloadUrl,
  }) = _FirmwareVersion;

  factory FirmwareVersion.empty() => const FirmwareVersion(
        versionNumber: '',
        fileName: '',
        fileSize: '',
        versionCode: '',
        osCode: '',
        patchDownloadUrl: '',
      );
}
