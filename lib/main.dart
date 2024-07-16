import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/page_items.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_action_button.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_app_bar.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import 'feature/widget/battery_view.dart';

final materialAppNavigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

final yaruPageControllerProvider = Provider((ref) => YaruPageController(length: routes.length));

final updateAlertStateProvider = StateProvider.autoDispose<bool>((ref) => false);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await configureDependencies();

  await settingWindow();

  runApp(const ProviderScope(child: StoreApp()));
}

Future<void> settingWindow() async {
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1140, 880),
    minimumSize: Size(1140, 880),
    // Add this line
    maximumSize: Size(1140, 880),
    // Add this line
    center: true,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions);
}

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key});

  @override
  ConsumerState createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  final _viewModel = getIt<MainViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.subscribeToMessages();
    _viewModel.navigateUiEvent.stream.listen((event) {
      if (event is MoveToConnectionPageEvent) {
        ref.watch(yaruPageControllerProvider).index = 0;
      }
    });

    _viewModel.versionState.stream.listen((data) {
      Log.d('${data.item1} | ${data.item2}');
      ref.read(updateAlertStateProvider.notifier).state = data.item3;
    });
  }

  @override
  dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YaruTheme(builder: (context, yaru, child) {
      return MaterialApp(
        title: 'Wave Tool Installer',
        debugShowCheckedModeBanner: false,
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        navigatorKey: ref.watch(materialAppNavigatorKeyProvider),
        home: Scaffold(
          appBar: CustomAppBar(
            title: 'Wave Tool Installer',
            leading: Row(
              children: [
                const Gap(10),
                Assets.icons.iconWaveTools.image(),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('WAVE Tools', style: WaveTextStyles.appBarHeader),
                    Text('VISION WAVE Tools Ver.1.0.0 - 20241022', style: WaveTextStyles.subtitle1),
                  ],
                ),
              ],
            ),
            actions: [
              const BatteryView(),
              const Gap(30),
              CustomActionButton.reduction(onTap: () {
                windowManager.minimize();
              }),
              const Gap(20),
              CustomActionButton.close(onTap: () {
                windowManager.close();
              }),
              const Gap(20),
            ],
          ),
          body: YaruMasterDetailPage(
            navigatorKey: _navigatorKey,
            controller: ref.watch(yaruPageControllerProvider),
            breakpoint: 0,
            tileBuilder: (context, index, selected, availableWidth) {
              final state = ref.watch(updateAlertStateProvider);
              return YaruMasterTile(
                leading: routes[index].iconBuilder(context, selected),
                index: index,
                isAvailableUpdate: state,
                title: Text(
                  routes[index].title,
                  style: WaveTextStyles.sideMenuTitle,
                ).paddingSymmetric(horizontal: 30),
              );
            },
            pageBuilder: (context, index) => routes[index].pageBuilder(context),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: YaruColors.titleBarLight,
              boxShadow: null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 36),
            ),
          ),
        ),
      );
    });
  }
}
