import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_event.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/alignment_view.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_app_bar.dart';
import 'package:wave_desktop_installer/feature/widget/common_guide_button.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/theme.dart';
import 'package:yaru/widgets.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> with SingleTickerProviderStateMixin {
  final _viewModel = getIt<SettingViewModel>();
  final _rootViewModel = getIt<MainViewModel>();
  final _controller = WebviewController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel.checkConnection();
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
      Log.e('Error creating WebView: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(54),
          const Text('WAVE Alignment Setting', style: WaveTextStyles.headline4Bold),
          _viewModel.settingUiEvent.ui(builder: (context, state) {
            if (!state.hasData || state.data.isNullOrEmpty) {
              return const SizedBox.shrink();
            }

            if (state.data is DeviceNotConnected) {
              return CommonGuideButton.onlyWifiGuide(
                onTap: () => _rootViewModel.navigateToConnectionPage(),
              );
            } else if (state.data is DeviceConnected) {
              return Expanded(child: _buildWebView());
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    Log.d('WebView LoadSuccess!!!!!!!!!!!!!!! ${_controller.value.isInitialized}');

    if (!_controller.value.isInitialized) {
      return const SizedBox.shrink();
    } else {
      Log.d("webview real load");
      return Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Webview(_controller),
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
                  child: AspectRatio(
                    aspectRatio: 640 / 480,
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
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
                    child: _viewModel.settingUiState.ui(builder: (context, state) {
                      if (!state.hasData || state.data.isNullOrEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          YaruCheckButton(
                            title: const Text('Tilt', style: TextStyle(color: Colors.white)),
                            value: state.data!.isTiltAngle,
                            onChanged: (v) {},
                            tristate: true,
                          ),
                          YaruCheckButton(
                            title: const Text('Roll', style: TextStyle(color: Colors.white)),
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
          StreamBuilder<LoadingState>(
              stream: _controller.loadingState,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == LoadingState.loading) {
                  return const YaruLinearProgressIndicator(color: YaruColors.blue);
                } else {
                  _animationController.forward();
                  return const SizedBox.shrink();
                }
              }),
        ],
      );
    }
  }
}
