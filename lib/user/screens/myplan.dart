import 'dart:convert';
import 'package:fitness_app/user/achievement.dart';
import 'package:fitness_app/user/screens/gymactivity_screen.dart';
import 'package:fitness_app/user/screens/profilescreen.dart';
import 'package:fitness_app/user/user_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'achievement_gallery.dart'; // Import the AchievementGallery screen

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  _MyPlanScreenState createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  List<String> planDetails = [];
  bool isLoading = false;

  // Form controllers
  final _sexController = TextEditingController();
  final _ageController = TextEditingController();
  final _hypertensionController = TextEditingController();
  final _diabetesController = TextEditingController();
  final _bmiController = TextEditingController();
  final _fitnessGoalController = TextEditingController();
  final _fitnessTypeController = TextEditingController();
  int _currentIndex = 0;

  // Key to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _sexController.dispose();
    _ageController.dispose();
    _hypertensionController.dispose();
    _diabetesController.dispose();
    _bmiController.dispose();
    _fitnessGoalController.dispose();
    _fitnessTypeController.dispose();
    super.dispose();
  }

  Future<void> fetchPlanDetails(Map<String, dynamic> requestData) async {
    print(requestData);
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://f704-117-221-183-209.ngrok-free.app/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prediction = data['prediction'] as String;

        if (mounted) {
          setState(() {
            planDetails = prediction.split('\n').map((e) => e.trim()).toList();
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to load prediction: ${response.statusCode}');
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error fetching prediction: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Plan Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Sex', _sexController),
                _buildTextField('Age', _ageController, isNumber: true),
                _buildTextField('Hypertension', _hypertensionController),
                _buildTextField('Diabetes', _diabetesController),
                _buildTextField('BMI', _bmiController, isNumber: true),
                _buildTextField('Fitness Goal', _fitnessGoalController),
                _buildTextField('Fitness Type', _fitnessTypeController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitForm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  void _submitForm() {
    final requestData = {
      "Sex": _sexController.text,
      "Age": int.tryParse(_ageController.text) ?? 0,
      "Hypertension": _hypertensionController.text,
      "Diabetes": _diabetesController.text,
      "BMI": double.tryParse(_bmiController.text) ?? 0.0,
      "Fitness Goal": _fitnessGoalController.text,
      "Fitness Type": _fitnessTypeController.text,
    };
    fetchPlanDetails(requestData);
  }

  Future<void> _logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear login data from local storage (SharedPreferences)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Redirect to the login screen or any screen you wish
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
        title: const Text(
          "My Plan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.message,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to UserMessageScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserMessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6, // Half-screen width
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.purple),
              title: const Text('Achievement Gallery'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AchievementGallery()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering, color: Colors.purple),
              title: const Text('Service'),
              onTap: () {
                // Handle Service
                Navigator.pop(context); // Close the drawer
                // Add navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.purple),
              title: const Text('About'),
              onTap: () {
                // Handle About
                Navigator.pop(context); // Close the drawer
                // Add navigation logic here
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: planDetails.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(planDetails[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _showInputDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'My Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String detail) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          detail,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigate to corresponding screens based on index
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyActivitiesPage()),
      );
    }
  }
}