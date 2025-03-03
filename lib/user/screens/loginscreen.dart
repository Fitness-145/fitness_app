import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/admin/admindashboard.dart';
import 'package:fitness_app/trainer/trainerdashboard.dart';
import 'package:fitness_app/user/screens/forgotpassword.dart';
import 'package:fitness_app/user/screens/category.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/user/screens/signuppage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Authenticate with Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check for role in Firestore collections
      String? role = await _getRoleFromFirestore(email);

      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found with this email')),
        );
        return;
      }

      // Navigate based on the user's role
      _navigateToDashboard(role);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<String?> _getRoleFromFirestore(String email) async {
    // Check users collection
    var userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (userQuery.docs.isNotEmpty) return 'user';

    // Check trainers collection
    var trainerQuery = await _firestore
        .collection('trainer')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (trainerQuery.docs.isNotEmpty) return 'trainer';

    // Check admins collection
    var adminQuery = await _firestore
        .collection('admin')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (adminQuery.docs.isNotEmpty) return 'admin';

    return null;
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;

    if (role == 'admin') {
      dashboard = const AdminDashboard();
    } else if (role == 'trainer') {
      dashboard = const TrainerDashboard();
    } else {
      dashboard = const CustomizeInterestsScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value) ? null : 'Enter a valid email';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return value.length < 6 ? 'Password must be at least 6 characters' : null;
  }

  Widget _buildTextField(TextEditingController controller, IconData icon,
      String hintText, String? Function(String?) validator,
      {bool obscureText = false, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2)),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.bolt, color: Colors.white, size: 80),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, Icons.person,
                        'Email Address', _validateEmail),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, Icons.lock, 'Password',
                        _validatePassword,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white),
                          onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                        )),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen()),
                        ),
                        child: const Text('Forgot Password?',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('Continue',
                          style: TextStyle(color: Colors.purple, fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    // Sign up link
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
