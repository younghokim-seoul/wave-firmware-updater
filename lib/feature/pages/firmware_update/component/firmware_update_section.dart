import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/yaru.dart';

class ConnectionRequestSection extends ConsumerWidget {
  const ConnectionRequestSection({
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
          _buildConnectionRequestButton(),
          const Gap(38),
          const Text(
            'WAVE Tools 사용을 위해, WAVE를 연결해주세요.',
            style: WaveTextStyles.commentBold,
          ).marginOnly(bottom: 5),
        ],
      ),
    );
  }

  Widget _buildConnectionRequestButton() {
    return BounceGray(
      onTap: () => onTap.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(color: YaruColors.kubuntuBlue, borderRadius: BorderRadius.circular(100), boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0.0, 4),
            blurRadius: 4,
          ),
        ]),
        child: Row(
          children: [
            const Gap(45),
            SizedBox.square(
              dimension: 50,
              child: Assets.icons.iconWavetoolsConnection.image(),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              child: Text(
                'Connection Start',
                style: WaveTextStyles.headline4Bold.copyWith(color: Colors.white),
              ),
            )),
            const Gap(45),
          ],
        ),
      ),
    );
  }
}
