import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedCategoryIndex = 0;
  Map<String, dynamic> houseData = {};
  String userId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        userId = context.read<AppState>().userId;
      });
      loadHouseData();
    });
  }

  void loadHouseData() async {
    await FirebaseController()
        .fetchData('properties', 'agents')
        .then((data) {
          setState(() {
            houseData = data;
          });
        })
        .catchError((error) {
          if (kDebugMode) {
            print('Error fetching house data: $error');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Category Section
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCategory(
                      index: 0,
                      icon: Icons.apartment,
                      isActive: _selectedCategoryIndex == 0,
                      name: Text('Apartment'),
                      onTap: () => {
                        context.read<AppState>().updateIndexData(1),
                        setState(() => _selectedCategoryIndex = 0),
                      },
                    ),
                    buildCategory(
                      index: 1,
                      icon: Icons.place_rounded,
                      isActive: _selectedCategoryIndex == 1,
                      name: Text('Places'),
                      onTap: () => {
                        context.read<AppState>().updateIndexData(1),
                        setState(() => _selectedCategoryIndex = 1),
                      },
                    ),
                    buildCategory(
                      index: 2,
                      icon: Icons.house_siding_rounded,
                      isActive: _selectedCategoryIndex == 2,
                      name: Text('Hostels'),
                      onTap: () => {
                        context.read<AppState>().updateIndexData(1),
                        setState(() => _selectedCategoryIndex = 2),
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, curve: Curves.easeOut),

            const SizedBox(height: 30),

            /// Popular Apartments Header
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Apartments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().updateIndexData(1);
                      },
                      child: const Text('See all'),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.1, curve: Curves.easeOut),

            const SizedBox(height: 20),

            /// Carousel Slider
            houseData.entries.isNotEmpty
                ? CarouselSlider(
                    items: houseData.entries.map((entry) {
                      final value = entry.value;
                      final name = value['name'] ?? 'No name';
                      final price = value['price'] ?? 'N/A';
                      final images = value['images'] ?? [];
                      final image = images.isNotEmpty
                          ? images[0]
                          : 'assets/images/house.jpg';

                      return createCard(
                        onBookmarkTap: () {
                          context.read<AppState>().updateIndexData(1);
                        },
                        
                        image: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 170,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/house.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                        name: name,
                        details: value['details'] ?? '',
                        price: '₦$price',
                        rating: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 4),
                            Text('4.9 (6.5k)'),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale();
                    }).toList(),
                    options: CarouselOptions(
                      height: 290,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      enlargeCenterPage: true,
                      viewportFraction: 0.75
                    ),
                  )
                : Container(
                    height: 290,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(33, 40, 50, 0.15),
                          spreadRadius: 0.0,
                          blurRadius: 24,
                          offset: Offset(0, 0.15 * 24),
                        ),
                      ],
                    ),
                    child: Center(child: Text('Loading...')),
                  ),

            const SizedBox(height: 30),

            /// Low Budget Section
            Text(
                  'Explore...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.2, curve: Curves.easeOut),

            const SizedBox(height: 20),

            /// Horizontal Cards
            Column(
              children: houseData.entries.map((entry) {
                final value = entry.value;
                final name = value['name'] ?? 'No name';
                final price = value['price'] ?? 'N/A';

                final images = value['images'] as List<dynamic>? ?? [];

                // Use first image if available, fallback to local asset
                final firstImage = (images.isNotEmpty && images[0] is String)
                    ? images[0]
                    : 'assets/images/house.jpg';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: createHorizontalCard(
                    onBookmarkTap: () {
                      context.read<AppState>().updateIndexData(1);
                    },
                    image: CachedNetworkImage(
                      imageUrl: firstImage,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/house.jpg',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        );
                      },
                    ),
                    name: name,
                    details: value['details'] ?? '',
                    price: '₦$price',
                    rating: Row(
                      children: const [
                        Text('5.0 (7.5k)'),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.amber),
                      ],
                    ),
                  ).animate().fadeIn(delay: (200 * 3).ms).slideX(begin: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05);
  }

  /// Helper for building category icons
  Widget buildCategory({
    required int index,
    required IconData icon,
    required bool isActive,
    required Widget name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.blue : Colors.black54),
            const SizedBox(height: 6),
            DefaultTextStyle(
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              child: name,
            ),
          ],
        ),
      ),
    );
  }
}
