import 'package:flutter/material.dart';

Widget filledButton({required Widget item, required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: 
  Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 24,
          color: Color.fromRGBO(33, 40, 50, 0.15),
          spreadRadius: 0.0,
          offset: Offset(0, 0.15),
        ),
      ],
    ),
    child: Center(
      child: item,
    ),
  ));
}
