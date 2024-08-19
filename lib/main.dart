import 'dart:async';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this line
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:wave_desktop_installer/assets/assets.gen.dart';
import 'package:wave_desktop_installer/di/configurations.dart';
import 'package:wave_desktop_installer/feature/page_items.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_action_button.dart';
import 'package:wave_desktop_installer/feature/widget/appbar/custom_app_bar.dart';
import 'package:wave_desktop_installer/l10n/l10n.dart';
import 'package:wave_desktop_installer/main_view_model.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/real_log.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import 'feature/widget/battery_view.dart';

final materialAppNavigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

final updateAlertStateProvider = StateProvider.autoDispose<bool>((ref) => false);

const windowSize = Size(1140, 880);

final realLog = Logger('b2c_wave_tools');

enum LaunchMode { launcher, client }

void main(List<String> executableArguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await configureDependencies();
  await setupRealLogger();
  await settingWindow();
  setupGlobalErrorHandler();
  runApp(
    ProviderScope(
      child: StoreApp(
        executableArguments: executableArguments,
      ),
    ),
  );
}

setupGlobalErrorHandler() {
  PlatformDispatcher.instance.onError = (error, stack) {
    realLog.error('outside flutter error handle: $error', error, stack);
    return true;
  };
}

Future<void> setupRealLogger() async {
  final appDataPath = p.dirname(Platform.resolvedExecutable);
  final parentDirPath = p.join(appDataPath, '..', '..');
  Log.d("appDataPath $appDataPath");
  Log.d("parentDirPath $parentDirPath");
  final binaryName = p.basenameWithoutExtension(Platform.resolvedExecutable);
  Log.d("binaryName $binaryName");
  Logger.setup(
    path: p.join(
      parentDirPath,
      binaryName,
      '$binaryName.log',
    ),
  );
  await deleteOldLogFiles(parentDirPath, binaryName);
}

Future<void> deleteOldLogFiles(String parentDirPath, String binaryName) async {
  final currentDate = DateTime.now();
  FileSystem fs = const LocalFileSystem();

  final dir = fs.directory(p.join(parentDirPath, binaryName));

  await Future.forEach(dir.listSync(), (element) async {
    final stat = element.statSync();
    Log.d("File path: ${element.path}, Created: ${stat.changed}");
    final differenceInMonths = currentDate.difference(stat.changed).inDays ~/ 30;

    Log.d("Difference in months: $differenceInMonths");

    if (differenceInMonths >= 1) {
      await element.delete();
      Log.d("Deleted file: ${element.path}");
    }
  });
}

Future<void> settingWindow() async {
  WindowOptions windowOptions = const WindowOptions(
    size: windowSize,
    minimumSize: windowSize,
    // Add this line
    maximumSize: windowSize,
    // Add this line
    center: true,
    titleBarStyle: !kReleaseMode ? TitleBarStyle.normal : TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions);
}

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key, required this.executableArguments});

  final List<String> executableArguments;

  @override
  ConsumerState createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _viewModel = getIt<MainViewModel>();
  LaunchMode _launchMode = LaunchMode.launcher;
  Locale _locale = const Locale('en');
  late List<PageItem> _routes;
  late YaruPageController _pageController;

  @override
  void initState() {
    super.initState();
    _initLanguage();
    _initRoutes();
    _viewModel.subscribeToMessages();
    _viewModel.navigateUiEvent.stream.listen((event) {
      if (event is MoveToConnectionPageEvent) {
        _pageController.index = 0;
      }
    });

    _viewModel.versionState.stream.listen((data) {
      Log.d('${data.item1} | ${data.item2}');
      ref.read(updateAlertStateProvider.notifier).state = data.item3;
    });
  }

  void _initRoutes() {
    if (!widget.executableArguments.isNullOrEmpty) {
      switch (widget.executableArguments[0]) {
        case 'launcher':
          _launchMode = LaunchMode.launcher;
          break;
        case 'client':
          _launchMode = LaunchMode.client;
          break;
      }
    }
    _routes = _launchMode == LaunchMode.launcher ? launcherRoutes : clientRoutes;
    _pageController = YaruPageController(length: _routes.length);
  }

  void _initLanguage() {
    if (!widget.executableArguments.isNullOrEmpty) {
      if (widget.executableArguments.length > 1) {
        final language = widget.executableArguments[1];
        switch (language) {
          case 'ko':
            _locale = const Locale('ko');
            break;
          case 'en':
            _locale = const Locale('en');
            break;
          case 'ja':
            _locale = const Locale('ja');
            break;
        }
      }
    }
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
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
              if (_launchMode == LaunchMode.launcher) const BatteryView(),
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
            controller: _pageController,
            breakpoint: 0,
            tileBuilder: (context, index, selected, availableWidth) {
              final state = ref.watch(updateAlertStateProvider);
              return YaruMasterTile(
                leading: _routes[index].iconBuilder(context, selected),
                index: index,
                isAvailableUpdate: state,
                title: Text(
                  _routes[index].title,
                  style: WaveTextStyles.sideMenuTitle,
                ).paddingSymmetric(horizontal: 30),
              );
            },
            pageBuilder: (context, index) => _routes[index].pageBuilder(context),
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
