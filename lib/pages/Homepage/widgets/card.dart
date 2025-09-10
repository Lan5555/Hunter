import 'package:flutter/material.dart';

Widget createCard({
  required String image,
  required String name,
  required String details,
  required String price,
  required Widget rating,
  double? width,
  double? height,
  void Function()? onBookmarkTap, // Optional tap handler
}) {
  return Container(
    width: width ?? 250,
    height: height ?? 300,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 1.2,
          spreadRadius: 0.0,
          //offset: Offset(0, 3.6), // 0.15 * 24
          color: Color.fromRGBO(33, 40, 50, 0.15),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -5,
                right: 8,
                child: GestureDetector(
                  onTap: onBookmarkTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.bookmark_border, size: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            details,
            style: TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              rating,
            ],
          ),
        ],
      ),
    ),
  );
}

Widget createHorizontalCard({
  required String image,
  required String name,
  required String details,
  required String price,
  required Widget rating,
  double? width,
  double? height,
  void Function()? onBookmarkTap, // Optional tap handler
}) {
  return GestureDetector(
    onTap: onBookmarkTap,
    child: 
  Container(
    width: width ?? double.infinity,
    height: height ?? 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          spreadRadius: 1,
          offset: Offset(0, 2),
          color: Color.fromRGBO(33, 40, 50, 0.15),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
          ),
          SizedBox(width: 16), // spacing between image and content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    rating,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ));
}


Widget buildCategory({
  required int index,
  required IconData icon,
  required Widget name,
  required bool isActive,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 100,
      height: 90,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.white, // Active color
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0.0,
            offset: Offset(0, 0.15 * 24),
            color: Color.fromRGBO(33, 40, 50, 0.15),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: Duration(microseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              icon,
              key: ValueKey<bool>(isActive),
              color: isActive ? Colors.blue : Colors.black,
            ),
          ), // Icon color
          SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 200),
            style: TextStyle(color: isActive ? Colors.blue : Colors.black),
            child: name,
          ),
        ],
      ),
    ),
  );
}
