import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

class FirmwareIdleSection extends ConsumerWidget {
  const FirmwareIdleSection({
    super.key,
    required this.onInstallTap,
  });

  final VoidCallback onInstallTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              const SizedBox(width: 480,height: 262),
              _buildInstallButton(),
            ],
          ),
          const Gap(38),
          const Text(
            '최신 버전으로 펌웨어 업데이트를 진행하세요.',
            style: WaveTextStyles.commentHeaderBold,
          ),
          const Gap(20),
          const Text(
            'WAVE Firmware Ver. 0.55.12.194',
            style: WaveTextStyles.commentBold,
          )
        ],
      ),
    );
  }

  Widget _buildInstallButton() {
    return BounceGray(
      onTap: () => onInstallTap.call(),
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(40), boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0.0, 0.2),
            blurRadius: 4,
          ),
        ]),
        child: Assets.icons.btnFirmwareUpdateStart.image(),
      ),
    );
  }
}
