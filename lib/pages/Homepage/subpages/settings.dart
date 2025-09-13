import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/admin/admin.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/login/login.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationsEnabled = true;
  bool isDarkMode = false;
  ShowSnackBar snackBar = ShowSnackBar();
  Map<String, dynamic> userDetails = {};
  final GlobalKey<FormState> _globalKey = GlobalKey();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final GlobalKey<FormState> _globalKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AppState>().userId;
      _fetchUserDetails(userId);
    });
  }

  Future<void> _fetchUserDetails(String userId) async {
    try {
      final userData = await FirebaseController().fetchData('users', userId);
      if (userData.isNotEmpty) {
        setState(() {
          userDetails = userData;
          _number.text = userDetails['phone'] ?? '';
          _userName.text = userDetails['username'] ?? '';
        });
      } else {
        ShowSnackBar().warning(
          title: 'Error',
          message: 'Failed to load user data',
          context: context,
        );
      }
    } catch (e) {
      ShowSnackBar().warning(
        title: 'Error',
        message: 'Failed to load user data + $e',
        context: context,
      );
    }
  }

  void resetPrefState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('login');
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers, unnecessary_new
    final TextEditingController _controller = new TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    void loadAdminPage() {
      if (_controller.text != '' && _controller.text == '3548') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminUploadPage()),
        );
      } else {
        snackBar.warning(
          title: 'Warning',
          message: 'Invalid key',
          context: context,
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(
                            "assets/images/house.jpg",
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    userDetails['username'] != null
                        ? Text(
                            userDetails['username'] ?? "",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : CircularProgressIndicator(strokeWidth: 1),
                    const SizedBox(height: 4),
                    Text(
                      userDetails['email'] ?? "",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Section Title
              const Text(
                "Account Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              /// Edit Profile
              buildSettingsTile(
                icon: Icons.person,
                title: "Edit Profile",
                onTap: () {
                  buildBottomSheet(
                    context,
                    widget: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          left: 16,
                          right: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildSheetHeader(title: 'Edit Profile'),
                            const SizedBox(height: 20),
                            // More content here
                            Form(
                              key: _globalKey,
                              child: Column(
                                children: [
                                  Text('Edit your user name..'),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    focusNode: _focusNode,
                                    controller: _userName,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('User name'),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.blueAccent,
                                        ),
                                        foregroundColor: WidgetStatePropertyAll(
                                          Colors.white,
                                        ),
                                      ),
                                      icon: Icon(Icons.update),
                                      onPressed: () async {
                                        if (_globalKey.currentState!
                                            .validate()) {
                                          try {
                                            final data =
                                                await FirebaseController()
                                                    .updateValue(
                                                      context
                                                          .read<AppState>()
                                                          .userId,
                                                      _userName.text,
                                                      'username',
                                                    );
                                            if (data['success'] == true) {
                                              ShowSnackBar().success(
                                                context: context,
                                                title: 'Info',
                                                message: 'Updated Successfully',
                                              );
                                              setState(() {
                                                userDetails['username'] =
                                                    _userName.text;
                                              });
                                            }
                                          } catch (e) {
                                            ShowSnackBar().warning(
                                              context: context,
                                              title: 'warning',
                                              message: 'Failed $e',
                                            );
                                          }
                                        }
                                      },
                                      label: Text('Confirm'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              /// Change Password
              buildSettingsTile(
                icon: Icons.lock_outline,
                title: "Change Phone Number",
                onTap: () {
                  // Navigate to change phone number
                  buildBottomSheet(
                    context,
                    widget: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          left: 16,
                          right: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildSheetHeader(title: 'Edit Profile'),
                            const SizedBox(height: 20),
                            // More content here
                            Form(
                              key: _globalKey2,
                              child: Column(
                                children: [
                                  Text('Edit your Phone number..'),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    focusNode: _focusNode,
                                    controller: _number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text('Phone number'),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.blueAccent,
                                        ),
                                        foregroundColor: WidgetStatePropertyAll(
                                          Colors.white,
                                        ),
                                      ),
                                      icon: Icon(Icons.update),
                                      onPressed: () async {
                                        if (_globalKey2.currentState!
                                            .validate()) {
                                          try {
                                            final data =
                                                await FirebaseController()
                                                    .updateValue(
                                                      context
                                                          .read<AppState>()
                                                          .userId,
                                                      _number.text,
                                                      'phone',
                                                    );
                                            if (data['success'] == true) {
                                              ShowSnackBar().success(
                                                context: context,
                                                title: 'Info',
                                                message: 'Updated Successfully',
                                              );
                                              setState(() {
                                                userDetails['phone'] =
                                                    _number.text;
                                              });
                                            }
                                          } catch (e) {
                                            ShowSnackBar().warning(
                                              context: context,
                                              title: 'warning',
                                              message: 'Failed $e',
                                            );
                                          }
                                        }
                                      },
                                      label: Text('Confirm'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              /// Notification Toggle
              buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: "Notifications",
                value: isNotificationsEnabled,
                onChanged: (value) {
                  setState(() => isNotificationsEnabled = value);
                },
              ),

              // /// Theme Toggle (Dark Mode)
              // buildSwitchTile(
              //   icon: Icons.dark_mode_outlined,
              //   title: "Dark Mode",
              //   value: isDarkMode,
              //   onChanged: (value) {
              //     setState(() => isDarkMode = value);
              //   },
              // ),
              buildSettingsTile(
                icon: Icons.today_outlined,
                title: "Miscellaneous",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Access',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Input password';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter key',
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      loadAdminPage();
                                    }
                                  },
                                  child: const Text('Login'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              /// Other Section
              const Text(
                "Support",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              buildSettingsTile(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: () {
                  buildBottomSheet(
                    context,
                    widget: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '🛠 Help & Support\n\n',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Booking
                            TextSpan(
                              text: '💡 How do I book a house?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  '1. Browse listings.\n'
                                  '2. Tap a property to view details.\n'
                                  '3. Click “Book Now” and select your dates.\n'
                                  '4. Confirm your booking and make payment.\n\n',
                            ),

                            // Modify Booking
                            TextSpan(
                              text: '🗓 Can I modify or cancel my booking?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Yes! Go to My Bookings → Select booking → Edit or Cancel.\n'
                                  'Note: Cancellation policies vary by host.\n\n',
                            ),

                            // Payment
                            TextSpan(
                              text: '💰 How does payment work?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Payment is done by a physical meet '
                                  'You’ll receive confirmation once payment is successful.\n\n',
                            ),

                            // Issues
                            TextSpan(
                              text:
                                  '🛎 What if I have an issue with a host or property?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  '1. Contact the host via the Messages tab.\n'
                                  '2. Tap "Report Issue" in your booking.\n'
                                  '3. Our support team will respond within 24 hours.\n\n',
                            ),

                            // Security
                            TextSpan(
                              text: '🔒 Is my data secure?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Yes. We use encryption and never share your data without consent.\n\n',
                            ),

                            // Date Selection
                            TextSpan(
                              text: '📅 Why can’t I select certain dates?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Dates may be unavailable due to existing bookings or host rules.\n\n',
                            ),

                            // Reviews
                            TextSpan(
                              text: '✍️ Can I leave a review?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Yes! Go to My Bookings → Completed stay → Leave a review.\n\n',
                            ),

                            // Receipts
                            TextSpan(
                              text: '🧾 Where can I find my receipts?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Receipts are available in My Bookings → Tap booking → Download Receipt.\n\n',
                            ),

                            // Contact
                            TextSpan(
                              text: '📞 Need More Help?\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Email: huntershaven333@gmail.com\n'
                                  'Phone: +234 810 772 4456\n',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () {
                  buildBottomSheet(
                    context,
                    widget: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '🔐 Privacy Policy\n\n',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextSpan(
                              text: 'Last Updated: September 12, 2025\n\n',
                              style: TextStyle(color: Colors.grey),
                            ),

                            // Introduction
                            TextSpan(
                              text: '📌 Introduction\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We value your privacy and are committed to protecting your personal information. This policy explains how we collect, use, and store your data.\n\n',
                            ),

                            // Data Collection
                            TextSpan(
                              text: '📥 What We Collect\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We collect personal information such as:\n'
                                  '- Name\n'
                                  '- Email address\n'
                                  '- Phone number\n'
                                  '- Booking history\n'
                                  '- Payment details (processed securely)\n\n',
                            ),

                            // Data Usage
                            TextSpan(
                              text: '📊 How We Use Your Data\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Your data helps us to:\n'
                                  '- Process bookings and payments\n'
                                  '- Send confirmations and updates\n'
                                  '- Improve app performance\n'
                                  '- Prevent fraud and ensure safety\n\n',
                            ),

                            // Data Sharing
                            TextSpan(
                              text: '🔗 Data Sharing\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We do not sell your data. We only share it with:\n'
                                  '- Verified hosts (limited information)\n'
                                  '- Payment providers (for transaction processing)\n'
                                  '- Legal authorities (if required by law)\n\n',
                            ),

                            // User Rights
                            TextSpan(
                              text: '🧑‍⚖️ Your Rights\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You can:\n'
                                  '- View or update your profile information\n'
                                  '- Delete your account\n'
                                  '- Request access to the data we store\n\n',
                            ),

                            // Security
                            TextSpan(
                              text: '🔒 Security\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We use encryption and secure servers to protect your data.\n'
                                  'We regularly review and update our security practices.\n\n',
                            ),

                            // Cookies (if applicable)
                            TextSpan(
                              text: '🍪 Cookies\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We may use cookies to personalize your experience and improve performance.\n\n',
                            ),

                            // Changes to Policy
                            TextSpan(
                              text: '📄 Policy Updates\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We may update this policy from time to time. We will notify you of significant changes via the app or email.\n\n',
                            ),

                            // Contact Info
                            TextSpan(
                              text: '📞 Contact Us\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'If you have any questions or concerns, please contact us at:\n'
                                  'Phone: +234 810 772 4456\n'
                                  'Email: huntershaven333@gmail.com\n',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              buildSettingsTile(
                icon: Icons.info_outline,
                title: "About App",
                onTap: () {
                  buildBottomSheet(context,height: 150, widget:
                  SingleChildScrollView(
                    child: Padding(padding: EdgeInsets.all(16),
                    child: Text.rich(
                      TextSpan(
                    children: [
                        TextSpan(text:
                         '🏡 Hunter..\n'
                         'huntershaven333@gmail.com\n'
                         'Micheal Obieze x Nicholas Johnson\n'
                         'All rights reserved.',
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'GowunBatang'))
                        ])
                      ),
                    ),
                  ));
                },
              ),

              const SizedBox(height: 30),

              /// Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Perform logout
                    resetPrefState();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HunterAuthPage()),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable Tile
  Widget buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  /// Reusable Switch Tile
  Widget buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

Future<dynamic> buildBottomSheet(BuildContext context, {Widget? widget, double? height}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: height ?? 600,
        width: MediaQuery.of(context).size.width,
        child: widget ?? const SizedBox.shrink(),
      ),
    ),
  );
}

Widget buildSheetHeader({String title = ''}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Divider(height: 4, thickness: 1),
      ],
    ),
  );
}
