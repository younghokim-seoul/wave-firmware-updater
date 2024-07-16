// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MainUiState {
  String get swVersion => throw _privateConstructorUsedError;
  String get batteryLevel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MainUiStateCopyWith<MainUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainUiStateCopyWith<$Res> {
  factory $MainUiStateCopyWith(
          MainUiState value, $Res Function(MainUiState) then) =
      _$MainUiStateCopyWithImpl<$Res, MainUiState>;
  @useResult
  $Res call({String swVersion, String batteryLevel});
}

/// @nodoc
class _$MainUiStateCopyWithImpl<$Res, $Val extends MainUiState>
    implements $MainUiStateCopyWith<$Res> {
  _$MainUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swVersion = null,
    Object? batteryLevel = null,
  }) {
    return _then(_value.copyWith(
      swVersion: null == swVersion
          ? _value.swVersion
          : swVersion // ignore: cast_nullable_to_non_nullable
              as String,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MainUiStateImplCopyWith<$Res>
    implements $MainUiStateCopyWith<$Res> {
  factory _$$MainUiStateImplCopyWith(
          _$MainUiStateImpl value, $Res Function(_$MainUiStateImpl) then) =
      __$$MainUiStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String swVersion, String batteryLevel});
}

/// @nodoc
class __$$MainUiStateImplCopyWithImpl<$Res>
    extends _$MainUiStateCopyWithImpl<$Res, _$MainUiStateImpl>
    implements _$$MainUiStateImplCopyWith<$Res> {
  __$$MainUiStateImplCopyWithImpl(
      _$MainUiStateImpl _value, $Res Function(_$MainUiStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swVersion = null,
    Object? batteryLevel = null,
  }) {
    return _then(_$MainUiStateImpl(
      swVersion: null == swVersion
          ? _value.swVersion
          : swVersion // ignore: cast_nullable_to_non_nullable
              as String,
      batteryLevel: null == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MainUiStateImpl implements _MainUiState {
  const _$MainUiStateImpl(
      {required this.swVersion, required this.batteryLevel});

  @override
  final String swVersion;
  @override
  final String batteryLevel;

  @override
  String toString() {
    return 'MainUiState(swVersion: $swVersion, batteryLevel: $batteryLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainUiStateImpl &&
            (identical(other.swVersion, swVersion) ||
                other.swVersion == swVersion) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, swVersion, batteryLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MainUiStateImplCopyWith<_$MainUiStateImpl> get copyWith =>
      __$$MainUiStateImplCopyWithImpl<_$MainUiStateImpl>(this, _$identity);
}

abstract class _MainUiState implements MainUiState {
  const factory _MainUiState(
      {required final String swVersion,
      required final String batteryLevel}) = _$MainUiStateImpl;

  @override
  String get swVersion;
  @override
  String get batteryLevel;
  @override
  @JsonKey(ignore: true)
  _$$MainUiStateImplCopyWith<_$MainUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
