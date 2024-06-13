import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/scan_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/wifi_view.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

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
    _viewModel.startScan(ConnectionMode.wifi);
  }

  @override
  void dispose() {
    _viewModel.connectionUiState.close();
    _viewModel.dispose();
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
            Gap(30),
            const Text('WAVE Sensor Connection', style: WaveTextStyles.headline4Bold),
            Gap(30),
            ScanSection(connectionViewModel: _viewModel),
            Gap(30),
            Expanded(
              child: WifiListView(
                connectionViewModel: _viewModel,
                onSelected: () {
                  Log.d('onSelected');
                },
              ),
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
              onTap: () =>  _viewModel.startScan(ref.read(connectionModeProvider)),
            ),
            const Gap(43),
          ],
        ),
      ),
    );
  }
}
