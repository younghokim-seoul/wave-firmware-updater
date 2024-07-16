import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.freezed.dart';

@freezed
class MainUiState with _$MainUiState {
  const factory MainUiState({
    required String swVersion,
    required String batteryLevel,
  }) = _MainUiState;

  factory MainUiState.initial() => const MainUiState(
        swVersion: '',
        batteryLevel: '',
      );
}
