import 'package:providerscope/providerscope.dart';

class CounterModel extends Model {
  int _counter = 1;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}
