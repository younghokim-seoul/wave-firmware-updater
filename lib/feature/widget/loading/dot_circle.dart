import 'dart:math' as math show sin, pi;
import 'package:flutter/widgets.dart';


class SpinKitFadingCircle extends StatefulWidget {
  const SpinKitFadingCircle({
    super.key,
    this.color,
    this.size = 160.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(
  !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color',
  );

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

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
      child: SizedBox.fromSize(
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
    );
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