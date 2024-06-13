import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

class FirmwareCompleteSection extends ConsumerWidget {
  const FirmwareCompleteSection({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 480, height: 262, child: Assets.icons.btnFirmwareUpdateComplete.image()),
          const Gap(38),
          const Text(
            '업데이트가 완료되어 WAVE(R1)를 재시작 합니다.',
            style: WaveTextStyles.commentHeaderBold,
          ),
          const Gap(44),
          CommonButton(
            title: Text(
              '확인',
              style: WaveTextStyles.buttonLarge,
            ),
            onTap: () => onTap.call(),
          )
        ],
      ),
    );
  }
}
