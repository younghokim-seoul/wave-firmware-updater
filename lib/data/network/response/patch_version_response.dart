import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_version_response.freezed.dart';
part 'patch_version_response.g.dart';

@freezed
class PatchVersionResponse with _$PatchVersionResponse {
  const factory PatchVersionResponse({
    required String? verDatAttcIdFileSize,
    required String? verNo,
    required String? verFirmwareAttcIdFileNm,
    required String? verStateCd,
    required String? verDatAttcIdImg,
    required String? verOsCd,
    required String? verHexAttcIdFileSize,
    required String? verFirmwareAttcIdImg,
    required String? verHexAttcIdFileNm,
    required String? verReleaseUrlAddr,
    required String? verHexAttcIdImg,
    required String? verDatAttcIdFileNm,
    required String? verFirmwareAttcIdFileSize,
    required String? verMgmtAppNm,
  }) = _PatchVersionResponse;

  factory PatchVersionResponse.fromJson(Map<String,dynamic> json) => _$PatchVersionResponseFromJson(json);
}