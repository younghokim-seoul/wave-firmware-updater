import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/device_scan_view.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/device_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/scan_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';

import '../../widget/loading/dot_circle.dart';

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
    Log.d('ConnectionPage init');
    _viewModel.subscribeToConnection();
    _viewModel.startScan(ConnectionMode.wifi);
  }

  @override
  void dispose() {
    Log.d('ConnectionPage dispose');
    _viewModel.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.d('ConnectionPage build');
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(30),
            const Text('WAVE Sensor Connection', style: WaveTextStyles.headline4Bold),
            const Gap(30),
            ScanSection(connectionViewModel: _viewModel),
            const Gap(30),
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
              onTap: () => _viewModel.startScan(ref.read(connectionModeProvider)),
            ),
            const Gap(43),
          ],
        ),
      ),
    );
  }
}
