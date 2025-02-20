import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({Key? key}) : super(key: key);

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

        setState(() {
          planDetails = prediction.split('\n').map((e) => e.trim()).toList();
          isLoading = false;
        });
      } else {
        debugPrint('Failed to load prediction: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching prediction: $e');
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Plan"),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
}
