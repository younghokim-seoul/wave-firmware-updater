import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:wave_desktop_installer/utils/extension/margin_extension.dart';
import 'package:yaru/yaru.dart';

const kCustomAppBarSize = Size.fromHeight(100);


class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  const CustomAppBar({
    this.leading,
    this.title,
    this.actions,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget? leading;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsets padding;


  @override
  Size get preferredSize => kCustomAppBarSize;

  @override
  State<CustomAppBar> createState() => CustomAppBarState();
}


class CustomAppBarState extends State<CustomAppBar> {

  bool isScrolledUnder = false;

  ScrollNotificationObserverState? _scrollNotificationObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }

  @override
  void dispose() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
      _scrollNotificationObserver = null;
    }

    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      final oldIsScrolledUnder = isScrolledUnder;
      final metrics = notification.metrics;

      switch (metrics.axisDirection) {
        case AxisDirection.up:
          // Scroll view is reversed
          isScrolledUnder = metrics.extentAfter > 0;

        case AxisDirection.down:
          isScrolledUnder = metrics.extentBefore > 0;

        case AxisDirection.right:
        case AxisDirection.left:
        // Scrolled under is only supported in the vertical axis, and should
        // not be altered based on horizontal notifications of the same
        // predicate since it could be a 2D scroller.
      }

      if (isScrolledUnder != oldIsScrolledUnder) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: YaruColors.titleBarLight,
        boxShadow: null,
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: widget.preferredSize.height,
          ),
          child: Padding(
            padding: widget.padding,
            child: CustomMultiChildLayout(
              delegate: _CustomAppBarLayout(),
              children: <Widget>[
                if (widget.leading != null)
                  LayoutId(
                    id: _CustomAppBarSlot.leading,
                    child: widget.leading!,
                  ),
                if (widget.title != null)
                  LayoutId(
                    id: _CustomAppBarSlot.title,
                    child: Text(
                      widget.title!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (widget.actions != null)
                  LayoutId(
                    id: _CustomAppBarSlot.actions,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.actions!.toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _CustomAppBarSlot {
  leading,
  title,
  actions,
}

/// Layout delegate that positions 3 widgets along a horizontal axis in order to
/// keep the title widget centered and leading and actions in the left and
/// right side of the screen respectively.
class _CustomAppBarLayout extends MultiChildLayoutDelegate {
  /// The default spacing around the middle widget.
  static const kTitleSpacing = 8;

  @override
  void performLayout(Size size) {
    var leadingWidth = 0.0;
    var actionsWidth = 0.0;

    if (hasChild(_CustomAppBarSlot.leading)) {
      final constraints = BoxConstraints.loose(size);
      final leadingSize = layoutChild(_CustomAppBarSlot.leading, constraints);

      const leadingX = 0.0;
      final leadingY = (size.height - leadingSize.height) / 2;

      leadingWidth = leadingSize.width;

      positionChild(
        _CustomAppBarSlot.leading,
        Offset(leadingX, leadingY),
      );
    }

    if (hasChild(_CustomAppBarSlot.actions)) {
      final constraints = BoxConstraints.loose(size);
      final actionsSize = layoutChild(_CustomAppBarSlot.actions, constraints);

      final actionsX = size.width - actionsSize.width;
      final actionsY = (size.height - actionsSize.height) / 2;

      actionsWidth = actionsSize.width;

      positionChild(
        _CustomAppBarSlot.actions,
        Offset(actionsX, actionsY),
      );
    }

    if (hasChild(_CustomAppBarSlot.title)) {
      final side = math.max(leadingWidth, actionsWidth);
      final maxWidth = math.max<double>(
        size.width - side * 2 - kTitleSpacing * 2.0,
        0,
      );

      final constraints = BoxConstraints.loose(size).copyWith(
        maxWidth: maxWidth,
      );
      final titleSize = layoutChild(_CustomAppBarSlot.title, constraints);

      final titleX = (size.width - titleSize.width) / 2.0;
      final titleY = (size.height - titleSize.height) / 2;

      positionChild(
        _CustomAppBarSlot.title,
        Offset(titleX, titleY),
      );
    }
  }

  @override
  bool shouldRelayout(_CustomAppBarLayout oldDelegate) {
    return false;
  }
}
