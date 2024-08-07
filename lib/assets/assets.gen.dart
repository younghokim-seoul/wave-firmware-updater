/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/NotoSansKR-Bold.ttf
  String get notoSansKRBold => 'assets/fonts/NotoSansKR-Bold.ttf';

  /// File path: assets/fonts/NotoSansKR-Regular.ttf
  String get notoSansKRRegular => 'assets/fonts/NotoSansKR-Regular.ttf';

  /// List of all assets
  List<String> get values => [notoSansKRBold, notoSansKRRegular];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/Btn_FirmwareUpdate_Complete.png
  AssetGenImage get btnFirmwareUpdateComplete =>
      const AssetGenImage('assets/icons/Btn_FirmwareUpdate_Complete.png');

  /// File path: assets/icons/Btn_FirmwareUpdate_Downloading.png
  AssetGenImage get btnFirmwareUpdateDownloading =>
      const AssetGenImage('assets/icons/Btn_FirmwareUpdate_Downloading.png');

  /// File path: assets/icons/Btn_FirmwareUpdate_Start.png
  AssetGenImage get btnFirmwareUpdateStart =>
      const AssetGenImage('assets/icons/Btn_FirmwareUpdate_Start.png');

  /// File path: assets/icons/Close_Btn_Normal.png
  AssetGenImage get closeBtnNormal =>
      const AssetGenImage('assets/icons/Close_Btn_Normal.png');

  /// File path: assets/icons/Close_Btn_Over.png
  AssetGenImage get closeBtnOver =>
      const AssetGenImage('assets/icons/Close_Btn_Over.png');

  /// File path: assets/icons/Icon_Alert.png
  AssetGenImage get iconAlert =>
      const AssetGenImage('assets/icons/Icon_Alert.png');

  /// File path: assets/icons/Icon_Battery.png
  AssetGenImage get iconBattery =>
      const AssetGenImage('assets/icons/Icon_Battery.png');

  /// File path: assets/icons/Icon_WaveTools_Alert.png
  AssetGenImage get iconWaveToolsAlert =>
      const AssetGenImage('assets/icons/Icon_WaveTools_Alert.png');

  /// File path: assets/icons/Icon_WaveTools_Refresh.png
  AssetGenImage get iconWaveToolsRefresh =>
      const AssetGenImage('assets/icons/Icon_WaveTools_Refresh.png');

  /// File path: assets/icons/Icon_WaveTools_Scan.png
  AssetGenImage get iconWaveToolsScan =>
      const AssetGenImage('assets/icons/Icon_WaveTools_Scan.png');

  /// File path: assets/icons/Icon_WaveTools_Wifi_01.png
  AssetGenImage get iconWaveToolsWifi01 =>
      const AssetGenImage('assets/icons/Icon_WaveTools_Wifi_01.png');

  /// File path: assets/icons/Icon_bluetooth_disable.png
  AssetGenImage get iconBluetoothDisable =>
      const AssetGenImage('assets/icons/Icon_bluetooth_disable.png');

  /// File path: assets/icons/Icon_bluetooth_enable.png
  AssetGenImage get iconBluetoothEnable =>
      const AssetGenImage('assets/icons/Icon_bluetooth_enable.png');

  /// File path: assets/icons/Icon_wave.png
  AssetGenImage get iconWave =>
      const AssetGenImage('assets/icons/Icon_wave.png');

  /// File path: assets/icons/Icon_wavetools_connection.png
  AssetGenImage get iconWavetoolsConnection =>
      const AssetGenImage('assets/icons/Icon_wavetools_connection.png');

  /// File path: assets/icons/Icon_wifi_disable.png
  AssetGenImage get iconWifiDisable =>
      const AssetGenImage('assets/icons/Icon_wifi_disable.png');

  /// File path: assets/icons/Icon_wifi_enable.png
  AssetGenImage get iconWifiEnable =>
      const AssetGenImage('assets/icons/Icon_wifi_enable.png');

  /// File path: assets/icons/Reduction_Btn_Normal.png
  AssetGenImage get reductionBtnNormal =>
      const AssetGenImage('assets/icons/Reduction_Btn_Normal.png');

  /// File path: assets/icons/Reduction_Btn_Over.png
  AssetGenImage get reductionBtnOver =>
      const AssetGenImage('assets/icons/Reduction_Btn_Over.png');

  /// File path: assets/icons/icon_wave_tools.png
  AssetGenImage get iconWaveTools =>
      const AssetGenImage('assets/icons/icon_wave_tools.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        btnFirmwareUpdateComplete,
        btnFirmwareUpdateDownloading,
        btnFirmwareUpdateStart,
        closeBtnNormal,
        closeBtnOver,
        iconAlert,
        iconBattery,
        iconWaveToolsAlert,
        iconWaveToolsRefresh,
        iconWaveToolsScan,
        iconWaveToolsWifi01,
        iconBluetoothDisable,
        iconBluetoothEnable,
        iconWave,
        iconWavetoolsConnection,
        iconWifiDisable,
        iconWifiEnable,
        reductionBtnNormal,
        reductionBtnOver,
        iconWaveTools
      ];
}

class Assets {
  Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size = null});

  final String _assetName;

  final Size? size;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
