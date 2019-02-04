import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:itemized_widget/src/common/itemized_widget_direction.dart';

class ItemizedViewWrapperWidget extends StatelessWidget {
  ItemizedViewWrapperWidget(
      {Key key,
      this.exitIn = false,
      this.exitOut = false,
      this.entryIn = false,
      this.entryOut = false,
      this.offset = 0.0,
      this.position = 1.0,
      @required this.child,
      this.formNavigation = ItemizedWidgetDirection.NONE})
      : super(key: key);

  final bool exitIn;
  final bool exitOut;
  final bool entryIn;
  final bool entryOut;

  final double offset;
  final double position;

  final ItemizedWidgetDirection formNavigation;

  final Widget child;

  double _getOpacity() {
    if (exitOut ||
        (entryOut && formNavigation != ItemizedWidgetDirection.NONE)) {
      return 1.0 - position;
    }
    return position;
  }

  double _getTranslationY() {
    if (exitOut) {
      return lerpDouble(offset, 0.0, 1.0 - position);
    } else if (exitIn) {
      return lerpDouble(0.0, -offset, 1.0 - position);
    } else if (entryOut) {
      return lerpDouble(-offset, 0.0, 1.0 - position);
    } else if (entryIn) {
      return lerpDouble(0.0, offset, 1.0 - position);
    }
    return offset * (1.0 - position);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _getOpacity(),
      child: Transform(
        transform: Matrix4.translationValues(0.0, _getTranslationY(), 0.0),
        child: child,
      ),
    );
  }
}
