import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_event.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/alignment_view.dart';
import 'package:wave_desktop_installer/feature/widget/common_guide_button.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/feature/widget/size/size_common.dart';
import 'package:wave_desktop_installer/l10n/l10n.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/widgets.dart';

import '../../../utils/screen_util.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> with SingleTickerProviderStateMixin {
  final _viewModel = getIt<SettingViewModel>();
  final _rootViewModel = getIt<MainViewModel>();
  final _controller = WebviewController();
  bool initializeError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel.checkConnection();
    _viewModel.subscribeToStatuses();
    _viewModel.subscribeToMessages();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0, // 시작 투명도
      end: 1.0, // 끝 투명도
    ).animate(_animationController);

    initPlatformState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    try {
      Log.d('initPlatformState');
      await _controller.initialize();

      _controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      });

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('http://192.168.8.1:8080/wave_stream.html');

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      realLog.error('Assemble WebView: $e');
      setState(() {
        initializeError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
        body: Full(
      child: Column(
        children: [
          const Gap(54),
          const Text('WAVE Alignment Setting', style: WaveTextStyles.headline4Bold),
          _viewModel.settingUiEvent.ui(builder: (context, state) {
            if (!state.hasData || state.data.isNullOrEmpty) {
              return const SizedBox(width: double.infinity);
            }
            if (state.data is DeviceNotConnected) {
              return CommonGuideButton.notConnectGuide(
                onTap: () => _rootViewModel.navigateToConnectionPage(),
              );
            } else if (state.data is DeviceConnected) {
              _animationController.forward();
              return Flexible(
                child: Column(
                  children: [
                    const Gap(36),
                    Text(
                      l10n.waveToolsAlignmentSettingText02,
                      style: WaveTextStyles.headline5,
                      textAlign: TextAlign.center,
                    ),
                    Expanded(child: _buildWebView()),
                  ],
                ),
              );
            } else if (state.data is CameraLoading) {
              return const Expanded(child: Center(child: SpinKitFadingCircle.large(label: '')));
            }
            return const SizedBox(width: double.infinity);
          }),
        ],
      ),
    ));
  }

  Widget _buildWebView() {
    if (!_controller.value.isInitialized) {
      return const SizedBox.shrink();
    } else {
      return initializeError
          ? const FirmwareErrorSection(errorCode: ErrorCode.undefinedErrorCode)
          : Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                      offset: const Offset(0, -10), // 원하는 offset 값을 설정하세요.
                      child: FullHeight(
                        child: Stack(
                          children: [
                            Webview(_controller),
                          ],
                        ),
                      )),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 640,
                          maxHeight: 480,
                        ),
                        child: AspectRatio(
                          aspectRatio: 640 / 480,
                          child: Container(
                            padding: const EdgeInsets.only(top: 30),
                            color: Colors.black.withOpacity(0.2),
                            child: CustomPaint(
                              painter: AlignmentView(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 640,
                          maxHeight: 480,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          width: double.infinity,
                          child: _viewModel.settingUiState.ui(builder: (context, state) {
                            if (!state.hasData || state.data.isNullOrEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                YaruCheckButton(
                                  title: const Text('Tilt', style: WaveTextStyles.body1Bold),
                                  value: state.data!.isTiltAngle,
                                  onChanged: (v) {},
                                  tristate: true,
                                ),
                                YaruCheckButton(
                                  title: const Text('Roll', style: WaveTextStyles.body1Bold),
                                  value: state.data!.isRollAngle,
                                  onChanged: (v) {},
                                  tristate: true,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
    }
  }
}
