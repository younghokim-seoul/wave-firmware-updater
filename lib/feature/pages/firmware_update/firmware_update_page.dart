import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/connection/component/scan_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/connection_request_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_complete_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_download_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_idle_section.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_event.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/firmware_update_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
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

  @override
  void initState() {
    Log.d("FirmwareUpdatePage initState!!");
    super.initState();
    _viewModel.subscribeToStatuses();
    _viewModel.checkFirmwareVersion(ref.read(connectionModeProvider));
  }

  @override
  void dispose() {
    Log.d("FirmwareUpdatePage dispose!!");
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  return ConnectionRequestSection(onTap: () {
                    Log.d("Connection Start onTap");
                    //todo 스캔화면으로 이동 필요
                  });
                }

                if (state.data is FirmwareVersionInfoRequested) {
                  return const Expanded(child: Center(child: SpinKitFadingCircle.large()));
                }

                if (state.data is FirmwareVersionInfoReceived) {
                  return FirmwareIdleSection(onInstallTap: () {
                    Log.d("onInstallTap");
                    _viewModel.installFirmware();
                  });
                }

                if (state.data is FirmwareDownloadProgress) {
                  return FirmwareDownloadSection(viewModel: _viewModel);
                }

                if (state.data is FirmwareDownloadComplete) {
                  return FirmwareCompleteSection(onTap: () {
                     _viewModel.checkFirmwareVersion(ref.watch(connectionModeProvider));
                  });
                }

                if (state.data is FirmwareErrorNotify) {
                  final errorType = (state.data as FirmwareErrorNotify).error;
                  return FirmwareErrorSection(errorType: errorType);
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
