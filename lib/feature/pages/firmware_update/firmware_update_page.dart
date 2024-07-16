import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/scan_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/connection_request_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_already_latest_version_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_complete_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_download_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_idle_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_event.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/screen_util.dart';

class FirmwareUpdatePage extends ConsumerStatefulWidget {
  const FirmwareUpdatePage({super.key});

  @override
  ConsumerState createState() => _FirmwareUpdatePageState();
}

class _FirmwareUpdatePageState extends ConsumerState<FirmwareUpdatePage> {
  final _viewModel = getIt<FirmwareUpdateViewModel>();
  final _rootViewModel = getIt<MainViewModel>();

  @override
  void initState() {
    Log.d("화면 진입한데이!!!!!!!!!!!!!!!!!!!!!!");
    super.initState();
    _viewModel.setConnectionMode(ref.read(connectionModeProvider));
    _viewModel.subscribeToStatuses();
    _viewModel.checkFirmwareVersion();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: getScreenWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(54),
            const Text('WAVE Firmware Update', style: WaveTextStyles.headline4Bold),
            _viewModel.firmwareUiEvent.ui(
              builder: (context, state) {
                if (!state.hasData || state.data.isNullOrEmpty) {
                  return const SizedBox.shrink();
                }

                if (state.data is DeviceNotConnected) {
                  return ConnectionRequestSection(onTap: () => _rootViewModel.navigateToConnectionPage());
                }

                if (state.data is FirmwareVersionInfoRequested) {
                  return const Expanded(
                      child: Center(
                          child: SpinKitFadingCircle.large(
                    label: '업데이트 확인 중...',
                  )));
                }

                if (state.data is FirmwareVersionInfoReceived) {
                  final data = state.data as FirmwareVersionInfoReceived;
                  return FirmwareIdleSection(
                      currentVersion: data.currentVersion, onInstallTap: () => _viewModel.installFirmware());
                }

                if (state.data is FirmwareDownloadProgress) {
                  return FirmwareDownloadSection(viewModel: _viewModel);
                }

                if (state.data is FirmwareAlreadyLatestVersion) {
                  return FirmwareAlreadyLatestVersionSection(
                    currentVersion: (state.data as FirmwareAlreadyLatestVersion).currentVersion,
                  );
                }

                if (state.data is FirmwareErrorNotify) {
                  final data = (state.data as FirmwareErrorNotify);
                  return Flexible(
                    child: FirmwareErrorSection(
                      errorType: data.error,
                      errorCode: data.code,
                      onRetryCallback: () {
                        _viewModel.checkFirmwareVersion();
                      },
                    ),
                  );
                }

                if (state.data is FirmwareDownloadComplete) {
                  return FirmwareCompleteSection(onTap: () => _viewModel.checkFirmwareVersion());
                }

                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
