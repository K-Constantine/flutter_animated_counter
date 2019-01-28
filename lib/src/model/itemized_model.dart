import 'package:itemized_widget/src/common/itemized_widget_scroll.dart';
import 'package:providerscope/providerscope.dart';

typedef void ItemCallback(ItemizedWidgetScroll direction);

class ItemizedModel extends Model {
  ItemCallback _itemCallback;

  void listen(ItemCallback itemCallback) {
    _itemCallback = itemCallback;
  }

  void next() {
    _itemCallback(ItemizedWidgetScroll.NEXT);
  }

  void previous() {
    _itemCallback(ItemizedWidgetScroll.PREVIOUS);
  }
}
