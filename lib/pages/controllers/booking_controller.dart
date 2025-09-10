/// Booking Model
class Booking {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final String status; // "Pending" or "Completed"
  final String date;
  final String checkIn;
  final String checkOut;
  final String paymentStatus;
  final String? review; // Only for completed
  final String? phoneNumber;

  Booking({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.status,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.paymentStatus,
    this.review,
    this.phoneNumber
  });
}
