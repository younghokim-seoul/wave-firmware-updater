// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firmware_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FirmwareVersion {
  String get versionNumber => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileSize => throw _privateConstructorUsedError;
  String get versionCode => throw _privateConstructorUsedError;
  String get osCode => throw _privateConstructorUsedError;
  String get patchDownloadUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FirmwareVersionCopyWith<FirmwareVersion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirmwareVersionCopyWith<$Res> {
  factory $FirmwareVersionCopyWith(
          FirmwareVersion value, $Res Function(FirmwareVersion) then) =
      _$FirmwareVersionCopyWithImpl<$Res, FirmwareVersion>;
  @useResult
  $Res call(
      {String versionNumber,
      String fileName,
      String fileSize,
      String versionCode,
      String osCode,
      String patchDownloadUrl});
}

/// @nodoc
class _$FirmwareVersionCopyWithImpl<$Res, $Val extends FirmwareVersion>
    implements $FirmwareVersionCopyWith<$Res> {
  _$FirmwareVersionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? versionNumber = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? versionCode = null,
    Object? osCode = null,
    Object? patchDownloadUrl = null,
  }) {
    return _then(_value.copyWith(
      versionNumber: null == versionNumber
          ? _value.versionNumber
          : versionNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as String,
      versionCode: null == versionCode
          ? _value.versionCode
          : versionCode // ignore: cast_nullable_to_non_nullable
              as String,
      osCode: null == osCode
          ? _value.osCode
          : osCode // ignore: cast_nullable_to_non_nullable
              as String,
      patchDownloadUrl: null == patchDownloadUrl
          ? _value.patchDownloadUrl
          : patchDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirmwareVersionImplCopyWith<$Res>
    implements $FirmwareVersionCopyWith<$Res> {
  factory _$$FirmwareVersionImplCopyWith(_$FirmwareVersionImpl value,
          $Res Function(_$FirmwareVersionImpl) then) =
      __$$FirmwareVersionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String versionNumber,
      String fileName,
      String fileSize,
      String versionCode,
      String osCode,
      String patchDownloadUrl});
}

/// @nodoc
class __$$FirmwareVersionImplCopyWithImpl<$Res>
    extends _$FirmwareVersionCopyWithImpl<$Res, _$FirmwareVersionImpl>
    implements _$$FirmwareVersionImplCopyWith<$Res> {
  __$$FirmwareVersionImplCopyWithImpl(
      _$FirmwareVersionImpl _value, $Res Function(_$FirmwareVersionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? versionNumber = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? versionCode = null,
    Object? osCode = null,
    Object? patchDownloadUrl = null,
  }) {
    return _then(_$FirmwareVersionImpl(
      versionNumber: null == versionNumber
          ? _value.versionNumber
          : versionNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as String,
      versionCode: null == versionCode
          ? _value.versionCode
          : versionCode // ignore: cast_nullable_to_non_nullable
              as String,
      osCode: null == osCode
          ? _value.osCode
          : osCode // ignore: cast_nullable_to_non_nullable
              as String,
      patchDownloadUrl: null == patchDownloadUrl
          ? _value.patchDownloadUrl
          : patchDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FirmwareVersionImpl implements _FirmwareVersion {
  const _$FirmwareVersionImpl(
      {required this.versionNumber,
      required this.fileName,
      required this.fileSize,
      required this.versionCode,
      required this.osCode,
      required this.patchDownloadUrl});

  @override
  final String versionNumber;
  @override
  final String fileName;
  @override
  final String fileSize;
  @override
  final String versionCode;
  @override
  final String osCode;
  @override
  final String patchDownloadUrl;

  @override
  String toString() {
    return 'FirmwareVersion(versionNumber: $versionNumber, fileName: $fileName, fileSize: $fileSize, versionCode: $versionCode, osCode: $osCode, patchDownloadUrl: $patchDownloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareVersionImpl &&
            (identical(other.versionNumber, versionNumber) ||
                other.versionNumber == versionNumber) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.versionCode, versionCode) ||
                other.versionCode == versionCode) &&
            (identical(other.osCode, osCode) || other.osCode == osCode) &&
            (identical(other.patchDownloadUrl, patchDownloadUrl) ||
                other.patchDownloadUrl == patchDownloadUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, versionNumber, fileName,
      fileSize, versionCode, osCode, patchDownloadUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareVersionImplCopyWith<_$FirmwareVersionImpl> get copyWith =>
      __$$FirmwareVersionImplCopyWithImpl<_$FirmwareVersionImpl>(
          this, _$identity);
}

abstract class _FirmwareVersion implements FirmwareVersion {
  const factory _FirmwareVersion(
      {required final String versionNumber,
      required final String fileName,
      required final String fileSize,
      required final String versionCode,
      required final String osCode,
      required final String patchDownloadUrl}) = _$FirmwareVersionImpl;

  @override
  String get versionNumber;
  @override
  String get fileName;
  @override
  String get fileSize;
  @override
  String get versionCode;
  @override
  String get osCode;
  @override
  String get patchDownloadUrl;
  @override
  @JsonKey(ignore: true)
  _$$FirmwareVersionImplCopyWith<_$FirmwareVersionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
