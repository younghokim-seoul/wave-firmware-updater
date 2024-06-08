import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/data/network/response/patch_version_response.dart';

part 'patch_info_response.freezed.dart';
part 'patch_info_response.g.dart';

@freezed
class PatchInfoResponse with _$PatchInfoResponse {
  const factory PatchInfoResponse({
    required int status,
    required String? error,
    required String? message,
    required String? redirect,
    required List<PatchVersionResponse> versions,
  }) = _PatchInfoResponse;

  factory PatchInfoResponse.fromJson(Map<String,dynamic> json) => _$PatchInfoResponseFromJson(json);
}