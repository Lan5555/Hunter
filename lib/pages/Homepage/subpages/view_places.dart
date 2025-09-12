import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hunter/pages/Homepage/subpages/preview_houses.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';

class ViewPlaces extends StatefulWidget {
  const ViewPlaces({super.key});
  @override
  State<ViewPlaces> createState() => Place();
}

class Place extends State<ViewPlaces> {
  String userId = "";
  Map<String, dynamic> houseData = {};
  Map<String, dynamic> cachedHouseData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userId = context.read<AppState>().userId;
      loadHouseData();
    });
  }

  void loadHouseData() async {
    try {
      final data = await FirebaseController().fetchData('properties', 'agents');
      setState(() {
        houseData = data;
        if (cachedHouseData.isEmpty) {
          cachedHouseData = Map<String, dynamic>.from(data);
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching house data: $error');
      }
      ShowSnackBar().warning(title: 'Failed to load data', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataToDisplay = cachedHouseData.isNotEmpty ? cachedHouseData : houseData;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: dataToDisplay.entries.map((entry) {
          final item = entry.value;

          final name = item['name'] ?? 'No name';
          final price = item['price'] ?? 'N/A';
          final details = item['details'] ?? 'No details';
          final location = item['location'] ?? 'Unknown location';
          final List<dynamic> images = item['images'] ?? [];

          final String firstImage = (images.isNotEmpty && images[0] is String)
              ? images[0]
              : '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: createHorizontalCard(
              image: firstImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: firstImage,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
              name: name,
              details: details,
              price: '₦$price',
              rating: Row(
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 15),
                  SizedBox(width: 4),
                  Text('4.5 (6.2k)'),
                ],
              ),
              onBookmarkTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HousePreview(
                      image: firstImage,
                      details: details,
                      price: price,
                      name: name,
                      location: location,
                      imagelist: images.cast<String>(),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    ).animate().fade(duration: const Duration(milliseconds: 500));
  }
}
