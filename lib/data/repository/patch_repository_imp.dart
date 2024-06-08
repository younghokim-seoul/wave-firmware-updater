import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/exception/network_exception.dart';
import 'package:wave_desktop_installer/data/network/api_client.dart';
import 'package:wave_desktop_installer/data/network/api_service.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';
import 'package:wave_desktop_installer/domain/repository/patch_repository.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';

@LazySingleton(as: PatchRepository)
class PatchRepositoryImp implements PatchRepository {
  final ApiService _apiService;

  PatchRepositoryImp(this._apiService);

  @override
  Future<FirmwareVersion> fetchPatchDetails() async {
    try {
      final response = await _apiService.patch();

      if(!response.error.isNullOrEmpty){
        throw NetworkException('Api error occurred');
      }

      final firmwareVersion = response.versions
          .where((e) => e.verOsCd == Const.waveOsCode)
          .map(
            (e) => FirmwareVersion(
                versionNumber: e.verNo ?? '',
                fileName: e.verFirmwareAttcIdFileNm ?? '',
                fileSize: e.verFirmwareAttcIdFileSize ?? '',
                versionCode: e.verStateCd ?? '',
                osCode: e.verOsCd ?? '',
                patchDownloadUrl: e.verFirmwareAttcIdImg ?? ''),
          )
          .first;

      return firmwareVersion;
    } on DioException catch (e, t) {
      throw NetworkException(e.message ?? 'Unknown error occurred',t);
    } catch (e, t) {
      throw NetworkException(e.toString(),t);
    }
  }
}
