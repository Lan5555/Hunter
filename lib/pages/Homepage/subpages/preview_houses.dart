import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/home.dart';
import 'package:hunter/pages/Homepage/widgets/filled_button.dart';

class HousePreview extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String details;
  final String location;
  final List<String> imagelist;

  HousePreview({
    super.key,
    required this.image,
    required this.name,
    required this.details,
    required this.price,
    required this.location,
    required this.imagelist,
  });

  @override
  Preview createState() => Preview();
}

class Preview extends State<HousePreview> {
  @override
  Widget build(BuildContext context) {
    String? imageSrc = widget.imagelist[0];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// Top image and buttons
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 350,
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    filledButton(
                      item: const Icon(Icons.arrow_back),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                    Row(
                      children: [
                        filledButton(
                          item: const Icon(Icons.bookmark),
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        filledButton(
                          item: const Icon(Icons.share),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Scrollable content + Book Now button
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '4.2 (6.9k reviews)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.price}/',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: 'NGN',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(widget.details, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  const Text(
                    'Building Includes',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider(
                    items: widget.imagelist.map((item) {
                      return filledButton(
                        item: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imageSrc ?? item,
                            fit: BoxFit.cover,
                            height: 90,
                            width: 100,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            imageSrc = item;
                          });
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 90,
                      viewportFraction: 0.35,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Book Now Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle booking action
                },
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
