import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

class FirmwareAlreadyLatestVersionSection extends ConsumerWidget {
  const FirmwareAlreadyLatestVersionSection({
    super.key,
    required this.currentVersion,
  });

  final String currentVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              const SizedBox(width: 480, height: 262),
              _buildInstallButton(),
            ],
          ),
          const Gap(11),
          Container(
            height: 100,
            alignment: Alignment.bottomCenter,
            child: const Text(
              '펌웨어 버전이 최신 입니다.',
              style: WaveTextStyles.commentHeaderBold,
            ),
          ),
          const Gap(15),
          Text(
            'WAVE Firmware Ver. $currentVersion',
            style: WaveTextStyles.commentBold,
          )
        ],
      ),
    );
  }

  Widget _buildInstallButton() {
    return BounceGray(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(40), boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0.0, 0.2),
            blurRadius: 4,
          ),
        ]),
        child: Assets.icons.btnFirmwareUpdateComplete.image(),
      ),
    );
  }
}
