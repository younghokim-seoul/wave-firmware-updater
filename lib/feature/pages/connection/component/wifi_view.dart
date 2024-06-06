import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:yaru/yaru.dart';

class WifiListView extends ConsumerWidget {
  const WifiListView({
    super.key,
    required this.connectionViewModel,
    required this.onSelected,
  });

  final VoidCallback onSelected;
  final ConnectionViewModel connectionViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return connectionViewModel.connectionUiState.ui(builder: (context, state) {
      if (!state.hasData || state.data.isNullOrEmpty) {
        return SpinKitFadingCircle(color: Colors.white);
      }
      return YaruSection(
          child: ListView.builder(
        itemCount: state.data!.scanDevices.length,
        itemBuilder: (context, index) {
          final model = state.data!.scanDevices[index];
          return YaruTile(
            key: ValueKey(index),
            leading: const SizedBox(width: 32, child: Icon(YaruIcons.network_wireless)),
            title: Text(model.deviceName),
          ).paddingOnly(top: 8,bottom: 8);
        },
      ));
    });
  }
}
