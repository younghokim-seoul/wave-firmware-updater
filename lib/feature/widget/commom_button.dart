import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/feature/widget/bounce_button.dart';
import 'package:yaru/theme.dart';

class CommonButton extends ConsumerWidget {
  const CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.width = 480,
    this.height = 60,
    this.radius = const Radius.circular(40),
    this.icon,
    this.alignment = Alignment.center,
    this.titlePadding = EdgeInsets.zero,
  });

  final double width;
  final double height;
  final Radius radius;
  final Widget title;
  final Widget? icon;
  final Alignment alignment;
  final EdgeInsets titlePadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BounceGray(
      onTap: () => onTap.call(),
      child: Container(
        decoration: BoxDecoration(
          color: YaruColors.selectBarHighlightColor,
          borderRadius: BorderRadius.all(radius),
        ),
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned(left: 9, top: 0, bottom: 0, child: icon ?? const SizedBox()),
            Padding(
              padding: titlePadding,
              child: Align(
                alignment: alignment,
                child: title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
