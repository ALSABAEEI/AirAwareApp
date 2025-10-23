import 'package:flutter/foundation.dart';

class ShellViewModel extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int newIndex) {
    if (newIndex == _index) return;
    _index = newIndex;
    notifyListeners();
  }
}
