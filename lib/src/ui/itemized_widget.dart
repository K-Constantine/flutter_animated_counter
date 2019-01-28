import 'package:flutter/material.dart';
import 'package:itemized_widget/src/common/itemized_transition.dart';
import 'package:itemized_widget/src/common/itemized_widget_scroll.dart';
import 'package:itemized_widget/src/model/itemized_model.dart';
import 'package:itemized_widget/src/ui/itemized_view_widget.dart';
import 'package:itemized_widget/src/ui/itemized_view_wrapper_widget.dart';
import 'package:providerscope/providerscope.dart';

class ItemizedWidget extends StatefulWidget {
  ItemizedWidget(
      {Key key,
      this.size = 0,
      this.activePage = 0,
      this.offset = 100.0,
      @required this.scope,
      @required ItemizedViewWidget builder})
      : this._build = builder,
        super(key: key);

  final int size;
  final int activePage;
  final double offset;
  final ProviderScope scope;
  final ItemizedViewWidget _build;

  @override
  State<StatefulWidget> createState() => _ItemizedWidgetState(activePage);
}

class _ItemizedWidgetState extends State<ItemizedWidget>
    with TickerProviderStateMixin {
  _ItemizedWidgetState(int activePage) : this.activePage = activePage {
    percentage = 0.0;
    navigation = ItemizedWidgetScroll.NONE;
  }

  int activePage;
  double percentage;
  ItemizedTransition transition;

  ItemizedWidgetScroll navigation;
  PageController pageController = new PageController();

  List<ItemizedViewWrapperWidget> _buildWidgets(BuildContext context) {
    List<ItemizedViewWrapperWidget> widgets = [];
    if (widget.size <= 0) {
      return widgets;
    }
    for (var index = activePage - 1; index <= activePage + 1; index++) {
      widgets.add(_createWidget(context, index));
    }
    return widgets;
  }

  ItemizedViewWrapperWidget _createWidget(BuildContext context, int index) {
    var entryIn = false;
    var entryOut = false;
    var animationValue = 0.0;

    if (index == activePage) {
      animationValue = 1.0 - percentage;
    } else if (index == activePage - 1 &&
        navigation == ItemizedWidgetScroll.PREVIOUS) {
      entryOut = true;
      animationValue = percentage;
    } else if (index == activePage + 1 &&
        navigation == ItemizedWidgetScroll.NEXT) {
      entryIn = true;
      animationValue = percentage;
    }
    return _itemize(index, animationValue, entryIn, entryOut);
  }

  Widget _itemize(int index, double position, bool entryIn, bool entryOut) {
    var isActive = index == activePage;
    // Itemized wrapper
    return ItemizedViewWrapperWidget(
      child: widget._build(_getItemPosition(index), position),
      position: position,
      offset: widget.offset,
      formNavigation: navigation,
      exitIn: isActive && navigation == ItemizedWidgetScroll.NEXT,
      exitOut: isActive && navigation == ItemizedWidgetScroll.PREVIOUS,
      entryIn: entryIn,
      entryOut: entryOut,
    );
  }

  int _getItemPosition(index) {
    var position = (index >= widget.size) ? 0 : index;
    return (index < 0) ? widget.size - 1 : position;
  }

  @override
  Widget build(BuildContext context) {
    return Provide<ItemizedModel>(
      scope: widget.scope,
      builder: (BuildContext context, Widget child, ItemizedModel model) {
        model.listen(_navigate);
        return Stack(children: _buildWidgets(context));
      },
    );
  }

  void _navigate(ItemizedWidgetScroll direction) {
    if (navigation != ItemizedWidgetScroll.NONE) {
      return;
    }
    if (direction == ItemizedWidgetScroll.PREVIOUS) {
      previous();
    } else {
      next();
    }
  }

  void next() {
    navigation = ItemizedWidgetScroll.NEXT;
    transition = ItemizedTransition((percent) {
      setState(() {
        percentage = percent;
      });
    }, () {
      setState(() {
        navigation = ItemizedWidgetScroll.NONE;
        activePage = _getItemPosition(activePage + 1);
        percentage = 0.0;
        transition.dispose();
      });
    }, navigation, this);
    transition.run();
  }

  void previous() {
    navigation = ItemizedWidgetScroll.PREVIOUS;
    transition = ItemizedTransition((percent) {
      setState(() {
        percentage = 1.0 - percent;
      });
    }, () {
      setState(() {
        navigation = ItemizedWidgetScroll.NONE;
        activePage = _getItemPosition(activePage - 1);
        percentage = 0.0;
        transition.dispose();
      });
    }, navigation, this);
    transition.run();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
