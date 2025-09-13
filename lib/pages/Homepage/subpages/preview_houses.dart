import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/home.dart';
import 'package:hunter/pages/Homepage/subpages/booking_status.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/controllers/booking_controller.dart';
import 'package:hunter/pages/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HousePreview extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String details;
  final String location;
  final List<String> imagelist;

  const HousePreview({
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
  String phoneNumber = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserPhoneNumber();
  }

  Future<void> fetchUserPhoneNumber() async {
    final firestore = FirebaseFirestore.instance;
    final dataRef = firestore.collection('properties').doc('agents');
    final snapshot = await dataRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      if (data.isNotEmpty) {
        final firstAgent = data.entries.first.value;
        setState(() {
          phoneNumber = firstAgent['phone'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageSrc = widget.imagelist[0];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Top image and buttons
            Stack(
              children: [
                CarouselSlider(
                  items: List.generate(widget.imagelist.length, (index) {
                    final item = widget.imagelist[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.cover,
                        height: 330,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Text(
                            'Image not found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }),
                  options: CarouselOptions(
                    height: 330,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                  ),
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black54),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black54),
                              ],
                            ),
                            onPressed: () {
                              ShowSnackBar().success(
                                title: 'Info',
                                message: 'Click the button below',
                                context: context,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black54),
                              ],
                            ),
                            onPressed: () {
                              // ignore: deprecated_member_use
                              shareHouseDetails();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '4.2 (6.9k reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '₦${widget.price}/',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text: 'NGN',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.details,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      child: Icon(Icons.check, color: Colors.green),
                    ),
                    title: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: index == 0
                          ? Text(
                              'Payment would be done physically',
                              style: TextStyle(fontSize: 14),
                            )
                          : index == 1
                          ? Text(
                              'An Agent would be provided',
                              style: TextStyle(fontSize: 14),
                            )
                          : Text(
                              'Verified and Trusted',
                              style: TextStyle(fontSize: 14),
                            ),
                    ),
                  );
                },
              ),
            ),

            /// Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.blueAccent.withValues(alpha: .3),
                  ),
                  onPressed: () {
                    String id = generateUniqueId();
                    DateTime date = DateTime.now();
                    DateFormat format = DateFormat('yyyy-MM-dd');
                    String formatedDate = format.format(date);

                    DateTime checkOutDate = DateTime.now().add(
                      const Duration(days: 4),
                    );
                    String checkOut = format.format(checkOutDate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingOverviewPage(
                          booking: Booking(
                            id: id,
                            name: widget.name,
                            images: widget.imagelist,
                            description: widget.details,
                            status: 'Pending',
                            date: formatedDate,
                            checkIn: formatedDate,
                            checkOut: checkOut,
                            paymentStatus: 'Pending',
                            phoneNumber: phoneNumber,
                            price: widget.price,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareHouseDetails() async {
    final textToShare =
        '''
            Check out this house: ${widget.name}
            Location: ${widget.location}
            Price: ₦${widget.price}
            Details: ${widget.details}
            ''';

    await SharePlus.instance.share(ShareParams(text: textToShare));
  }

  String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000); // Random number between 0 and 9999
    return '$timestamp-$random'; // e.g., "1697059200000-1234"
  }
}
