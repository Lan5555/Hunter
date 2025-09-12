import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/admin/admin.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/login/login.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';

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
                  // Navigate to profile editing page
                },
              ),

              /// Change Password
              buildSettingsTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                  // Navigate to change password
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

              /// Theme Toggle (Dark Mode)
              buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                value: isDarkMode,
                onChanged: (value) {
                  setState(() => isDarkMode = value);
                },
              ),
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
                onTap: () {},
              ),
              buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () {},
              ),
              buildSettingsTile(
                icon: Icons.info_outline,
                title: "About App",
                onTap: () {},
              ),

              const SizedBox(height: 30),

              /// Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Perform logout
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
