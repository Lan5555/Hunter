import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/subpages/view_houses.dart';
import 'package:hunter/pages/Homepage/subpages/view_places.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  Home createState() => Home();
}

class Home extends State<HomePage> {
    int _selectedIndex = 0;
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.place, 'label': 'Places'},
    {'icon': Icons.favorite, 'label': 'Likes'},
    {'icon': Icons.person, 'label': 'Profile'},
  ];
  List<Widget>pages = [
    FirstPage(),
    ViewPlaces()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Rent',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'An Apartment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: Offset(0, 0.15 * 24),
                  color: Color.fromRGBO(33, 40, 50, 0.15),
                ),
              ],
            ),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body:pages.isNotEmpty && _selectedIndex < pages.length
    ? pages[_selectedIndex]
    : Center(child: Text('No page yet')),

      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'],
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                item['label'],
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

