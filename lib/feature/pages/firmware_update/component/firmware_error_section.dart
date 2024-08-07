import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/feature/widget/commom_button.dart';
import 'package:wave_desktop_installer/l10n/l10n.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:yaru/theme.dart';

class FirmwareErrorSection extends ConsumerWidget {
  const FirmwareErrorSection({
    super.key,
    required this.errorCode,
    this.onRetryCallback,
  });

  final ErrorCode errorCode;
  final VoidCallback? onRetryCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      children: [
        const Gap(70),
        Assets.icons.iconWaveToolsAlert.image(),
        const Gap(62),
        Text(_getErrorComment(l10n), style: WaveTextStyles.commentHeaderBold),
        const Gap(20),
        Flexible(child: _getErrorReasonText(l10n)),
      ],
    );
  }

  String _getErrorComment(AppLocalizations l10n) {
    switch (errorCode) {
      case ErrorCode.deviceTimeout:
        return l10n.waveToolsCommonErrorFwverCheckText01;
      case ErrorCode.notFoundBinaryFile:
        return l10n.waveToolsCommonErrorFwverCheckText01;
      case ErrorCode.uploadFail:
      case ErrorCode.serverConnectFail:
        return l10n.waveToolsFirmwareUpdateText13;
      case ErrorCode.notFoundNearDevice:
        return l10n.waveToolsSensorConnectionText03;
      case ErrorCode.undefinedErrorCode:
        return 'Unknown Error';
    }
  }

  Widget _getErrorReasonText(AppLocalizations l10n) {
    switch (errorCode) {
      case ErrorCode.deviceTimeout:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textAlign: TextAlign.center,
              '${l10n.waveToolsCommonErrorFwverCheckText02}\n(${l10n.waveToolsCommonTextError} : ${errorCode.code})',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Spacer(),
            CommonButton(
              icon: Assets.icons.iconWaveToolsScan.image(),
              title: Text(
                l10n.waveToolsFirmwareUpdateText06,
                style: WaveTextStyles.buttonLarge,
              ),
              onTap: () => onRetryCallback?.call(),
            ),
            const Gap(49),
          ],
        );
      case ErrorCode.notFoundBinaryFile:
        return Text(
          textAlign: TextAlign.center,
          '${l10n.commonWavePopupFirmwareUpdateErrorText02}\n(${l10n.waveToolsCommonTextError} : ${errorCode.code})',
          style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
        );
      case ErrorCode.uploadFail:
      case ErrorCode.serverConnectFail:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textAlign: TextAlign.center,
              '${l10n.waveToolsFirmwareUpdateText04}\n(${l10n.waveToolsCommonTextError} : ${errorCode.code})',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Spacer(),
            CommonButton(
              title: Text(
                l10n.waveConfirm,
                style: WaveTextStyles.buttonLarge,
              ),
              onTap: () => onRetryCallback?.call(),
            ),
            const Gap(49),
          ],
        );
      case ErrorCode.undefinedErrorCode:
      case ErrorCode.notFoundNearDevice:
        return Text(
          l10n.waveToolsSensorConnectionText04,
          style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
        );
    }
  }
}
