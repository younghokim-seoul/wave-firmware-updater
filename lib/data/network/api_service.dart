import 'package:dio/dio.dart';
import 'package:retrofit/http.dart' as http;
import 'package:retrofit/retrofit.dart';
import 'package:wave_desktop_installer/data/network/response/patch_info_response.dart';

import 'package:wave_desktop_installer/data/network/response/patch_version_response.dart';
import 'package:wave_desktop_installer/utils/constant.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(final Dio dio) = _ApiService;

  @GET('${Const.publicApi}/patch.ajax')
  Future<PatchInfoResponse> patch();

}
