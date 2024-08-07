// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CameraUiState {
  Heartbeat get heartbeat => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CameraUiStateCopyWith<CameraUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraUiStateCopyWith<$Res> {
  factory $CameraUiStateCopyWith(
          CameraUiState value, $Res Function(CameraUiState) then) =
      _$CameraUiStateCopyWithImpl<$Res, CameraUiState>;
  @useResult
  $Res call({Heartbeat heartbeat});

  $HeartbeatCopyWith<$Res> get heartbeat;
}

/// @nodoc
class _$CameraUiStateCopyWithImpl<$Res, $Val extends CameraUiState>
    implements $CameraUiStateCopyWith<$Res> {
  _$CameraUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartbeat = null,
  }) {
    return _then(_value.copyWith(
      heartbeat: null == heartbeat
          ? _value.heartbeat
          : heartbeat // ignore: cast_nullable_to_non_nullable
              as Heartbeat,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HeartbeatCopyWith<$Res> get heartbeat {
    return $HeartbeatCopyWith<$Res>(_value.heartbeat, (value) {
      return _then(_value.copyWith(heartbeat: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CameraUiStateImplCopyWith<$Res>
    implements $CameraUiStateCopyWith<$Res> {
  factory _$$CameraUiStateImplCopyWith(
          _$CameraUiStateImpl value, $Res Function(_$CameraUiStateImpl) then) =
      __$$CameraUiStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Heartbeat heartbeat});

  @override
  $HeartbeatCopyWith<$Res> get heartbeat;
}

/// @nodoc
class __$$CameraUiStateImplCopyWithImpl<$Res>
    extends _$CameraUiStateCopyWithImpl<$Res, _$CameraUiStateImpl>
    implements _$$CameraUiStateImplCopyWith<$Res> {
  __$$CameraUiStateImplCopyWithImpl(
      _$CameraUiStateImpl _value, $Res Function(_$CameraUiStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartbeat = null,
  }) {
    return _then(_$CameraUiStateImpl(
      heartbeat: null == heartbeat
          ? _value.heartbeat
          : heartbeat // ignore: cast_nullable_to_non_nullable
              as Heartbeat,
    ));
  }
}

/// @nodoc

class _$CameraUiStateImpl implements _CameraUiState {
  const _$CameraUiStateImpl({required this.heartbeat});

  @override
  final Heartbeat heartbeat;

  @override
  String toString() {
    return 'CameraUiState(heartbeat: $heartbeat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraUiStateImpl &&
            (identical(other.heartbeat, heartbeat) ||
                other.heartbeat == heartbeat));
  }

  @override
  int get hashCode => Object.hash(runtimeType, heartbeat);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraUiStateImplCopyWith<_$CameraUiStateImpl> get copyWith =>
      __$$CameraUiStateImplCopyWithImpl<_$CameraUiStateImpl>(this, _$identity);
}

abstract class _CameraUiState implements CameraUiState {
  const factory _CameraUiState({required final Heartbeat heartbeat}) =
      _$CameraUiStateImpl;

  @override
  Heartbeat get heartbeat;
  @override
  @JsonKey(ignore: true)
  _$$CameraUiStateImplCopyWith<_$CameraUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
