import 'package:flutter/material.dart';
import 'package:wave_desktop_installer/feature/widget/common_guide_button.dart';

class ConnectionRequestSection extends StatelessWidget {
  const ConnectionRequestSection({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CommonGuideButton.notConnectGuide(onTap: () => onTap.call());
  }
}
