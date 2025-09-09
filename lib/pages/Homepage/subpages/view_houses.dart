import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  First createState() => First();
}

class First extends State<FirstPage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildCategory(
                  index: 0,
                  icon: Icons.house,
                  isActive: _selectedCategoryIndex == 0,
                  name: Text(
                    'Apartment',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = 0;
                    });
                  },
                ),
                buildCategory(
                  index: 1,
                  icon: Icons.place,
                  isActive: _selectedCategoryIndex == 1,
                  name: Text('Places', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = 1;
                    });
                  },
                ),
                buildCategory(
                  index: 2,
                  icon: Icons.other_houses_rounded,
                  isActive: _selectedCategoryIndex == 2,
                  name: Text('Hostels', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = 2;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Apartments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextButton(onPressed: () {}, child: Text('See all')),
              ],
            ),
            SizedBox(height: 20),
            CarouselSlider(
              items: [
                createCard(
                  image: 'assets/images/house.jpg',
                  name: 'Test house',
                  details: 'Very comfortable',
                  price: 'N5000',
                  rating: Row(children: [Icon(Icons.star), Text('4.9(6.5)k')]),
                ),
                createCard(
                  image: 'assets/images/house.jpg',
                  name: 'Test house',
                  details: 'Very comfortable',
                  price: 'N5000',
                  rating: Row(children: [Icon(Icons.star), Text('4.9(6.5)k')]),
                ),
                createCard(
                  image: 'assets/images/house.jpg',
                  name: 'Test house',
                  details: 'Very comfortable',
                  price: 'N5000',
                  rating: Row(children: [Icon(Icons.star), Text('4.9(6.5)k')]),
                ),
              ],
              options: CarouselOptions(
                height: 270,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Low Budget Apartments',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            createHorizontalCard(
              image: 'assets/images/house.jpg',
              name: 'Test house',
              details: 'Some details can go here',
              price: '20k',
              rating: Row(children: [Text('5.0 (7.5k)'), Icon(Icons.star)]),
            ),
            SizedBox(height: 15),
            createHorizontalCard(
              image: 'assets/images/house.jpg',
              name: 'Test house',
              details: 'Some details can go here',
              price: '20k',
              rating: Row(children: [Text('5.0 (7.5k)'), Icon(Icons.star)]),
            ),
            SizedBox(height: 15),
            createHorizontalCard(
              image: 'assets/images/house.jpg',
              name: 'Test house',
              details: 'Some details can go here',
              price: '20k',
              rating: Row(children: [Text('5.0 (7.5k)'), Icon(Icons.star)]),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    ).animate().fadeIn(duration: Duration(milliseconds: 500));
  }
}
