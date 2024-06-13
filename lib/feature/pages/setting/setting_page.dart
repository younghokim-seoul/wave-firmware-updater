import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_state.dart';
import 'package:wave_desktop_installer/feature/pages/setting/setting_view_model.dart';
import 'package:wave_desktop_installer/feature/widget/alignment_view.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/theme.dart';
import 'package:yaru/widgets.dart';

// final webClientProvider = Provider.autoDispose<WebviewController>((ref) {
//   return WebviewController();
// });
//
// final alignmentProvider = StreamProvider.autoDispose<LoadingState>((ref) async* {
//   final webClient = ref.watch(webClientProvider);
//
//   if (!webClient.value.isInitialized) {
//     Log.d('webClient not isInitialized ->  Initializing Call');
//     await initializeWebClient(webClient);
//   }
//   yield* webClient.loadingState;
// });
//
// Future<void> initializeWebClient(WebviewController webClient) async {
//   await webClient.initialize();
//   await webClient.setPopupWindowPolicy(WebviewPopupWindowPolicy.allow);
//   await webClient.loadUrl('http://192.168.8.1:8080/wave_stream.html');
// }

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> with SingleTickerProviderStateMixin {
  final _viewModel = getIt<SettingViewModel>();

  final _controller = WebviewController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Log.d('SettingPage initState');

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
    Log.d('SettingPage disposed');
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

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
        // body: ref.watch(alignmentProvider).when(
        //       loading: () {
        //         Log.d('WebView loading');
        //         return const YaruLinearProgressIndicator(
        //           color: YaruColors.blue,
        //         );
        //       },
        //       error: (err, stack) => ErrorWidget(err),
        //       data: (state) {
        //         Log.d('WebView state: $state');
        //         if (state == LoadingState.none || state == LoadingState.loading) {
        //           return const YaruLinearProgressIndicator(
        //             color: YaruColors.blue
        //           );
        //         }
        //         _animationController.forward();
        //'WebView LoadSuccess!!!!!!!!!!!!!!! ${_controller.value.isInitialized}'ody: _buildWebView(),
      body: _buildWebView(),
        );
  }

  Widget _buildWebView() {
    Log.d('WebView LoadSuccess!!!!!!!!!!!!!!! ${_controller.value.isInitialized}');

    if (!_controller.value.isInitialized) {
      return const SizedBox.shrink();
    } else {
      Log.d("webview real load");
      _animationController.forward();
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
                  return SizedBox.shrink();
                }
              }),
        ],
      );
    }
  }
}
