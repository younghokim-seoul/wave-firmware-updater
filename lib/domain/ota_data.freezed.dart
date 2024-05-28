// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ota_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OtaData {
  int get totalDataLen => throw _privateConstructorUsedError;
  int get totalPageNum => throw _privateConstructorUsedError;
  int get pageNum => throw _privateConstructorUsedError;
  int get lastPageDataLen => throw _privateConstructorUsedError;
  int get sendCnt => throw _privateConstructorUsedError;
  Uint8List get totalBuff => throw _privateConstructorUsedError;
  Uint8List get pageBuff => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OtaDataCopyWith<OtaData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtaDataCopyWith<$Res> {
  factory $OtaDataCopyWith(OtaData value, $Res Function(OtaData) then) =
      _$OtaDataCopyWithImpl<$Res, OtaData>;
  @useResult
  $Res call(
      {int totalDataLen,
      int totalPageNum,
      int pageNum,
      int lastPageDataLen,
      int sendCnt,
      Uint8List totalBuff,
      Uint8List pageBuff});
}

/// @nodoc
class _$OtaDataCopyWithImpl<$Res, $Val extends OtaData>
    implements $OtaDataCopyWith<$Res> {
  _$OtaDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDataLen = null,
    Object? totalPageNum = null,
    Object? pageNum = null,
    Object? lastPageDataLen = null,
    Object? sendCnt = null,
    Object? totalBuff = null,
    Object? pageBuff = null,
  }) {
    return _then(_value.copyWith(
      totalDataLen: null == totalDataLen
          ? _value.totalDataLen
          : totalDataLen // ignore: cast_nullable_to_non_nullable
              as int,
      totalPageNum: null == totalPageNum
          ? _value.totalPageNum
          : totalPageNum // ignore: cast_nullable_to_non_nullable
              as int,
      pageNum: null == pageNum
          ? _value.pageNum
          : pageNum // ignore: cast_nullable_to_non_nullable
              as int,
      lastPageDataLen: null == lastPageDataLen
          ? _value.lastPageDataLen
          : lastPageDataLen // ignore: cast_nullable_to_non_nullable
              as int,
      sendCnt: null == sendCnt
          ? _value.sendCnt
          : sendCnt // ignore: cast_nullable_to_non_nullable
              as int,
      totalBuff: null == totalBuff
          ? _value.totalBuff
          : totalBuff // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      pageBuff: null == pageBuff
          ? _value.pageBuff
          : pageBuff // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtaDataImplCopyWith<$Res> implements $OtaDataCopyWith<$Res> {
  factory _$$OtaDataImplCopyWith(
          _$OtaDataImpl value, $Res Function(_$OtaDataImpl) then) =
      __$$OtaDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalDataLen,
      int totalPageNum,
      int pageNum,
      int lastPageDataLen,
      int sendCnt,
      Uint8List totalBuff,
      Uint8List pageBuff});
}

/// @nodoc
class __$$OtaDataImplCopyWithImpl<$Res>
    extends _$OtaDataCopyWithImpl<$Res, _$OtaDataImpl>
    implements _$$OtaDataImplCopyWith<$Res> {
  __$$OtaDataImplCopyWithImpl(
      _$OtaDataImpl _value, $Res Function(_$OtaDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDataLen = null,
    Object? totalPageNum = null,
    Object? pageNum = null,
    Object? lastPageDataLen = null,
    Object? sendCnt = null,
    Object? totalBuff = null,
    Object? pageBuff = null,
  }) {
    return _then(_$OtaDataImpl(
      totalDataLen: null == totalDataLen
          ? _value.totalDataLen
          : totalDataLen // ignore: cast_nullable_to_non_nullable
              as int,
      totalPageNum: null == totalPageNum
          ? _value.totalPageNum
          : totalPageNum // ignore: cast_nullable_to_non_nullable
              as int,
      pageNum: null == pageNum
          ? _value.pageNum
          : pageNum // ignore: cast_nullable_to_non_nullable
              as int,
      lastPageDataLen: null == lastPageDataLen
          ? _value.lastPageDataLen
          : lastPageDataLen // ignore: cast_nullable_to_non_nullable
              as int,
      sendCnt: null == sendCnt
          ? _value.sendCnt
          : sendCnt // ignore: cast_nullable_to_non_nullable
              as int,
      totalBuff: null == totalBuff
          ? _value.totalBuff
          : totalBuff // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      pageBuff: null == pageBuff
          ? _value.pageBuff
          : pageBuff // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$OtaDataImpl implements _OtaData {
  const _$OtaDataImpl(
      {required this.totalDataLen,
      required this.totalPageNum,
      required this.pageNum,
      required this.lastPageDataLen,
      required this.sendCnt,
      required this.totalBuff,
      required this.pageBuff});

  @override
  final int totalDataLen;
  @override
  final int totalPageNum;
  @override
  final int pageNum;
  @override
  final int lastPageDataLen;
  @override
  final int sendCnt;
  @override
  final Uint8List totalBuff;
  @override
  final Uint8List pageBuff;

  @override
  String toString() {
    return 'OtaData(totalDataLen: $totalDataLen, totalPageNum: $totalPageNum, pageNum: $pageNum, lastPageDataLen: $lastPageDataLen, sendCnt: $sendCnt, totalBuff: $totalBuff, pageBuff: $pageBuff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtaDataImpl &&
            (identical(other.totalDataLen, totalDataLen) ||
                other.totalDataLen == totalDataLen) &&
            (identical(other.totalPageNum, totalPageNum) ||
                other.totalPageNum == totalPageNum) &&
            (identical(other.pageNum, pageNum) || other.pageNum == pageNum) &&
            (identical(other.lastPageDataLen, lastPageDataLen) ||
                other.lastPageDataLen == lastPageDataLen) &&
            (identical(other.sendCnt, sendCnt) || other.sendCnt == sendCnt) &&
            const DeepCollectionEquality().equals(other.totalBuff, totalBuff) &&
            const DeepCollectionEquality().equals(other.pageBuff, pageBuff));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalDataLen,
      totalPageNum,
      pageNum,
      lastPageDataLen,
      sendCnt,
      const DeepCollectionEquality().hash(totalBuff),
      const DeepCollectionEquality().hash(pageBuff));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OtaDataImplCopyWith<_$OtaDataImpl> get copyWith =>
      __$$OtaDataImplCopyWithImpl<_$OtaDataImpl>(this, _$identity);
}

abstract class _OtaData implements OtaData {
  const factory _OtaData(
      {required final int totalDataLen,
      required final int totalPageNum,
      required final int pageNum,
      required final int lastPageDataLen,
      required final int sendCnt,
      required final Uint8List totalBuff,
      required final Uint8List pageBuff}) = _$OtaDataImpl;

  @override
  int get totalDataLen;
  @override
  int get totalPageNum;
  @override
  int get pageNum;
  @override
  int get lastPageDataLen;
  @override
  int get sendCnt;
  @override
  Uint8List get totalBuff;
  @override
  Uint8List get pageBuff;
  @override
  @JsonKey(ignore: true)
  _$$OtaDataImplCopyWith<_$OtaDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
