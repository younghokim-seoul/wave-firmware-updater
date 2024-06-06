import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';


abstract class WaveTextStyles {


  static const fontFamily = 'NotoSansKR';

  static TextTheme get textTheme => const TextTheme(
    labelLarge: buttonLarge,
    titleMedium: subtitle1,
    titleSmall: subtitle2,
    labelSmall: overline,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: caption,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 36,
    letterSpacing: 0.09,
  );

  static const TextStyle headline4Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 36,
    letterSpacing: 0.09,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 26,
  );

  static const TextStyle headline5Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 26,
  );

  static const TextStyle appBarHeader = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: YaruColors.titleTextLight,
    height: 1.2,
    letterSpacing: 0.03,
  );

  static const TextStyle headline6Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 21,
    letterSpacing: 0.03,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.4,
    color: YaruColors.titleVersionLight,
    letterSpacing: 0.03,
  );

  static const TextStyle sideMenuTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    color: YaruColors.titleTextLight,
    fontSize: 24,
    height: 1.4,
    letterSpacing: 0.03,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    letterSpacing: 0.02,
  );

  static const TextStyle subtitle2Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 0.02,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    letterSpacing: 0.09,
    color: Colors.white
  );

  static const TextStyle body1Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    letterSpacing: 0.09,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.26,
    letterSpacing: 0.25,
  );

  static const TextStyle body2Bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.135,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.41,
    letterSpacing: 0.21,
  );

  static const TextStyle buttonLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.41,
    letterSpacing: 0.21,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.14,
    letterSpacing: 0.17,
  );

  static const TextStyle buttonMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.14,
    letterSpacing: 0.17,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.15,
  );

  static const TextStyle buttonSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.15,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    letterSpacing: 0.05,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.05,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    letterSpacing: 0.17,
  );

  static const TextStyle overlineBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 0.17,
  );
}