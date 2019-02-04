import 'package:flutter/material.dart';
import 'package:itemized_widget/src/common/itemized_widget_direction.dart';

@immutable
class ItemizedNavigationState {
  ItemizedNavigationState(this.direction);

  final ItemizedWidgetDirection direction;
}
