import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:yaru/theme.dart';

enum FirmwareError {
  serverDownloadFail,
  deviceStatusWarning,
  bluetoothSlowWarning,
  firmwareDownloadFail,
}

class FirmwareErrorSection extends ConsumerWidget {
  const FirmwareErrorSection({
    super.key,
    required this.errorType,
  });

  final FirmwareError errorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Gap(70),
          Assets.icons.iconWaveToolsAlert.image(),
          const Gap(62),
          Text(_getErrorComment, style: WaveTextStyles.commentHeaderBold),
          const Gap(20),
          _getErrorDescription,
        ],
      ),
    );
  }

  String get _getErrorComment {
    switch (errorType) {
      case FirmwareError.serverDownloadFail:
        return '서버와 연결할 수 없습니다.';
      case FirmwareError.deviceStatusWarning:
        return '업데이트 시작 전에 확인해 주세요.';
      case FirmwareError.bluetoothSlowWarning:
        return 'Bluetooth 연결 상태 입니다.';
      case FirmwareError.firmwareDownloadFail:
        return '업데이트를 정상 진행하지 못했습니다.';
    }
  }

  Widget get _getErrorDescription {
    switch (errorType) {
      case FirmwareError.serverDownloadFail:
        return Column(
          children: [
            Text(
              textAlign: TextAlign.center,
              'WAVE(R1)의 연결 상태 및 네트워크 상태를 확인해주세요.\n연결 상태가 정상일 시, 고객 센터로 문의 바랍니다.',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Gap(7),
            const Text(
              '070.1234.5678',
              style: WaveTextStyles.commentBold,
            ),
          ],
        );
      case FirmwareError.deviceStatusWarning:
        return Column(
          children: [
            Text(
              '1. VISION WAVE 클라이언트를 종료 한 후에 진행해 주세요.',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Gap(2),
            Text(
              '2. WAVE 기기의 배터리 잔량이 30% 이상인지 확인해 주세요.',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Gap(2),
            const Text(
              'Wi-Fi 연결 모드로 진행하시는 것을 권장 드립니다.',
              style: WaveTextStyles.commentBold,
            ),
          ],
        );
      case FirmwareError.bluetoothSlowWarning:
        return Column(
          children: [
            Text(
              textAlign: TextAlign.center,
              'Bluetooth 연결 모드는 업데이트 진행이 매우 느릴 수 있으며\n진행 중 연결이 끊어질 시 처음부터 다시 진행해야 할 수 있습니다.',
              style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
            ),
            const Gap(2),
            const Text(
              'Wi-Fi 연결 모드로 진행하시는 것을 권장 드립니다.',
              style: WaveTextStyles.commentBold,
            ),
          ],
        );
      case FirmwareError.firmwareDownloadFail:
        return Text(
          'WAVE(R1)의 연결 상태 및 네트워크 상태를 확인해주세요.\n펌웨어 업데이트 시, WAVE(R1) 기기 연결은 Wi-Fi 연결을 권장합니다.',
          style: WaveTextStyles.commentBold.copyWith(color: YaruColors.red),
        );
    }
  }
}
