import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:itemized_widget/src/common/itemized_transition.dart';
import 'package:itemized_widget/src/common/itemized_widget_direction.dart';
import 'package:itemized_widget/src/state/itemized_navigation_state.dart';
import 'package:itemized_widget/src/ui/itemized_view_widget.dart';
import 'package:itemized_widget/src/ui/itemized_view_wrapper_widget.dart';
import 'package:redux/redux.dart';

part 'renderer_widget.dart';

class ItemizedWidget extends StatefulWidget {
  ItemizedWidget(
      {Key key,
      this.size = 0,
      this.activePage = 0,
      this.offset = 100.0,
      this.stream,
      @required this.builder})
      : super(key: key);

  final int size;
  final int activePage;
  final double offset;
  final Stream<ItemizedWidgetDirection> stream;

  final ItemizedViewWidget builder;

  @override
  State<StatefulWidget> createState() => _ItemizedWidgetState(activePage);
}

class _ItemizedWidgetState extends State<ItemizedWidget>
    with TickerProviderStateMixin {
  _ItemizedWidgetState(int activePage) : this.activePage = activePage {
    percentage = 0.0;
  }

  int activePage;
  double percentage;
  ItemizedTransition transition;

  PageController pageController;
  ItemizedNavigationState navigationState;
  Store<ItemizedNavigationState> navigationStore;
  StreamSubscription<ItemizedWidgetDirection> subscription;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    navigationState = ItemizedNavigationState(ItemizedWidgetDirection.NONE);
    navigationStore = Store(navigate, initialState: navigationState);
    if (widget.stream != null) {
      subscription = widget.stream.listen((direction) {
        navigationStore.dispatch(direction);
      });
    }
  }

  List<Widget> _buildWidgets(BuildContext context) {
    List<Widget> widgets = [];
    for (var index = activePage - 1;
        index <= activePage + 1 && widget.size > 0;
        index++) {
      widgets.add(_RendererWidget(
        size: widget.size,
        offset: widget.offset,
        position: index,
        activePage: activePage,
        percentage: percentage,
        builder: widget.builder,
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<ItemizedNavigationState>(
      store: navigationStore,
      child: Stack(children: _buildWidgets(context)),
    );
  }

  ItemizedNavigationState navigate(ItemizedNavigationState prev, direction) {
    if (prev.direction != ItemizedWidgetDirection.NONE) {
      return ItemizedNavigationState(direction);
    }
    if (direction == ItemizedWidgetDirection.PREVIOUS) {
      previous(direction);
    } else if (direction == ItemizedWidgetDirection.NEXT) {
      next(direction);
    }
    return ItemizedNavigationState(direction);
  }

  void next(ItemizedWidgetDirection navigation) {
    transition = ItemizedTransition((percent) {
      setState(() {
        percentage = percent;
      });
    }, () {
      setState(() => finishNavigation(activePage + 1));
    }, navigation, this);
    transition.run();
  }

  void previous(ItemizedWidgetDirection navigation) {
    transition = ItemizedTransition((percent) {
      setState(() {
        percentage = 1.0 - percent;
      });
    }, () {
      setState(() => finishNavigation(activePage - 1));
    }, navigation, this);
    transition.run();
  }

  void finishNavigation(int nextPage) {
    percentage = 0.0;
    activePage = _getItemPosition(nextPage, widget.size);
    navigationStore.dispatch(ItemizedWidgetDirection.NONE);
    transition.dispose();
  }

  @override
  void dispose() {
    subscription.cancel();
    pageController.dispose();
    super.dispose();
  }
}
