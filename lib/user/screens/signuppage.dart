import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/user/screens/loginscreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedGender; // Added gender selection variable

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    if (_selectedGender == null) { // Added gender validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }


    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Authentication
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'height': double.parse(_heightController.text.trim()),
        'weight': double.parse(_weightController.text.trim()),
        'phone': _phoneController.text.trim(),
        'role': 'user',
        'gender': _selectedGender, // Save selected gender
        'created_at': Timestamp.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        // <-- Wrapped Container with SizedBox
        height: MediaQuery.of(context).size.height,
        // <-- Set SizedBox height to screen height
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
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      icon: Icons.person,
                      hintText: 'Full Name',
                      validator: _validateName,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email,
                      hintText: 'Email Address',
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _ageController,
                      icon: Icons.cake,
                      hintText: 'Age',
                      keyboardType: TextInputType.number,
                      validator: _validateAge,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _heightController,
                      icon: Icons.height,
                      hintText: 'Height (in cm)',
                      keyboardType: TextInputType.number,
                      validator: _validateHeight,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _weightController,
                      icon: Icons.monitor_weight,
                      hintText: 'Weight (in kg)',
                      keyboardType: TextInputType.number,
                      validator: _validateWeight,
                    ),
                    const SizedBox(height: 15),
                    // Gender selection starts here
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 8.0),
                        child: Text(
                          'Gender',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Radio<String>(
                          value: 'male',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        const Text('Male', style: TextStyle(color: Colors.white)),
                        Radio<String>(
                          value: 'female',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        const Text('Female', style: TextStyle(color: Colors.white)),
                        Radio<String>(
                          value: 'not_to_say',
                          groupValue: _selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        const Text('Not to say', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    // Gender selection ends here
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hintText: 'Password',
                      obscureText: !_isPasswordVisible,
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.purple)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.purple),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
        .hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r"^\d{10}").hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
      return 'Please enter a valid age (must be a positive number)';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter a valid height (must be a positive number)';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enter a valid weight (must be a positive number)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}