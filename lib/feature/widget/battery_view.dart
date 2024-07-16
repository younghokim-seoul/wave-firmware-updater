import 'package:flutter/material.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';

class BatteryView extends StatelessWidget {
  const BatteryView({super.key});

  @override
  Widget build(BuildContext context) {
    final _rootViewModel = getIt<MainViewModel>();
    return SizedBox.square(
      dimension: 70,
      child: Stack(
        children: [
          Positioned.fill(
            child: Assets.icons.iconBattery.image(),
          ),
          Align(
            alignment: Alignment.center,
            child: _rootViewModel.mainUiState.ui(builder: (context, state) {
              if (!state.hasData || state.data.isNullOrEmpty) {
                return const SizedBox.shrink();
              }
              return Text(
                state.data!.batteryLevel.isNullOrEmpty ? '' : '${state.data!.batteryLevel}%',
                style: WaveTextStyles.buttonMedium,
              ).marginOnly(left: 7, right: 11);
            }),
          )
        ],
      ),
    );
  }
}
