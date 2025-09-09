import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/subpages/preview_houses.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';

class ViewPlaces extends StatefulWidget {
  const ViewPlaces({super.key});
  @override
  Place createState() => Place();
}

class Place extends State<ViewPlaces> {
  List<Map<String, dynamic>> places = [
    {
      'name': 'Duplex',
      'properties': {
        'image': 'assets/images/house.jpg',
        'price': 'N200',
        'details': 'Some text too goes here',
        'location':'unkwown',
        'imagelist':['assets/images/house.jpg','assets/images/house.jpg']
      },
    },
    {
      'name': 'Bungalow',
      'properties': {
        'image': 'assets/images/house.jpg',
        'price': 'N500',
        'details': 'Some text also goes here',
        'location':'unkwown',
        'imagelist':['assets/images/house.jpg','assets/images/house.jpg']
      },
    },
    {
      'name': 'Story building',
      'properties': {
        'image': 'assets/images/house.jpg',
        'price': 'N900',
        'details': 'Some text can goes here',
        'location':'unkwown',
        'imagelist':['assets/images/house.jpg','assets/images/house.jpg']
      },
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: 
        List.generate(places.length, (index) {
          final item = places[index];
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(16),child: 
          createHorizontalCard(
            image: item['properties']['image'],
            name: item['name'],
            details: item['properties']['details'],
            price: item['properties']['price'],
            rating: Row(children: [Icon(Icons.star), Text(('4.5(6.2k)'))]),
            onBookmarkTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HousePreview(image: item['properties']['image'], details: item['properties']['details'],price: item['properties']['price'],name: item['name'],location: item['properties']['location'],imagelist: item['properties']['imagelist'],)))
          ))]);
        }).toList(),
      ),
    ).animate().fade(duration: Duration(milliseconds: 500));
  }
}
