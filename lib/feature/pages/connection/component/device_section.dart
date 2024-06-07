import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/yaru.dart';


class DeviceSection extends ConsumerStatefulWidget {
  const DeviceSection({
    super.key,
    required this.item,
    required this.onSelected,
  });

  final ScanUiModel item;
  final Function(ScanUiModel) onSelected;

  @override
  ConsumerState createState() => _DeviceSectionState();
}

class _DeviceSectionState extends ConsumerState<DeviceSection> {
  late final ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: widget.item.isExpanded);
    _controller.addListener(() => widget.onSelected.call(widget.item.copyWith(isExpanded: _controller.expanded)));
  }

  @override
  void didUpdateWidget(covariant DeviceSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.isExpanded != widget.item.isExpanded) {
      Log.d(":::----------------------------------------------");
      Log.d(":::old... " + oldWidget.item.toString());
      Log.d(":::_controller... " + _controller.toString() + " widget... " + widget.item.toString());
      Log.d(":::----------------------------------------------");
      _controller.expanded = widget.item.isExpanded;
    }
  }

  @override
  void dispose() {
    Log.e("::dispose... device Section");
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    buildItem(String label) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(label),
      );
    }

    buildList() {
      return Column(
        children: <Widget>[
          for (var i in [1, 2, 3, 4]) buildItem("Item ${i}"),
        ],
      );
    }

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
                hasIcon: false,
              ),
              header: Container(
                color: _getDeviceStateAndExpansionColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  const Gap(15),
                  SizedBox.square(dimension: 70, child: Assets.icons.iconWave.image()),
                  Expanded(
                    child: Text(
                      widget.item.model.deviceName,
                      style: WaveTextStyles.listTitle1.copyWith(color: _getDeviceStateColor),
                    ).marginOnly(bottom: 4),
                  ),
                  _getDeviceStateIcon,
                  const Gap(15),
                ]),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Color get _getDeviceStateAndExpansionColor {
    if (widget.item.status == ConnectionStatus.connected || widget.item.isExpanded) {
      return YaruColors.kubuntuBlue;
    } else {
      return YaruColors.selectBarNormalColor;
    }
  }

  Color get _getDeviceStateColor {
    switch (widget.item.status) {
      case ConnectionStatus.connected:
        return Colors.white;
      case ConnectionStatus.connecting:
      case ConnectionStatus.disconnected:
        return YaruColors.coolGrey;
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
}
