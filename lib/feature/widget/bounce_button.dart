import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class BounceGray extends StatefulWidget {
  const BounceGray({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.95,
    this.paddingHorizontal = 0,
    this.paddingVertical = 0,
  });

  final Widget? child;
  final Function() onTap;
  final double scale;
  final double paddingHorizontal;
  final double paddingVertical;

  @override
  State<BounceGray> createState() => _ButtonAnimState();
}

class _ButtonAnimState extends State<BounceGray> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool tapDown = false;
  bool tapCancel = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
        reverseDuration: const Duration(milliseconds: 150),
        value: 1.0,
        lowerBound: 0.000001,
        upperBound: 1.00000
    );

    _animation = CurvedAnimation(
        parent: _controller,
        curve: CustomEaseOutCircCurve(scale: widget.scale),
        reverseCurve: CustomEaseInCircCurve(scale: widget.scale)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      if (!tapCancel) widget.onTap();
      _controller.forward();
      setState(() {
        tapDown = false;
      });
    });
    tapCancel = false;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _controller.reverse();
      tapDown = true;
    });
  }

  void _onTapCancel() {
    tapCancel = true;
    _controller.reverse().then((_) {
      _controller.forward();
      setState(() {
        tapDown = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: _animation,
        child: InkWell(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: (tapDown) ? YaruColors.textGrey.withOpacity(0) : YaruColors.textGrey.withOpacity(0),
              ),
              padding: EdgeInsets.only(left: widget.paddingHorizontal, right: widget.paddingHorizontal, top: widget.paddingVertical, bottom: widget.paddingVertical),
              child: widget.child,
            )
        )
    );
  }
}

class CustomEaseOutCircCurve extends Curve {

  final double scale;

  const CustomEaseOutCircCurve({required this.scale});

  @override
  double transformInternal(double t) {
    // Curves.easeOutCirc의 동작을 사용자 정의 커브 함수로 변환합니다.
    return ((1 - scale) * sqrt(1 - pow(t - 1, 2)) + scale);
  }
}

class CustomEaseInCircCurve extends Curve {

  final double scale;

  const CustomEaseInCircCurve({required this.scale});

  @override
  double transformInternal(double t) {
    return ((1 - scale) * (1 - sqrt(1 - pow(t, 2))) + scale);
  }
}