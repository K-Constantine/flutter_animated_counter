import 'package:flutter/material.dart';
import 'package:itemized_widget/src/common/itemized_widget_scroll.dart';

class ItemizedTransition {
  ItemizedTransition(
      this.update, this.finish, this.navigation, TickerProvider tickerProvider,
      {int durationTime = 800})
      : duration = Duration(milliseconds: durationTime) {
    controller = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    );
    animation = CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 1.0, curve: Curves.fastOutSlowIn))
      ..addListener(onAnimationChange)
      ..addStatusListener(updateAnimationStatus);
  }

  final Function update;
  final Function finish;
  final Duration duration;
  final ItemizedWidgetScroll navigation;

  CurvedAnimation animation;
  AnimationController controller;

  void onAnimationChange() {
    update(animation.value);
  }

  void updateAnimationStatus(animationStatus) {
    if (animationStatus == AnimationStatus.completed) {
      finish();
    }
  }

  void run() {
    controller.forward(from: 0.0);
  }

  void dispose() {
    controller.dispose();
  }
}
