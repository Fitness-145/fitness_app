import 'package:fitness_app/user/screens/forgotpassword.dart'; // Ensure this screen exists
// Ensure this screen exists
import 'package:fitness_app/user/screens/mainpage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Function to handle "Forgot Password" action
  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: Text('Password reset instructions will be sent to your email.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),

                // Logo at the top
                Icon(
                  Icons.bolt,
                  color: Colors.purple,
                  size: 80,
                ),
                SizedBox(height: 20),

                // Title Text
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 10),

                // Email TextField with validation
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.person,
                  hintText: 'Email Address',
                  validator: _validateEmail,
                ),
                SizedBox(height: 20),

                // Password TextField with validation and visibility toggle
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hintText: 'Password',
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),

                // Forgot Password button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Social media sign-in buttons
                Text(
                  'Sign in with',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.alternate_email), // Twitter icon replacement
                      onPressed: () {
                        // Add your Twitter sign-in logic here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.facebook),
                      onPressed: () {
                        // Add your Facebook sign-in logic here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.g_mobiledata), // Google icon replacement
                      onPressed: () {
                        // Add your Google sign-in logic here
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Continue button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logging in...')),
                      );
                      // Navigate to the next screen after successful login
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>CustomizeInterestsScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(200, 50),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 40), // Space below the button
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build a styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
