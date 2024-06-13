import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/device_section.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';

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
        return const SizedBox.shrink();
      }
      final event = state.data;

      if (event is NearByDevicesUpdate) {
        return ListView.builder(
          itemCount: event.data.scanDevices.length,
          itemBuilder: (context, index) {
            final item = event.data.scanDevices[index];
            return DeviceSection(
              key: ValueKey(item.model.deviceName),
              item: item,
              onExpandedChanged: (item, isExpanded) =>
                  connectionViewModel.expandStateUpdate(item, isExpanded),
              onConnectionRequest: (item,status) {
                  connectionViewModel.connectWifi(item,status);
              }
            ).paddingOnly(bottom: 4);
          },
        );
      } else if (event is NearByDevicesRequested) {
        return const SpinKitFadingCircle.large();
      } else {
        return SizedBox.shrink();
      }
    });
  }
}
