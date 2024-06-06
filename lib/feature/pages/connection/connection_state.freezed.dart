// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConnectionUiState {
  List<ScanDevice> get scanDevices => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConnectionUiStateCopyWith<ConnectionUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionUiStateCopyWith<$Res> {
  factory $ConnectionUiStateCopyWith(
          ConnectionUiState value, $Res Function(ConnectionUiState) then) =
      _$ConnectionUiStateCopyWithImpl<$Res, ConnectionUiState>;
  @useResult
  $Res call({List<ScanDevice> scanDevices});
}

/// @nodoc
class _$ConnectionUiStateCopyWithImpl<$Res, $Val extends ConnectionUiState>
    implements $ConnectionUiStateCopyWith<$Res> {
  _$ConnectionUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanDevices = null,
  }) {
    return _then(_value.copyWith(
      scanDevices: null == scanDevices
          ? _value.scanDevices
          : scanDevices // ignore: cast_nullable_to_non_nullable
              as List<ScanDevice>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionUiStateImplCopyWith<$Res>
    implements $ConnectionUiStateCopyWith<$Res> {
  factory _$$ConnectionUiStateImplCopyWith(_$ConnectionUiStateImpl value,
          $Res Function(_$ConnectionUiStateImpl) then) =
      __$$ConnectionUiStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ScanDevice> scanDevices});
}

/// @nodoc
class __$$ConnectionUiStateImplCopyWithImpl<$Res>
    extends _$ConnectionUiStateCopyWithImpl<$Res, _$ConnectionUiStateImpl>
    implements _$$ConnectionUiStateImplCopyWith<$Res> {
  __$$ConnectionUiStateImplCopyWithImpl(_$ConnectionUiStateImpl _value,
      $Res Function(_$ConnectionUiStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scanDevices = null,
  }) {
    return _then(_$ConnectionUiStateImpl(
      scanDevices: null == scanDevices
          ? _value._scanDevices
          : scanDevices // ignore: cast_nullable_to_non_nullable
              as List<ScanDevice>,
    ));
  }
}

/// @nodoc

class _$ConnectionUiStateImpl implements _ConnectionUiState {
  const _$ConnectionUiStateImpl({required final List<ScanDevice> scanDevices})
      : _scanDevices = scanDevices;

  final List<ScanDevice> _scanDevices;
  @override
  List<ScanDevice> get scanDevices {
    if (_scanDevices is EqualUnmodifiableListView) return _scanDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scanDevices);
  }

  @override
  String toString() {
    return 'ConnectionUiState(scanDevices: $scanDevices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionUiStateImpl &&
            const DeepCollectionEquality()
                .equals(other._scanDevices, _scanDevices));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_scanDevices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionUiStateImplCopyWith<_$ConnectionUiStateImpl> get copyWith =>
      __$$ConnectionUiStateImplCopyWithImpl<_$ConnectionUiStateImpl>(
          this, _$identity);
}

abstract class _ConnectionUiState implements ConnectionUiState {
  const factory _ConnectionUiState(
      {required final List<ScanDevice> scanDevices}) = _$ConnectionUiStateImpl;

  @override
  List<ScanDevice> get scanDevices;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionUiStateImplCopyWith<_$ConnectionUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
