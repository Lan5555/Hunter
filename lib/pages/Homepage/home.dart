import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/subpages/booking_status.dart';
import 'package:hunter/pages/Homepage/subpages/settings.dart';
import 'package:hunter/pages/Homepage/subpages/view_houses.dart';
import 'package:hunter/pages/Homepage/subpages/view_places.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';
import 'package:hunter/pages/controllers/booking_controller.dart';

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
  List<Widget> pages = [
    FirstPage(),
    ViewPlaces(),
    BookingOverviewPage(
      booking: Booking(
        id: "#BK19238",
        name: "Seaside Villa",
        images: ['assets/images/house.jpg', 'assets/images/house.jpg'],
        description: "Beautiful beachfront villa with private pool.",
        status: "Pending", // or "Completed"
        date: "Sept 9, 2025",
        checkIn: "Sept 15, 2025",
        checkOut: "Sept 20, 2025",
        paymentStatus: "Not Paid",
        review: null, // optional
        phoneNumber: '09065590812'
      ),
    ),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        titleSpacing: 20,
        title: _selectedIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Rent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'An Apartment',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            : _selectedIndex == 1
            ? Text('Apartments', style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
            ),)
            : _selectedIndex == 2
            ? Text('Booking status',style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
            ),)
            : _selectedIndex == 3
            ? Text('Settings',style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold
            ),)
            : null,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black87),
              onPressed: () {
                // Handle search action
              },
            ),
          ),
        ],
      ),

      body: pages.isNotEmpty && _selectedIndex < pages.length
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
