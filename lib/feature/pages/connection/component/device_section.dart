import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/yaru.dart';

const statusTitles = {
  ConnectionStatus.connected: '연결 끊기',
  ConnectionStatus.connecting: '연결 중...',
  ConnectionStatus.disconnected: '연결',
};

class DeviceSection extends ConsumerStatefulWidget {
  const DeviceSection({
    super.key,
    required this.item,
    required this.onExpandedChanged,
    required this.onConnectionRequest,
  });

  final ScanUiModel item;
  final Function(ScanUiModel, bool) onExpandedChanged;
  final Function(ConnectionStatus) onConnectionRequest;

  @override
  ConsumerState createState() => _DeviceSectionState();
}

class _DeviceSectionState extends ConsumerState<DeviceSection> {
  late bool isExpanded = widget.item.isExpanded;
  late ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: isExpanded);
    _controller.addListener(() {
      setState(() {
        isExpanded = !isExpanded;
      });
      widget.onExpandedChanged.call(widget.item, isExpanded);
    });
  }

  @override
  void didUpdateWidget(covariant DeviceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isExpanded != isExpanded) {
      _controller.toggle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: _controller,
      child: ScrollOnExpand(
        child: Column(
          children: [
            ExpandablePanel(
              theme: const ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToExpand: true,
                tapBodyToCollapse: true,
                hasIcon: false, crossFadePoint: 0
              ),
              header: Container(
                color: _getDeviceStateAndExpansionColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  const Gap(15),
                  SizedBox.square(
                      dimension: 70, child: Assets.icons.iconWave.image()),
                  Expanded(
                    child: Text(
                      widget.item.model.deviceName,
                      style: WaveTextStyles.listTitle1
                          .copyWith(color: _getDeviceStateColor),
                    ).marginOnly(bottom: 4),
                  ),
                  _getDeviceStateIcon,
                  const Gap(15),
                ]),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: _getConnectionControlButton,
            ),
          ],
        ),
      ),
    );
  }

  Color get _getDeviceStateAndExpansionColor {
    if (widget.item.status == ConnectionStatus.connected ||
        widget.item.isExpanded) {
      return YaruColors.kubuntuBlue;
    } else {
      return YaruColors.selectBarNormalColor;
    }
  }

  Color get _getDeviceStateColor {
    if(widget.item.isExpanded){
      switch (widget.item.status) {
        case ConnectionStatus.connected:
          return Colors.white;
        case ConnectionStatus.connecting:
        case ConnectionStatus.disconnected:
          return YaruColors.coolGrey;
      }
    }else{
      return Colors.white;
    }

  }

  Widget get _getDeviceStateIcon {
    if (widget.item.connectionMode == ConnectionMode.wifi) {
      switch (widget.item.status) {
        case ConnectionStatus.connected:
          return Assets.icons.iconWifiEnable.image();
        case ConnectionStatus.connecting:
          return const SpinKitFadingCircle.medium();
        case ConnectionStatus.disconnected:
          return Assets.icons.iconWifiDisable.image();
      }
    } else {
      switch (widget.item.status) {
        case ConnectionStatus.connected:
          return Assets.icons.iconBluetoothEnable.image();
        case ConnectionStatus.connecting:
          return const SpinKitFadingCircle.medium();
        case ConnectionStatus.disconnected:
          return Assets.icons.iconBluetoothDisable.image();
      }
    }
  }

  Widget get _getConnectionControlButton {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: YaruColors.kubuntuBlue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BounceGray(
            child: Container(
              width: 160,
              decoration: const BoxDecoration(
                  color: YaruColors.selectBarHighlightColor),
              child: Text(
                statusTitles[widget.item.status] ?? '',
                style: WaveTextStyles.body1,
                textAlign: TextAlign.center,
              ).paddingSymmetric(vertical: 8),
            ),
            onTap: () => widget.onConnectionRequest.call(widget.item.status),
          )
        ],
      ).paddingSymmetric(vertical: 10, horizontal: 12),
    );
  }
}
