import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/device_scan_view.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  final _viewModel = getIt<ConnectionViewModel>();


  @override
  void initState() {
    super.initState();
    _viewModel.startScan();


    Future.delayed(const Duration(seconds: 1), () {
      _viewModel.subscribeToConnection();
    });
  }


  @override
  void dispose() {
    _viewModel.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(54),
            const Text('WAVE Sensor Connection', style: WaveTextStyles.headline4Bold),
            const Gap(60),
            Expanded(
              child: DeviceScanView(connectionViewModel: _viewModel),
            )
          ],
        ),
      ),
      bottomNavigationBar: IntrinsicHeight(
        child: Column(
          children: [
            const Gap(12),
            CommonButton(
              icon: Assets.icons.iconWaveToolsScan.image(),
              title: const Text(
                'Rescan Nearby Devices',
                style: WaveTextStyles.buttonLarge,
              ),
              onTap: () => _viewModel.startScan(),
            ),
            const Gap(43),
          ],
        ),
      ),
    );
  }
}
