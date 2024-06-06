import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/page_items.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_app_bar.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

final materialAppNavigatorKeyProvider =
    Provider((ref) => GlobalKey<NavigatorState>());

final yaruPageControllerProvider =
    Provider((ref) => YaruPageController(length: routes.length));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await configureDependencies();

  settingWindow();

  runApp(const ProviderScope(child: StoreApp()));
}

void settingWindow() {
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1140, 880),
    minimumSize: Size(1140, 880), // Add this line
    maximumSize: Size(1140, 880), // Add this line
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });
}

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key});

  @override
  ConsumerState createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {


    // Future.delayed(Duration(seconds: 2), () {
    //   Log.d("delayed 2 seconds $_navigator");
    //   //여기서 인덱싱교체...
    //   ref.read(yaruPageControllerProvider)?.index = 2;
    // });

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
                Assets.icons.iconWaveTools.image(),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('WAVE Tools', style: WaveTextStyles.appBarHeader),
                    Text('VISION WAVE Tools Ver.1.0.0 - 20241022',
                        style: WaveTextStyles.subtitle1),
                  ],
                ),
              ],
            ),
            actions: [],
          ),
          body: YaruMasterDetailPage(
            navigatorKey: _navigatorKey,
            controller: ref.watch(yaruPageControllerProvider),
            breakpoint: 0,
            tileBuilder: (context, index, selected, availableWidth) {
              return YaruMasterTile(
                leading: routes[index].iconBuilder(context, selected),
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
