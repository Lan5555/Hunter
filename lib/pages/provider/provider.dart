import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String userId = "";
  int selectedIndex = 0;

  String get data => userId;
  int get indexData => selectedIndex;

  void updateData(String newData) {
    userId = newData;
    notifyListeners();
  }

  void updateIndexData(int data) {
    selectedIndex = data;
    notifyListeners();
  }
}
