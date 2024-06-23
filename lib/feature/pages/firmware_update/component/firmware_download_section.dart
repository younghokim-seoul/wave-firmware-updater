import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/data/fwupd/fwupd_service.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:yaru/theme.dart';

import '../../../../utils/dev_log.dart';

class FirmwareDownloadSection extends ConsumerWidget {
  const FirmwareDownloadSection({
    super.key,
    required this.viewModel,
  });

  final FirmwareUpdateViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 480, height: 262, child: Assets.icons.btnFirmwareUpdateDownloading.image()),
          Container(
            height: 100,
            alignment: Alignment.bottomCenter,
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                ColorizeAnimatedText(
                  '업데이트 파일을 확인하고 있습니다.',
                  textStyle: WaveTextStyles.commentHeaderBold,
                  colors: [YaruColors.commentTextLight, Colors.white],
                ),
              ],
            ),
          ),
          const Gap(20),
          _buildDownloadProgressBar(),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 160),
      child: viewModel.percentage.ui(
        builder: (context, state) {
          double originPercent = state.data != null ? state.data! : 0.0;
          double dividePercent = originPercent / 100;

          Log.d('dividePercent: $dividePercent');
          return LinearPercentIndicator(
            lineHeight: 30,
            center: Text('${originPercent.floor()}%', style: WaveTextStyles.subtitle2Bold.copyWith(color: Colors.white)),
            progressColor: YaruColors.blue,
            percent: dividePercent,
            animation: false,
            animationDuration: 1400,
          );
        },
      ),
    );
  }
}
