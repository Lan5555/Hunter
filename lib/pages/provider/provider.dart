import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String  userId = "";

  String get data => userId;

  void updateData(String newData) {
    userId = newData;
    notifyListeners();
  }
}