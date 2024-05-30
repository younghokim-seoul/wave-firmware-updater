import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_view_model.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {

  final _viewModel = getIt<SettingViewModel>();


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}
