import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/baseurl.dart';
import 'package:fitness_app/user/achievement.dart';
import 'package:fitness_app/user/screens/chatbot.dart';
import 'package:fitness_app/user/screens/gymactivity_screen.dart';
import 'package:fitness_app/user/screens/profilescreen.dart';
import 'package:fitness_app/user/user_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  _MyPlanScreenState createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  List<String> planDetails = [];
  bool isLoading = false;
  bool isPlanVerified = false;
  bool showForm = true; // Track whether to show the form or output

  // Form controllers
  final _sexController = TextEditingController();
  final _ageController = TextEditingController();
  final _hypertensionController = TextEditingController();
  final _diabetesController = TextEditingController();
  final _bmiController = TextEditingController();
  final _fitnessGoalController = TextEditingController();
  final _fitnessTypeController = TextEditingController();
  int _currentIndex = 0;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Key to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchPlanDetails(); // Fetch plan details when the screen loads
  }

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

  Future<void> fetchPlanDetails() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot planSnapshot = await FirebaseFirestore.instance
            .collection('plans')
            .doc(user.uid)
            .get();

        if (planSnapshot.exists) {
          final data = planSnapshot.data() as Map<String, dynamic>;
          final isVerified = data['verified'] ?? false;

          if (isVerified) {
            final planDetails = data['planDetails'] as List<dynamic>;
            if (mounted) {
              setState(() {
                this.planDetails = planDetails.cast<String>();
                isPlanVerified = true;
                isLoading = false;
                showForm = false; // Hide the form after fetching the plan
              });
            }
          } else {
            if (mounted) {
              setState(() {
                planDetails = ["Your plan is pending verification by the trainer."];
                isPlanVerified = false;
                isLoading = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              planDetails = ["No plan found. Please create a new plan."];
              isPlanVerified = false;
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching plan details: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> savePlanToFirestore(List<String> planDetails) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference plansRef =
          FirebaseFirestore.instance.collection("plans");

      await plansRef.doc(user.uid).set({
        "planDetails": planDetails,
        "verified": false, // Initially set to false (not verified)
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  void _submitForm(
    String sex,
    String hypertension,
    String diabetes,
    String fitnessGoal,
    String fitnessType,
  ) {
    if (_formKey.currentState!.validate()) {
      final requestData = {
        "Sex": sex,
        "Age": int.tryParse(_ageController.text) ?? 0,
        "Hypertension": hypertension,
        "Diabetes": diabetes,
        "BMI": double.tryParse(_bmiController.text) ?? 0.0,
        "Fitness Goal": fitnessGoal,
        "Fitness Type": fitnessType,
      };
      fetchPlanDetailsFromAPI(requestData);
    }
  }

  Future<void> fetchPlanDetailsFromAPI(Map<String, dynamic> requestData) async {
    setState(() {
      isLoading = true;
      showForm = false; // Hide the form when fetching the plan
    });

    try {
      final response = await http.post(
        Uri.parse('$baseurl/predict'),
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

        await savePlanToFirestore(planDetails);
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
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
            icon: const Icon(Icons.message, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserMessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.purple),
              title: const Text('Achievement Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AchievementGallery()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering, color: Colors.purple),
              title: const Text('Service'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.purple),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(
              children: [
                if (showForm) // Show the form only if `showForm` is true
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildInputForm(),
                    ),
                  ),
                if (!showForm) // Show the output only if `showForm` is false
                  Expanded(
                    child: Column(
                      children: [
                        // Add a pencil icon and "Click to edit details" message
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Click to edit details',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.purple),
                                onPressed: () {
                                  setState(() {
                                    showForm = true; // Show the form again for editing
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('plans')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Colors.purple));
                              }

                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Center(child: Text('No plan found. Please create a new plan.'));
                              }

                              final data = snapshot.data!.data() as Map<String, dynamic>;
                              final isVerified = data['verified'] ?? false;
                              final planDetails = data['planDetails'] as List<dynamic>;

                              if (!isVerified) {
                                return const Center(child: Text('Your plan is pending verification by the trainer.'));
                              }

                              return ListView.builder(
                                itemCount: planDetails.length,
                                itemBuilder: (context, index) {
                                  return _buildPlanCard(planDetails[index].toString());
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.purple, // Purple background
        selectedItemColor: Colors.white, // White for selected item
        unselectedItemColor: Colors.white70, // Lighter white for unselected items
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ChatBot',
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

  Widget _buildInputForm() {
    String selectedSex = 'Male';
    String selectedHypertension = 'No';
    String selectedDiabetes = 'No';
    String selectedFitnessGoal = 'Weight Gain';
    String selectedFitnessType = 'Muscular Fitness';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button to return to plan details
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple),
                    onPressed: () {
                      setState(() {
                        showForm = false; // Go back to plan details
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Back to Plan Details',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Create a New Plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Dropdown for Sex
              DropdownButtonFormField<String>(
                value: selectedSex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSex = value!;
                },
              ),
              const SizedBox(height: 16),
              // TextField for Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Please enter a valid age (1-120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for Hypertension
              DropdownButtonFormField<String>(
                value: selectedHypertension,
                decoration: const InputDecoration(labelText: 'Hypertension'),
                items: ['No', 'Yes'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedHypertension = value!;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for Diabetes
              DropdownButtonFormField<String>(
                value: selectedDiabetes,
                decoration: const InputDecoration(labelText: 'Diabetes'),
                items: ['No', 'Yes'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDiabetes = value!;
                },
              ),
              const SizedBox(height: 16),
              // TextField for BMI
              TextFormField(
                controller: _bmiController,
                decoration: const InputDecoration(labelText: 'BMI'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your BMI';
                  }
                  final bmi = double.tryParse(value);
                  if (bmi == null || bmi < 10 || bmi > 50) {
                    return 'Please enter a valid BMI (10-50)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for Fitness Goal
              DropdownButtonFormField<String>(
                value: selectedFitnessGoal,
                decoration: const InputDecoration(labelText: 'Fitness Goal'),
                items: ['Weight Gain', 'Weight Loss'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedFitnessGoal = value!;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for Fitness Type
              DropdownButtonFormField<String>(
                value: selectedFitnessType,
                decoration: const InputDecoration(labelText: 'Fitness Type'),
                items: ['Muscular Fitness', 'Cardio Fitness'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedFitnessType = value!;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _submitForm(
                    selectedSex,
                    selectedHypertension,
                    selectedDiabetes,
                    selectedFitnessGoal,
                    selectedFitnessType,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ChatbotScreen()),
      );
    }
  }
}