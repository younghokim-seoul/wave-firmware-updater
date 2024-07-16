import 'dart:math' as math show sin, pi;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/theme/wave_tool_text_styles.dart';

enum SpinKitFadingCircleType { small, large }

class SpinKitFadingCircle extends StatefulWidget {
  const SpinKitFadingCircle({
    required this.size,
    required this.type,
    this.color,
    this.label,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
    super.key,
  }) : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  const SpinKitFadingCircle.medium({
    this.color = Colors.white,
    this.label,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
    super.key,
  })  : size = 50.0,
        type = SpinKitFadingCircleType.small;

  const SpinKitFadingCircle.large({
    this.color = Colors.white,
    this.label,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
    super.key,
  })  : size = 160.0,
        type = SpinKitFadingCircleType.large;

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final String? label;
  final AnimationController? controller;
  final SpinKitFadingCircleType type;

  @override
  State<SpinKitFadingCircle> createState() => _SpinKitFadingCircleState();
}

class _SpinKitFadingCircleState extends State<SpinKitFadingCircle> with SingleTickerProviderStateMixin {
  static const _itemCount = 12;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.fromSize(
          size: Size.square(widget.size),
          child: Stack(
            children: List.generate(_itemCount, (i) {
              final position = widget.size * .5;
              return Positioned.fill(
                left: position,
                top: position,
                child: Transform(
                  transform: Matrix4.rotationZ(30.0 * i * 0.0174533),
                  child: Align(
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: DelayTween(
                        begin: 0.0,
                        end: 1.0,
                        delay: i / _itemCount,
                      ).animate(_controller),
                      child: SizedBox.fromSize(
                        size: Size.square(widget.size / 1.5 * 0.15),
                        child: _itemBuilder(i),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        _labelBuilder(),
      ],
    ));
  }

  Widget _labelBuilder() {
    return widget.type == SpinKitFadingCircleType.large
        ? Column(children: [
            const Gap(58),
            Text(
              widget.label ?? '',
              style: WaveTextStyles.buttonLargeBold,
            ),
          ])
        : const SizedBox.shrink();
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        );
}

class DelayTween extends Tween<double> {
  DelayTween({
    super.begin,
    super.end,
    required this.delay,
  });

  final double delay;

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
