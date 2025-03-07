import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePlanScreen extends StatefulWidget {
  @override
  _CreatePlanScreenState createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  bool showForm = true;

  String selectedSex = 'Male';
  String selectedHypertension = 'No';
  String selectedDiabetes = 'No';
  String selectedFitnessGoal = 'Weight Gain';
  String selectedFitnessType = 'Muscular Fitness';

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateBMI();
  }

  Future<void> _fetchAndCalculateBMI() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        if (userData['role'] == 'user') {
          double weight = (userData['weight'] as num).toDouble();
          double height = (userData['height'] as num).toDouble();
          int age = (userData['age'] as num).toInt();

          if (height > 0) {
            double bmi = weight / ((height / 100) * (height / 100));

            // Update Firestore with calculated BMI
            await FirebaseFirestore.instance.collection('users').doc(uid).update({
              'bmi': bmi,
            });

            // Update UI
            setState(() {
              _bmiController.text = bmi.toStringAsFixed(2);
              _ageController.text = age.toString();
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you can save the form data to Firestore or use it for other processing
      print("Form submitted successfully!");
      print("Sex: $selectedSex");
      print("Age: ${_ageController.text}");
      print("Hypertension: $selectedHypertension");
      print("Diabetes: $selectedDiabetes");
      print("BMI: ${_bmiController.text}");
      print("Fitness Goal: $selectedFitnessGoal");
      print("Fitness Type: $selectedFitnessType");

      // You may also save the data to Firestore if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a New Plan")),
      body: _buildInputForm(),
    );
  }

  Widget _buildInputForm() {
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
                  setState(() {
                    selectedSex = value!;
                  });
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
                  setState(() {
                    selectedHypertension = value!;
                  });
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
                  setState(() {
                    selectedDiabetes = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // TextField for BMI (Auto-Filled)
              TextFormField(
                controller: _bmiController,
                decoration: const InputDecoration(labelText: 'BMI'),
                keyboardType: TextInputType.number,
                readOnly: true, // Prevent manual entry
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
                  setState(() {
                    selectedFitnessGoal = value!;
                  });
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
                  setState(() {
                    selectedFitnessType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
