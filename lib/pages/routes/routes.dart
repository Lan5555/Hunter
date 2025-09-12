import 'package:flutter/material.dart';

abstract class Router {
  void move(BuildContext context, Widget page);
  void pop(BuildContext context);
}

class PageRouter implements Router {
  @override
  void move(BuildContext context, dynamic page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page()));
  }

  @override
  void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
