import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave_desktop_installer/assets/assets.gen.dart';

class CustomActionButton extends ConsumerStatefulWidget {
  const CustomActionButton({super.key, this.onTap, required this.closeImage, required this.hoverImage});

  final GestureTapCallback? onTap;
  final Widget closeImage;
  final Widget hoverImage;

  CustomActionButton.close({
    required this.onTap,
    super.key,
  })  : closeImage = Assets.icons.closeBtnNormal.image(),
        hoverImage = Assets.icons.closeBtnOver.image();

  CustomActionButton.reduction({
    required this.onTap,
    super.key,
  })  : closeImage = Assets.icons.reductionBtnNormal.image(),
        hoverImage = Assets.icons.reductionBtnOver.image();

  @override
  ConsumerState createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends ConsumerState<CustomActionButton> {
  bool _hovered = false;
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _handleHoverChange(true),
      onExit: (event) => _handleHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapUp: (_) => _handleHoverChange(false),
        child: SizedBox.square(
          dimension: 50,
          child: _hovered ? widget.hoverImage : widget.closeImage,
        ),
      ),
    );
  }

  void _handleHoverChange(bool hovered) {
    if (_hovered == hovered) {
      return;
    }

    setState(() {
      _hovered = hovered;

      if (!hovered) {
        _active = false;
      }
    });
  }
}
