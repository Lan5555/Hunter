import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hunter/pages/Homepage/home.dart';
import 'package:hunter/pages/Homepage/widgets/snackbar.dart';
import 'package:hunter/pages/controllers/firebase_controller.dart';
import 'package:hunter/pages/provider/provider.dart';
import 'package:provider/provider.dart';

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
  TextEditingController confirmPasswordController =TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  //Login variables
  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool acceptTerms = false;
  bool _loading = false;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      acceptTerms = false;
    });
  }

  Future<void> _submit() async {
  if (!isLogin && !acceptTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must accept the terms and conditions')),
    );
    return;
  }
  setState(() => _loading = true);

  try {
    UserCredential userCredential;

    if (isLogin) {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text,
      );
      if (userCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
        setState(() => _loading = false);
        return;
      }else{
        await userCredential.user?.reload();  // Refresh user info
        if(!mounted) return;  // Ensure context is valid
        final user = _auth.currentUser;
        context.read<AppState>().updateData(user!.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }

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

      await userCredential.user?.updateDisplayName(usernameController.text.trim());
      await userCredential.user?.reload();  // Refresh user info
    }

    final user = _auth.currentUser; // Updated user object after reload

    if (user != null) {
      await firebaseController.addData('users', user.uid, {
        'id': user.uid,
        'email': user.email,
        'username': user.displayName ?? usernameController.text.trim(),
        'phone': phoneController.text,
      });

      ShowSnackBar().success(
        title: 'Success',
        message: isLogin ? 'Logged in successfully' : 'Account created successfully',
      );

      if (!mounted) return;  // Ensure context is valid

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


  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);

    try {
      final userCredential = await firebaseController.signInWithGoogle();
      final user = userCredential!.user;

      if (user != null) {
        await firebaseController.addData('users', user.uid, {
          'id': user.uid,
          'email': user.email,
          'username': user.displayName ?? 'Unknown',
        });

        ShowSnackBar().success(
          title: 'Success',
          message: 'Signed in with Google',
        );

        // ✅ Navigate to Homepage
        if (!mounted) return;  // Ensure context is valid
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
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

              Card(
                elevation: 14,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                shadowColor: Colors.indigo.withValues(alpha: .3),
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
    );
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
            if (val == null || !val.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
          
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: passwordLoginController,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration('Password', icon: Icons.lock_outline),
          obscureText: true,
          validator: (val) {
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
              elevation: 8,
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
            onPressed: (){
              _submit();

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
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
