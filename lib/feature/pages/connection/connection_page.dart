import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/connection_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/scan_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/wifi_view.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:gap/gap.dart';
import 'package:yaru/widgets.dart';

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
    // _viewModel.connectWifi('192.168.8.1', 4999);
  }

  @override
  void dispose() {
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
            // ConnectionSection(),
            Expanded(
              child: WifiListView(
                connectionViewModel: _viewModel,
                onSelected: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
