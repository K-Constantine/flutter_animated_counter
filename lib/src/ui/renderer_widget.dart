part of 'itemized_widget.dart';

int _getItemPosition(index, size) {
  var position = (index >= size) ? 0 : index;
  return (index < 0) ? size - 1 : position;
}

class _RendererWidget extends StatelessWidget {
  _RendererWidget({
    this.size,
    this.offset,
    this.position,
    this.activePage,
    this.percentage,
    this.builder,
  }) : super();

  final int size;
  final int position;
  final int activePage;

  final double offset;
  final double percentage;
  final ItemizedViewWidget builder;

  Widget _itemize(double value, bool entryIn, bool entryOut,
      ItemizedWidgetDirection direction) {
    var isActive = position == activePage;
    // Itemized wrapper
    return ItemizedViewWrapperWidget(
      child: builder(_getItemPosition(position, size), value),
      position: value,
      offset: offset,
      formNavigation: direction,
      exitIn: isActive && direction == ItemizedWidgetDirection.NEXT,
      exitOut: isActive && direction == ItemizedWidgetDirection.PREVIOUS,
      entryIn: entryIn,
      entryOut: entryOut,
    );
  }

  Widget _builder(BuildContext context, ItemizedWidgetDirection direction) {
    var entryIn = false;
    var entryOut = false;
    var animationValue = 0.0;

    if (position == activePage) {
      animationValue = 1.0 - percentage;
    } else if (position == activePage - 1 &&
        direction == ItemizedWidgetDirection.PREVIOUS) {
      entryOut = true;
      animationValue = percentage;
    } else if (position == activePage + 1 &&
        direction == ItemizedWidgetDirection.NEXT) {
      entryIn = true;
      animationValue = percentage;
    }
    return _itemize(animationValue, entryIn, entryOut, direction);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ItemizedNavigationState, ItemizedWidgetDirection>(
      converter: (store) => store.state.direction,
      builder: (context, model) {
        return _builder(context, model);
      },
    );
  }
}
