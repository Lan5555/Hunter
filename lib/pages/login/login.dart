import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hunter/pages/Homepage/home.dart';
import 'package:hunter/pages/Homepage/subpages/settings.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/admin/admin.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HunterAuthPage extends StatefulWidget {
  const HunterAuthPage({super.key});

  @override
  State<HunterAuthPage> createState() => _HunterAuthPageState();
}

class _HunterAuthPageState extends State<HunterAuthPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseController firebaseController = FirebaseController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController controller = TextEditingController();

  //Login variables
  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isExtended = false;

  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool acceptTerms = false;
  bool _loading = false;

  final GlobalKey<FormState> _formKey4 = GlobalKey();

  void loadAdminPage() {
    if (controller.text != '' && controller.text == '3548') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminUploadPage()),
      );
    } else {
      ShowSnackBar().warning(
        title: 'Warning',
        message: 'Invalid key',
        context: context,
      );
    }
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      acceptTerms = false;
    });

    // Clear unused fields to prevent stale data
    if (isLogin) {
      usernameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } else {
      emailLoginController.clear();
      passwordLoginController.clear();
    }
  }

  Future<void> _submit() async {
    if (!isLogin && !acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms and conditions'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        UserCredential userCredential;

        if (isLogin) {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: emailLoginController.text.trim(),
            password: passwordLoginController.text,
          );
          _focusNode.unfocus();
        } else {
          if (passwordController.text != confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Passwords do not match')),
            );
            setState(() => _loading = false);
            return;
          }

          userCredential = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

          await userCredential.user?.updateDisplayName(
            usernameController.text.trim(),
          );
          await userCredential.user?.reload();

          // 🔐 Add user to Firestore only during registration
          final user = _auth.currentUser;
          if (user != null) {
            final userDoc = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid);
            final docSnap = await userDoc.get();

            if (!docSnap.exists) {
              await firebaseController.addData('users', user.uid, {
                'id': user.uid,
                'email': user.email,
                'username': user.displayName ?? usernameController.text.trim(),
                'phone': phoneController.text,
              });
            }
          }
        }

        final user = _auth.currentUser;
        if (user != null) {
          ShowSnackBar().success(
            title: 'Success',
            message: isLogin
                ? 'Logged in successfully'
                : 'Account created successfully',
          );

          if (!mounted) return;

          context.read<AppState>().updateData(user.uid);
          setLoginPrefs(user.uid);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication error')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);

    try {
      final userCredential = await firebaseController.signInWithGoogle();
      final user = userCredential?.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnap = await userDoc.get();

        if (!docSnap.exists) {
          await firebaseController.addData('users', user.uid, {
            'id': user.uid,
            'email': user.email,
            'username': user.displayName ?? usernameController.text.trim(),
            'phone': phoneController.text,
          });
        }

        if (!docSnap.exists) {
          await firebaseController.addData('users', user.uid, {
            'id': user.uid,
            'email': user.email,
            'username': user.displayName ?? 'Unknown',
          });
        }

        ShowSnackBar().success(
          title: 'Success',
          message: 'Signed in with Google',
        );

        if (!mounted) return;

        context.read<AppState>().updateData(user.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.indigo) : null,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  void checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('login') ?? false;

    if (isLoggedIn) {
      final String? userId = prefs.getString('userId');

      if (userId != null && context.mounted) {
        // Update your global app state with the user ID
        context.read<AppState>().updateData(userId);

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  void setLoginPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    await prefs.setString('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 249),
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: isExtended
            ? FloatingActionButton.extended(
                key: ValueKey("extended"),
                onPressed: () {
                  setState(() => isExtended = !isExtended);
                },
                icon: Icon(Icons.support_agent),
                label: Text('Agent'),
              )
            : FloatingActionButton(
                key: ValueKey("collapsed"),
                onPressed: () {
                  setState(() => isExtended = !isExtended);
                  Timer(Duration(seconds: 1), () {
                    setState(() {
                      isExtended = false;
                    });
                  });
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Form(
                          key: _formKey4,
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
                                controller: controller,
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
                                    if (_formKey4.currentState!.validate()) {
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
                child: Icon(Icons.support_agent),
              ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hunter',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo.shade700,
                  letterSpacing: 8,
                  fontFamily: 'GowunBatang',
                ),
              ),
              const SizedBox(height: 28),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(33, 40, 50, 0.15),
                      spreadRadius: 0.0,
                      blurRadius: 24,
                      offset: Offset(0, 0.15 * 24),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 400),
                      firstChild: buildLoginForm(),
                      secondChild: buildRegisterForm(),
                      crossFadeState: isLogin
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: _loading ? null : toggleForm,
                child: Text(
                  isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                  style: TextStyle(
                    color: Colors.indigo.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.indigo.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.indigo.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.indigo.shade200)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handleGoogleSignIn,
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 24,
                    width: 24,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.indigo.shade900,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: Duration(seconds: 1));
  }

  Widget buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            color: Colors.indigo.shade700,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 28),

        TextFormField(
          controller: emailLoginController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Email', icon: Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (!isLogin) return null;
            if (val == null || !val.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          focusNode: _focusNode,
          controller: passwordLoginController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Password', icon: Icons.lock_outline),
          obscureText: true,
          validator: (val) {
            if (!isLogin) return null;
            if (val == null || val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildRegisterForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            color: Colors.indigo.shade700,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 28),

        TextFormField(
          controller: usernameController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Username', icon: Icons.person_outline),
          validator: (val) {
            if (isLogin) return null;
            if (val == null || val.trim().length < 3) {
              return 'Enter a valid username (3+ characters)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: emailController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Email', icon: Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (isLogin) return null;
            if (val == null || !val.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: phoneController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(
            'Phone Number',
            icon: Icons.phone_outlined,
          ),
          keyboardType: TextInputType.phone,
          validator: (val) {
            if (isLogin) return null;
            if (val == null || val.trim().length < 7) {
              return 'Enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: passwordController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Password', icon: Icons.lock_outline),
          obscureText: true,
          validator: (val) {
            if (isLogin) return null;
            if (val == null || val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: confirmPasswordController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(
            'Confirm Password',
            icon: Icons.lock_outline,
          ),
          obscureText: true,
          validator: (val) {
            if (isLogin) return null;
            if (val == null || val.length < 6) {
              return 'Confirm your password';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Checkbox(
              value: acceptTerms,
              onChanged: (val) {
                setState(() {
                  acceptTerms = val ?? false;
                });
              },
              activeColor: Colors.indigo,
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  // You can open terms page here
                  buildBottomSheet(
                    context,
                    widget: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '📜 Terms of Service\n\n',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextSpan(
                              text: 'Last Updated: September 12, 2025\n\n',
                              style: TextStyle(color: Colors.grey),
                            ),

                            // Acceptance
                            TextSpan(
                              text: '✅ Acceptance of Terms\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'By using this app, you agree to comply with these Terms of Service and all applicable laws and regulations.\n\n',
                            ),

                            // App Use
                            TextSpan(
                              text: '📲 Use of the App\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You may use this app to browse listings, make bookings, communicate with hosts, and manage your account. Misuse of the platform for illegal or harmful activities is strictly prohibited.\n\n',
                            ),

                            // Accounts
                            TextSpan(
                              text: '👤 Account Responsibilities\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account.\n\n',
                            ),

                            // Bookings
                            TextSpan(
                              text: '🏡 Bookings\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'When you book a property, you agree to abide by the host’s rules, cancellation policy, and any terms displayed during the booking process.\n\n',
                            ),

                            // Payments
                            TextSpan(
                              text: '💳 Payments\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'All payments are processed securely. Refunds are subject to the cancellation policy associated with each property.\n\n',
                            ),

                            // Prohibited Activities
                            TextSpan(
                              text: '🚫 Prohibited Activities\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You may not:\n'
                                  '- Use false information\n'
                                  '- Harass or impersonate others\n'
                                  '- Violate any laws or regulations\n'
                                  '- Upload malicious code or spam\n\n',
                            ),

                            // Suspension
                            TextSpan(
                              text: '⚠️ Suspension or Termination\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We reserve the right to suspend or terminate your account for violating these terms, or for any behavior that compromises safety or user experience.\n\n',
                            ),

                            // Liability
                            TextSpan(
                              text: '🛡 Limitation of Liability\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We are not liable for any damages arising from the use or inability to use the app, including any interactions with hosts or guests.\n\n',
                            ),

                            // Changes to Terms
                            TextSpan(
                              text: '📝 Updates to These Terms\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We may update these Terms of Service from time to time. Continued use of the app constitutes acceptance of the updated terms.\n\n',
                            ),

                            // Contact
                            TextSpan(
                              text: '📞 Contact Us\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'For any questions, please contact us at:\n'
                                  'Email: huntershaven333@gmail.com\n'
                                  'Phone: +234 810 772 4456\n',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'I accept the Terms and Conditions',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
