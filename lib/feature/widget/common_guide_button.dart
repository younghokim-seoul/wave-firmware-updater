import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/yaru.dart';

class CommonGuideButton extends ConsumerWidget {
  const CommonGuideButton({
    required this.icon,
    required this.buttonText,
    required this.guideText,
    required this.onTap,
    super.key,
  });

  CommonGuideButton.notConnectGuide({
    required this.onTap,
    super.key,
  })  : icon = Assets.icons.iconWavetoolsConnection.image(),
        buttonText = 'Connection Start',
        guideText = 'WAVE Tools 사용을 위해, WAVE를 연결해주세요.';

  CommonGuideButton.scanGuide({
    required this.onTap,
    super.key,
  })  : icon = Assets.icons.iconWavetoolsConnection.image(),
        buttonText = 'Connection Start',
        guideText = 'WAVE Tools 사용을 위해, Launch Monitor를 연결해주세요.';

  CommonGuideButton.onlyWifiGuide({
    required this.onTap,
    super.key,
  })  : icon = Assets.icons.iconWaveToolsWifi01.image(),
        buttonText = 'Wifi Connection Only',
        guideText = 'WAVE Tools 사용을 위해, WAVE를 연결해주세요.\nAlignment 설정은 Wi-Fi연결 모드에서 사용할 수 있습니다.';

  final VoidCallback onTap;
  final String guideText;
  final String buttonText;
  final Image icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConnectionRequestButton().paddingSymmetric(horizontal: 129),
          const Gap(38),
          Text(
            guideText,
            textAlign: TextAlign.center,
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
            offset: const Offset(0.0, 4),
            blurRadius: 4,
          ),
        ]),
        child: Row(
          children: [
            const Gap(45),
            SizedBox.square(
              dimension: 70,
              child: icon,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: WaveTextStyles.headline4Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
            const Gap(60),
          ],
        ),
      ),
    );
  }
}
