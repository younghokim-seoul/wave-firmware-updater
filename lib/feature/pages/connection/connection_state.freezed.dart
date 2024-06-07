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
  List<ScanUiModel> get scanDevices => throw _privateConstructorUsedError;

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
  $Res call({List<ScanUiModel> scanDevices});
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
              as List<ScanUiModel>,
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
  $Res call({List<ScanUiModel> scanDevices});
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
              as List<ScanUiModel>,
    ));
  }
}

/// @nodoc

class _$ConnectionUiStateImpl implements _ConnectionUiState {
  const _$ConnectionUiStateImpl({required final List<ScanUiModel> scanDevices})
      : _scanDevices = scanDevices;

  final List<ScanUiModel> _scanDevices;
  @override
  List<ScanUiModel> get scanDevices {
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
      {required final List<ScanUiModel> scanDevices}) = _$ConnectionUiStateImpl;

  @override
  List<ScanUiModel> get scanDevices;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionUiStateImplCopyWith<_$ConnectionUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ScanUiModel {
  ConnectionMode get connectionMode => throw _privateConstructorUsedError;
  ScanDevice get model => throw _privateConstructorUsedError;
  bool get isExpanded => throw _privateConstructorUsedError;
  ConnectionStatus get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScanUiModelCopyWith<ScanUiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanUiModelCopyWith<$Res> {
  factory $ScanUiModelCopyWith(
          ScanUiModel value, $Res Function(ScanUiModel) then) =
      _$ScanUiModelCopyWithImpl<$Res, ScanUiModel>;
  @useResult
  $Res call(
      {ConnectionMode connectionMode,
      ScanDevice model,
      bool isExpanded,
      ConnectionStatus status});

  $ScanDeviceCopyWith<$Res> get model;
}

/// @nodoc
class _$ScanUiModelCopyWithImpl<$Res, $Val extends ScanUiModel>
    implements $ScanUiModelCopyWith<$Res> {
  _$ScanUiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionMode = null,
    Object? model = null,
    Object? isExpanded = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      connectionMode: null == connectionMode
          ? _value.connectionMode
          : connectionMode // ignore: cast_nullable_to_non_nullable
              as ConnectionMode,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as ScanDevice,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ScanDeviceCopyWith<$Res> get model {
    return $ScanDeviceCopyWith<$Res>(_value.model, (value) {
      return _then(_value.copyWith(model: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScanUiModelImplCopyWith<$Res>
    implements $ScanUiModelCopyWith<$Res> {
  factory _$$ScanUiModelImplCopyWith(
          _$ScanUiModelImpl value, $Res Function(_$ScanUiModelImpl) then) =
      __$$ScanUiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ConnectionMode connectionMode,
      ScanDevice model,
      bool isExpanded,
      ConnectionStatus status});

  @override
  $ScanDeviceCopyWith<$Res> get model;
}

/// @nodoc
class __$$ScanUiModelImplCopyWithImpl<$Res>
    extends _$ScanUiModelCopyWithImpl<$Res, _$ScanUiModelImpl>
    implements _$$ScanUiModelImplCopyWith<$Res> {
  __$$ScanUiModelImplCopyWithImpl(
      _$ScanUiModelImpl _value, $Res Function(_$ScanUiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionMode = null,
    Object? model = null,
    Object? isExpanded = null,
    Object? status = null,
  }) {
    return _then(_$ScanUiModelImpl(
      connectionMode: null == connectionMode
          ? _value.connectionMode
          : connectionMode // ignore: cast_nullable_to_non_nullable
              as ConnectionMode,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as ScanDevice,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConnectionStatus,
    ));
  }
}

/// @nodoc

class _$ScanUiModelImpl implements _ScanUiModel {
  const _$ScanUiModelImpl(
      {required this.connectionMode,
      required this.model,
      required this.isExpanded,
      required this.status});

  @override
  final ConnectionMode connectionMode;
  @override
  final ScanDevice model;
  @override
  final bool isExpanded;
  @override
  final ConnectionStatus status;

  @override
  String toString() {
    return 'ScanUiModel(connectionMode: $connectionMode, model: $model, isExpanded: $isExpanded, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanUiModelImpl &&
            (identical(other.connectionMode, connectionMode) ||
                other.connectionMode == connectionMode) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.isExpanded, isExpanded) ||
                other.isExpanded == isExpanded) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, connectionMode, model, isExpanded, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanUiModelImplCopyWith<_$ScanUiModelImpl> get copyWith =>
      __$$ScanUiModelImplCopyWithImpl<_$ScanUiModelImpl>(this, _$identity);
}

abstract class _ScanUiModel implements ScanUiModel {
  const factory _ScanUiModel(
      {required final ConnectionMode connectionMode,
      required final ScanDevice model,
      required final bool isExpanded,
      required final ConnectionStatus status}) = _$ScanUiModelImpl;

  @override
  ConnectionMode get connectionMode;
  @override
  ScanDevice get model;
  @override
  bool get isExpanded;
  @override
  ConnectionStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$ScanUiModelImplCopyWith<_$ScanUiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
