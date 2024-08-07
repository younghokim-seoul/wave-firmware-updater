import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_page.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_page.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_page.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_page.dart';
import 'package:yaru/icons.dart';

class PageItem {
  const PageItem({
    required this.title,
    this.leadingBuilder,
    this.titleBuilder,
    this.actionsBuilder,
    required this.pageBuilder,
    required this.iconBuilder,
  });

  final String title;
  final WidgetBuilder? leadingBuilder;
  final WidgetBuilder? titleBuilder;
  final List<Widget> Function(BuildContext context)? actionsBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(BuildContext context, bool selected) iconBuilder;
}

final launcherRoutes = [
  PageItem(
    title: 'Sensor Connection',
    iconBuilder: (context, selected) => const Icon(YaruIcons.network_cellular_no_route),
    pageBuilder: (context) => const ConnectionPage(),
  ),
  PageItem(
    title: 'Firmware Update',
    iconBuilder: (context, selected) => const Icon(YaruIcons.update),
    pageBuilder: (context) => const FirmwareUpdatePage(),
  ),
  PageItem(
    title: 'Alignment Setting',
    iconBuilder: (context, selected) => const Icon(Icons.settings),
    pageBuilder: (context) => const SettingPage(),
  ),
];

final clientRoutes = [
  PageItem(
    title: 'Alignment Setting',
    iconBuilder: (context, selected) => const Icon(Icons.settings),
    pageBuilder: (context) => const CameraPage(),
  ),
];
