import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/l10n/l10n.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

class FirmwareCompleteSection extends ConsumerWidget {
  const FirmwareCompleteSection({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 480, height: 262, child: Assets.icons.btnFirmwareUpdateComplete.image()),
          const Gap(38),
          Text(
            l10n.waveToolsFirmwareUpdateText11,
            style: WaveTextStyles.commentHeaderBold,
            textAlign: TextAlign.center,
          ),
          const Gap(44),
          CommonButton(
            title: Text(
              l10n.waveConfirm,
              style: WaveTextStyles.buttonLarge,
            ),
            onTap: () => onTap.call(),
          )
        ],
      ),
    );
  }
}
