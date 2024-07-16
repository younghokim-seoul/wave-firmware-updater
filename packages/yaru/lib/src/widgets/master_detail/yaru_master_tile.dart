import 'package:flutter/material.dart';
import 'package:yaru/theme.dart';

const double _kScrollbarThickness = 8.0;
const double _kScrollbarMargin = 2.0;
const Duration _kSelectedTileAnimationDuration = Duration(milliseconds: 250);
const double _kItemHeight = 106.0;

enum MenuType {
  scan(0),
  firmware(1),
  alignment(2);

  const MenuType(
    this.code,
  );

  final int code;

  factory MenuType.fromCode(int code) => values.singleWhere((e) => code == e.code, orElse: () => MenuType.scan);
}

class YaruMasterTile extends StatelessWidget {
  const YaruMasterTile({
    super.key,
    this.selected,
    this.leading,
    this.isAvailableUpdate,
    required this.title,
    required this.index,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// See [ListTile.selected].
  final bool? selected;

  /// See [ListTile.leading].
  final Widget? leading;

  /// See [ListTile.title].
  final Widget? title;

  /// See [ListTile.subtitle].
  final Widget? subtitle;

  /// See [ListTile.trailing].
  final Widget? trailing;

  /// An optional [VoidCallback] forwarded to the internal [ListTile]
  /// If not provided [YaruMasterTileScope] `onTap` will be called.
  final VoidCallback? onTap;

  final int index;

  final bool? isAvailableUpdate;

  @override
  Widget build(BuildContext context) {
    final scope = YaruMasterTileScope.maybeOf(context);

    final isSelected = selected ?? scope?.selected ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: AnimatedContainer(
        duration: _kSelectedTileAnimationDuration,
        decoration: BoxDecoration(
          color: isSelected ? YaruColors.blue : YaruColors.selectBarHighlightColor,
        ),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!.call();
            } else {
              scope?.onTap();
            }
          },
          child: SizedBox(
            width: double.infinity,
            height: _kItemHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: SizedBox.square(
                    dimension: 60,
                    child: CustomPaint(
                      painter: LeadingPainter(),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Center(child: _titleStyle(context, title) ?? const SizedBox.shrink()),
                ),
                _buildAlert(context, index,isAvailableUpdate ?? false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlert(BuildContext context, int index,bool isUpdate) {
    return Visibility(
      visible: MenuType.fromCode(index) == MenuType.firmware && isUpdate,
      child: Positioned(
        right: 4,
        top: 4,
        child: SizedBox.square(
          dimension: 26,
          child: Image.asset(
            'assets/icons/Icon_Alert.png',
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  Widget? _titleStyle(BuildContext context, Widget? child) {
    if (child == null) {
      return child;
    }

    return DefaultTextStyle.merge(
      child: child,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _subTitleStyle(BuildContext context, Widget? child) {
    if (child == null) {
      return child;
    }

    return DefaultTextStyle.merge(
      child: child,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
    );
  }

  double _calcScrollbarThicknessWithTrack(final BuildContext context) {
    final scrollbarTheme = Theme.of(context).scrollbarTheme;

    final doubleMarginWidth =
        scrollbarTheme.crossAxisMargin != null ? scrollbarTheme.crossAxisMargin! * 2 : _kScrollbarMargin * 2;

    final scrollBarThumbThikness = scrollbarTheme.thickness?.resolve({WidgetState.hovered}) ?? _kScrollbarThickness;

    return doubleMarginWidth + scrollBarThumbThikness;
  }
}

class YaruMasterTileScope extends InheritedWidget {
  const YaruMasterTileScope({
    super.key,
    required super.child,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  static YaruMasterTileScope of(BuildContext context) {
    return maybeOf(context)!;
  }

  static YaruMasterTileScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<YaruMasterTileScope>();
  }

  @override
  bool updateShouldNotify(YaruMasterTileScope oldWidget) {
    return selected != oldWidget.selected || index != oldWidget.index;
  }
}

class LeadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = YaruColors.blue
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0) // 시작점을 (0, 0)으로 이동
      ..lineTo(size.width, 0) // (size.width, 0)까지 선을 그림
      ..lineTo(0, size.height) // (0, size.height)까지 선을 그림
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
