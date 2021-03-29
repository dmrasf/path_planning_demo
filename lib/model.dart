import 'package:flutter/material.dart';

class MyThemeModel extends ChangeNotifier {
  bool _isLightTheme = true;

  void changeTheme(bool newValue) {
    _isLightTheme = newValue;
    notifyListeners();
  }

  bool get isLightTheme => _isLightTheme;
}
