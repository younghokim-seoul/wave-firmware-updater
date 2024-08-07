import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/data/exception/response_code.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_event.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_state.dart';
import 'package:wave_desktop_installer/feature/pages/camera/camera_view_model.dart';
import 'package:wave_desktop_installer/feature/pages/firmware_update/component/firmware_error_section.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_event.dart';
import 'package:wave_desktop_installer/feature/widget/alignment_view.dart';
import 'package:wave_desktop_installer/feature/widget/loading/dot_circle.dart';
import 'package:wave_desktop_installer/l10n/l10n.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/screen_util.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/theme.dart';
import 'package:yaru/widgets.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with SingleTickerProviderStateMixin {
  final _viewModel = getIt<CameraViewModel>();
  final _controller = WebviewController();
  bool initializeError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel.startServer();
    _viewModel.checkConnection();

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
        Log.d('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      });

      _controller.onLoadError.listen((event) {
        Log.d("onLoadError: $event");
        setState(() {
          initializeError = true;
        });
      });

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('http://192.168.8.1:8080/wave_stream.html');
      if (!mounted) return;
      setState(() {
        _animationController.forward();
      });
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
        body: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          StreamBuilder<LoadingState>(
              stream: _controller.loadingState,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == LoadingState.loading) {
                  return const SizedBox.shrink();
                } else {
                  _animationController.forward();
                  return const SizedBox.shrink();
                }
              }),
          const Gap(54),
          const Text('WAVE Alignment Setting', style: WaveTextStyles.headline4Bold),
          _viewModel.cameraUiEvent.ui(builder: (context, state) {
            if (!state.hasData || state.data.isNullOrEmpty) {
              return const SizedBox(width: double.infinity);
            }
            if (state.data is CameraNotConnected) {
              return const Expanded(child: Center(child: SpinKitFadingCircle.large(label: '')));
            } else if (state.data is CameraConnected) {
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
            }
            return const SizedBox(width: double.infinity);
          }),
        ],
      ),
    ));
  }

  Widget _buildWebView() {
    if (!_controller.value.isInitialized) {
      Log.d("이니셜라이즈 실패");
      return const SizedBox.shrink();
    } else {
      return initializeError
          ? FirmwareErrorSection(
              errorCode: ErrorCode.undefinedErrorCode,
              onRetryCallback: () async {
                await _controller.loadUrl('http://192.168.8.1:8080/wave_stream.html');
                setState(() {
                  initializeError = false;
                });
              })
          : Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                      offset: const Offset(0, -10), // 원하는 offset 값을 설정하세요.
                      child: SizedBox(
                        height: getScreenHeight(context),
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
                          maxHeight: 100,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          width: double.infinity,
                          child: _viewModel.cameraUiState.ui(builder: (context, state) {
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
