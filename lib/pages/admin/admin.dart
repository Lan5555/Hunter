import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';

class AdminUploadPage extends StatefulWidget {
  const AdminUploadPage({Key? key}) : super(key: key);

  @override
  State<AdminUploadPage> createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageCountController = TextEditingController();
  List<TextEditingController> _imageLinkControllers = [];

  String userId = "";

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      userId = context.read<AppState>().userId;
     
    });
  });
}

  void uploadData() async {
  if (_formKey.currentState!.validate()) {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not loaded. Try again.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading data...')),
    );

    List<String> imageLinks = _imageLinkControllers
    .map((controller) => controller.text.trim())
    .where((link) => link.isNotEmpty)
    .toList();

    final metaData = {
      'name': _nameController.text,
      'price': _priceController.text,
      'details': _detailsController.text,
      'location': _locationController.text,
      'images': imageLinks,
      'phone': _phoneController.text,
    };

    try {
      await FirebaseController().addAutoIncrementedKey('properties', userId, metaData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 249, 251, 251),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Upload'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Animate(
            effects: [
              FadeEffect(duration: 500.ms),
              SlideEffect(curve: Curves.easeOut),
            ],
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Post New Listing',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration.copyWith(labelText: 'Name'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: inputDecoration.copyWith(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter price' : null,
                  ),
                  const SizedBox(height: 16),

                  // Details
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: inputDecoration.copyWith(labelText: 'Details'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter details' : null,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: inputDecoration.copyWith(labelText: 'Location'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter location' : null,
                  ),
                  const SizedBox(height: 16),

                  // // Google Maps Link
                  // TextFormField(
                  //   controller: _linkController,
                  //   decoration: inputDecoration.copyWith(
                  //     labelText: 'Image Link',
                  //   ),
                  //   validator: (val) =>
                  //       val == null || val.isEmpty ? 'Enter link' : null,
                  // ),
                  const SizedBox(height: 16),

                  // Number of images input
                TextFormField(
                  controller: _imageCountController,
                  decoration: inputDecoration.copyWith(labelText: 'Number of Images'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    int count = int.tryParse(val) ?? 0;
                    setState(() {
                      _imageLinkControllers = List.generate(
                        count,
                        (index) => TextEditingController(),
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Image link fields
                ..._imageLinkControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: controller,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Image ${index + 1} Link',
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter image link' : null,
                    ),
                  );
                }).toList(),


                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Contact Phone Number',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter phone number'
                        : null,
                  ),

                  const SizedBox(height: 30),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: uploadData,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text(
                        'Upload',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel / Back
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
