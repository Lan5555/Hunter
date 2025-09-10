import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/widgets/card.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedCategoryIndex = 0;

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
                  onTap: () => setState(() => _selectedCategoryIndex = 0),
                ),
                buildCategory(
                  index: 1,
                  icon: Icons.place_rounded,
                  isActive: _selectedCategoryIndex == 1,
                  name: Text('Places'),
                  onTap: () => setState(() => _selectedCategoryIndex = 1),
                ),
                buildCategory(
                  index: 2,
                  icon: Icons.house_siding_rounded,
                  isActive: _selectedCategoryIndex == 2,
                  name: Text('Hostels'),
                  onTap: () => setState(() => _selectedCategoryIndex = 2),
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
                  onPressed: () {},
                  child: const Text('See all'),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.1, curve: Curves.easeOut),

            const SizedBox(height: 20),

            /// Carousel Slider
            CarouselSlider(
              items: List.generate(
                3,
                (index) => createCard(
                  image: 'assets/images/house.jpg',
                  name: 'Modern House #${index + 1}',
                  details: 'Spacious & elegant',
                  price: '₦${(5000 + index * 1500).toString()}',
                  rating: Row(children: const [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('4.9 (6.5k)'),
                  ]),
                ).animate().fadeIn(duration: 600.ms).scale(),
              ),
              options: CarouselOptions(
                height: 290,
                autoPlay: true,
                // enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 4),
              ),
            ),

            const SizedBox(height: 30),

            /// Low Budget Section
            Text(
              'Low Budget Apartments',
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
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: createHorizontalCard(
                    image: 'assets/images/house.jpg',
                    name: 'Cozy Home #${index + 1}',
                    details: 'Good location, WiFi, water...',
                    price: '₦${(20000 + index * 5000).toString()}',
                    rating: Row(children: const [
                      Text('5.0 (7.5k)'),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber),
                    ]),
                  ).animate().fadeIn(delay: (200 * index).ms).slideX(begin: 0.1),
                ),
              ),
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
