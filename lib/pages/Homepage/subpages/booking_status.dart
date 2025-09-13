import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hunter/pages/controllers/booking_controller.dart';

class BookingOverviewPage extends StatefulWidget {
  final Booking booking;

  const BookingOverviewPage({super.key, required this.booking});

  @override
  State<BookingOverviewPage> createState() => _BookingOverviewPageState();
}

class _BookingOverviewPageState extends State<BookingOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Booking booking;
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
    _tabController = TabController(length: 2, vsync: this);
    if (booking.status == 'Completed') {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Chip UI for status
  Widget buildStatusChip(String status) {
    final isPending = status == 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)), // Slide up animation
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color.fromARGB(255, 230, 238, 244),
              Color.fromARGB(255, 139, 181, 221),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: .2),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueGrey[800],
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launch phone call
  void _launchCaller(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not launch dialer")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            /// Image Slider
            CarouselSlider(
              items: booking.images.map((img) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Center(child: Text('No preview..')),
                    placeholder: (context, url) => CircularProgressIndicator(),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            ),

            const SizedBox(height: 20),

            /// Title & Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildStatusChip(booking.status),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                booking.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),

            /// Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  /// Pending Booking Details
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailRow("Booking ID", booking.id),
                        SizedBox(height: 10),
                        detailRow("Booking Date", booking.date),
                        SizedBox(height: 10),
                        detailRow("Price", booking.price),
                        SizedBox(height: 10),
                        detailRow("Check-In", booking.checkIn),
                        SizedBox(height: 10),
                        detailRow("Check-Out", booking.checkOut),
                        SizedBox(height: 10),
                        detailRow("Payment Status", booking.paymentStatus),
                        SizedBox(height: 10),
                        detailRow("Phone", booking.phoneNumber),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _launchCaller(booking.phoneNumber),
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Call Now",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            Text('Contact agent'),
                          ],
                        ),

                        const SizedBox(height: 10),

                        if (booking.status == 'Pending')
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AppState>().updateIndexData(1);
                            },
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: const Text(
                              "Cancel Booking",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// Completed Booking Details
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailRow("Booking ID", booking.id),
                        detailRow(
                          "Stay Duration",
                          "${booking.checkIn} → ${booking.checkOut}",
                        ),
                        detailRow("Payment", booking.paymentStatus),
                        if (booking.review != null)
                          detailRow("Review", booking.review!),

                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.blue,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                          ),
                          onPressed: () {
                            ShowSnackBar().success(
                              context: context,
                              title: 'Purchase',
                              message: 'Successfully completed',
                            );
                          },
                          icon: const Icon(Icons.reviews_outlined),
                          label: const Text("Mark as Completed"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
