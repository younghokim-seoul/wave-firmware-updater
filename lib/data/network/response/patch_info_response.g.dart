// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatchInfoResponseImpl _$$PatchInfoResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PatchInfoResponseImpl(
      status: (json['status'] as num).toInt(),
      error: json['error'] as String?,
      message: json['message'] as String?,
      redirect: json['redirect'] as String?,
      versions: (json['versions'] as List<dynamic>)
          .map((e) => PatchVersionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PatchInfoResponseImplToJson(
        _$PatchInfoResponseImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'error': instance.error,
      'message': instance.message,
      'redirect': instance.redirect,
      'versions': instance.versions,
    };
