import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/sliding_control/widget.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:yaru/theme.dart';

class ScanSection extends ConsumerWidget {
  const ScanSection({super.key, required this.connectionViewModel});

  final ConnectionViewModel connectionViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomSlidingSegmentedControl<ConnectionMode>(
      initialValue: ConnectionMode.wifi,
      isStretch: true,
      children: const {
        ConnectionMode.wifi: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              Expanded(
                child: Center(
                  child: Text(
                    'Wi-Fi',
                    style: WaveTextStyles.body1,
                  ),
                ),
              )
            ],
          ),
        ),
        ConnectionMode.bluetooth: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Bluetooth',
                    style: WaveTextStyles.body1,
                  ),
                ),
              ),
              Icon(Icons.bluetooth, color: Colors.white),
            ],
          ),
        ),
      },
      decoration: BoxDecoration(
        color: YaruColors.selectBarNormalColor,
        borderRadius: BorderRadius.circular(50),
      ),
      thumbDecoration: BoxDecoration(
        color: YaruColors.selectBarHighlightColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 4.0,
            spreadRadius: 1.0,
            offset: const Offset(
              0.0,
              2.0,
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      onValueChanged: (v) {
        Log.d("Selected $v");
        connectionViewModel.startScan(v);
      },
    );
  }
}
