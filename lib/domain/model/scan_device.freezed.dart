// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScanDevice {
  String get deviceName => throw _privateConstructorUsedError;
  String get macAddress => throw _privateConstructorUsedError;
  String get rssi => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScanDeviceCopyWith<ScanDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanDeviceCopyWith<$Res> {
  factory $ScanDeviceCopyWith(
          ScanDevice value, $Res Function(ScanDevice) then) =
      _$ScanDeviceCopyWithImpl<$Res, ScanDevice>;
  @useResult
  $Res call({String deviceName, String macAddress, String rssi});
}

/// @nodoc
class _$ScanDeviceCopyWithImpl<$Res, $Val extends ScanDevice>
    implements $ScanDeviceCopyWith<$Res> {
  _$ScanDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = null,
    Object? macAddress = null,
    Object? rssi = null,
  }) {
    return _then(_value.copyWith(
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      macAddress: null == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanDeviceImplCopyWith<$Res>
    implements $ScanDeviceCopyWith<$Res> {
  factory _$$ScanDeviceImplCopyWith(
          _$ScanDeviceImpl value, $Res Function(_$ScanDeviceImpl) then) =
      __$$ScanDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deviceName, String macAddress, String rssi});
}

/// @nodoc
class __$$ScanDeviceImplCopyWithImpl<$Res>
    extends _$ScanDeviceCopyWithImpl<$Res, _$ScanDeviceImpl>
    implements _$$ScanDeviceImplCopyWith<$Res> {
  __$$ScanDeviceImplCopyWithImpl(
      _$ScanDeviceImpl _value, $Res Function(_$ScanDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = null,
    Object? macAddress = null,
    Object? rssi = null,
  }) {
    return _then(_$ScanDeviceImpl(
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      macAddress: null == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String,
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ScanDeviceImpl implements _ScanDevice {
  const _$ScanDeviceImpl(
      {required this.deviceName, required this.macAddress, required this.rssi});

  @override
  final String deviceName;
  @override
  final String macAddress;
  @override
  final String rssi;

  @override
  String toString() {
    return 'ScanDevice(deviceName: $deviceName, macAddress: $macAddress, rssi: $rssi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanDeviceImpl &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.rssi, rssi) || other.rssi == rssi));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceName, macAddress, rssi);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanDeviceImplCopyWith<_$ScanDeviceImpl> get copyWith =>
      __$$ScanDeviceImplCopyWithImpl<_$ScanDeviceImpl>(this, _$identity);
}

abstract class _ScanDevice implements ScanDevice {
  const factory _ScanDevice(
      {required final String deviceName,
      required final String macAddress,
      required final String rssi}) = _$ScanDeviceImpl;

  @override
  String get deviceName;
  @override
  String get macAddress;
  @override
  String get rssi;
  @override
  @JsonKey(ignore: true)
  _$$ScanDeviceImplCopyWith<_$ScanDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
