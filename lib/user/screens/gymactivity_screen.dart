import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

// Constants for Firestore collection and field names
const String usersCollection = 'users';
const String userProgressCollection = 'userProgress';
const String fieldName = 'name';
const String fieldHeight = 'height';
const String fieldCurrentWeight = 'currentWeight';
const String fieldCurrentBmi = 'currentBmi';
const String fieldTargetWeight = 'targetWeight';
const String fieldUserId = 'userId';
const String fieldUpdatedAt = 'updatedAt';

// Screen to track user progress for weight and BMI
class ActivitiesTrackScreen extends StatefulWidget {
  final String userId; // User ID to fetch data from Firestore

  const ActivitiesTrackScreen({super.key, required this.userId});

  @override
  State<ActivitiesTrackScreen> createState() => _ActivitiesTrackScreenState();
}

class _ActivitiesTrackScreenState extends State<ActivitiesTrackScreen> {
  // Controllers for input fields
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _currentBmiController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  // State variables for user data
  String name = ''; // User's name from users collection
  double height = 0.0; // User's height (cm) from users collection
  double currentWeight = 0.0; // Current weight from userProgress or input
  double currentBmi = 0.0; // Current BMI calculated from weight and height
  double targetWeight = 0.0; // Target weight from userProgress or input
  bool isLoading = true; // Loading state for UI
  bool hasData = false; // Tracks if progress data exists

  @override
  void initState() {
    super.initState();
    _initialize(); // Initialize Firebase and fetch data
    // Add listener to currentWeightController to auto-calculate BMI
    _currentWeightController.addListener(_calculateBmi);
  }

  // Initialize Firebase and fetch user data
  Future<void> _initialize() async {
    try {
      // Ensure Firebase is initialized only once
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await _fetchAllData(); // Fetch user and progress data
    } catch (e) {
      _showMessage('Initialization error: $e'); // Show error if initialization fails
    } finally {
      setState(() => isLoading = false); // Update UI after initialization
    }
  }

  // Fetch user and progress data from Firestore
  Future<void> _fetchAllData() async {
    setState(() => isLoading = true); // Show loading indicator
    try {
      // Reference to user and progress documents
      final userDoc = FirebaseFirestore.instance.collection(usersCollection).doc(widget.userId);
      final progressDoc = FirebaseFirestore.instance.collection(userProgressCollection).doc(widget.userId);

      // Batch fetch both documents to reduce network calls
      final results = await Future.wait([
        userDoc.get(),
        progressDoc.get(),
      ]);

      final userData = results[0]; // User document
      final progressData = results[1]; // Progress document

      // Extract user data if it exists
      if (userData.exists && userData.data() != null) {
        final data = userData.data()!;
        name = data[fieldName] ?? ''; // User's name (e.g., "varun")
        height = (data[fieldHeight] ?? 0.0).toDouble(); // User's height (e.g., 174 cm)
        if (height <= 0) {
          _showMessage('Height not set in profile. Please update your profile.');
        }
      } else {
        _showMessage('User data not found.'); // Show error if user data is missing
        return;
      }

      // Extract progress data if it exists
      if (progressData.exists && progressData.data() != null) {
        final data = progressData.data()!;
        currentWeight = (data[fieldCurrentWeight] ?? 0.0).toDouble(); // Current weight
        currentBmi = (data[fieldCurrentBmi] ?? 0.0).toDouble(); // Current BMI
        targetWeight = (data[fieldTargetWeight] ?? 0.0).toDouble(); // Target weight
        // Populate text controllers
        _currentWeightController.text = currentWeight > 0 ? currentWeight.toStringAsFixed(1) : '';
        _currentBmiController.text = currentBmi > 0 ? currentBmi.toStringAsFixed(1) : '';
        _targetWeightController.text = targetWeight > 0 ? targetWeight.toStringAsFixed(1) : '';
        hasData = currentWeight > 0 && currentBmi > 0;
      }
    } catch (e) {
      _showMessage('Error fetching data: $e'); // Show error if fetching fails
    }
    setState(() => isLoading = false); // Update UI after fetching
  }

  // Calculate BMI based on weight and height
  double _calculateBmiFromWeight(double weight) {
    if (weight > 0 && height > 0) {
      final heightInMeters = height / 100; // Convert cm to meters
      return weight / (heightInMeters * heightInMeters); // BMI formula
    }
    return 0.0;
  }

  // Update currentBmi when currentWeight changes
  void _calculateBmi() {
    final weightInput = double.tryParse(_currentWeightController.text);
    if (weightInput != null && weightInput > 0 && height > 0) {
      final bmi = _calculateBmiFromWeight(weightInput);
      setState(() {
        currentBmi = bmi;
        _currentBmiController.text = bmi.toStringAsFixed(1); // Update BMI field
      });
    } else {
      setState(() {
        currentBmi = 0.0;
        _currentBmiController.text = ''; // Clear BMI if invalid
      });
    }
  }

  // Save current and target values to Firestore
  Future<void> _saveProgressData() async {
    try {
      // Save progress data to userProgress collection
      await FirebaseFirestore.instance.collection(userProgressCollection).doc(widget.userId).set({
        fieldUserId: widget.userId,
        fieldCurrentWeight: currentWeight,
        fieldCurrentBmi: currentBmi,
        fieldTargetWeight: targetWeight,
        fieldUpdatedAt: FieldValue.serverTimestamp(), // Timestamp for last update
      }, SetOptions(merge: true)); // Merge to avoid overwriting unnecessary fields
      _showMessage('Progress saved!'); // Confirm save
    } catch (e) {
      _showMessage('Error saving progress: $e'); // Show error if saving fails
    }
  }

  // Show snackbar with a message
  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // Validate and compare current progress with targets
  void _compareProgress() {
    final weightInput = double.tryParse(_currentWeightController.text); // Parse current weight
    final targetWeightInput = double.tryParse(_targetWeightController.text); // Parse target weight

    // Validate current weight
    if (weightInput == null || weightInput <= 0 || weightInput > 500) {
      _showMessage('Please enter a valid current weight (0-500 kg).');
      return;
    }
    // Validate target weight
    if (targetWeightInput == null || targetWeightInput <= 0 || targetWeightInput > 500) {
      _showMessage('Please enter a valid target weight (0-500 kg).');
      return;
    }
    // Validate height for BMI calculation
    if (height <= 0) {
      _showMessage('Height not set in profile. Please update your profile.');
      return;
    }

    // Update state with new values
    setState(() {
      currentWeight = weightInput;
      currentBmi = _calculateBmiFromWeight(weightInput); // Recalculate BMI
      targetWeight = targetWeightInput;
      hasData = true; // Indicate data is available for comparison
    });

    _saveProgressData(); // Save to Firestore
  }

  // Generate a summary note based on weight and BMI differences
  String _generateSummaryNote() {
    final weightDiffPercent = ((currentWeight - targetWeight).abs() / targetWeight) * 100;
    final targetBmi = _calculateBmiFromWeight(targetWeight);
    final bmiDiffPercent = ((currentBmi - targetBmi).abs() / targetBmi) * 100;

    if (weightDiffPercent <= 1 && bmiDiffPercent <= 1) {
      return 'Congratulations! You\'ve achieved your target weight and ideal BMI. Keep it up!';
    } else if (weightDiffPercent <= 5 || bmiDiffPercent <= 5) {
      return 'Great effort! You\'re very close to your target weight. Just a bit more to reach your ideal BMI!';
    } else if (weightDiffPercent <= 10 || bmiDiffPercent <= 10) {
      return 'Good job! You\'re making progress toward your target weight. Take some more action to achieve your ideal BMI!';
    } else {
      return 'You\'re on the right path! Keep working hard to reach your target weight and improve your BMI.';
    }
  }

  // Build a comparison card to show target vs current values
  Widget _buildComparisonCard(String title, double target, double current, Color color, {bool isBmi = false}) {
    final diff = (current - target).toStringAsFixed(1); // Calculate difference
    final status = current == target
        ? '✅ Goal Achieved'
        : current > target
            ? '⬇️ Reduce by $diff'
            : '⬆️ Increase by ${diff.replaceAll('-', '')}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 8),
            Text('Target: ${isBmi ? target.toStringAsFixed(1) : target}', style: const TextStyle(fontSize: 16)),
            Text('Current: ${isBmi ? current.toStringAsFixed(1) : current}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Build a legend for the chart to indicate green (target) and red (current) values
  Widget _buildChartLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: Colors.green.shade400,
              ),
              const SizedBox(width: 4),
              const Text('Target', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: Colors.redAccent.shade200,
              ),
              const SizedBox(width: 4),
              const Text('Current', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // Build a bar chart to visualize target vs current values
  Widget _buildChart() {
    final targetBmi = _calculateBmiFromWeight(targetWeight); // Calculate target BMI
    return Column(
      children: [
        _buildChartLegend(), // Add legend above the chart
        AspectRatio(
          aspectRatio: 1.4,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false), // Hide border
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt() == 0 ? 'Weight' : 'BMI', // Label x-axis
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(0), // Label y-axis
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: [
                // Weight comparison
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: targetWeight, color: Colors.green.shade400, width: 16), // Target weight
                    BarChartRodData(toY: currentWeight, color: Colors.redAccent.shade200, width: 16), // Current weight
                  ],
                ),
                // BMI comparison
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: targetBmi, color: Colors.green.shade400, width: 16), // Target BMI
                    BarChartRodData(toY: currentBmi, color: Colors.redAccent.shade200, width: 16), // Current BMI
                  ],
                ),
              ],
              gridData: const FlGridData(show: true, drawVerticalLine: false), // Show horizontal grid lines
            ),
          ),
        ),
      ],
    );
  }

  // Build input field with consistent styling
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')), // Allow one decimal place
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _currentWeightController.removeListener(_calculateBmi);
    _currentWeightController.dispose();
    _currentBmiController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plan'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $name 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ), // Display name from users
                  const SizedBox(height: 16),
                  const Text(
                    '🎯 Your Targets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  // Current weight and BMI in the same row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _currentWeightController,
                          label: 'Current Weight (kg)',
                          icon: Icons.monitor_weight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _currentBmiController,
                          label: 'Current BMI',
                          icon: Icons.bar_chart,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Target weight input
                  _buildInputField(
                    controller: _targetWeightController,
                    label: 'Target Weight (kg)',
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 16),
                  // Button to compare progress
                  ElevatedButton(
                    onPressed: _compareProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: Colors.white, // Set text color to white
                    ),
                    child: const Text(
                      'Compare with Target',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  // Show chart, comparison cards, and summary note if data exists
                  if (hasData && currentWeight > 0 && currentBmi > 0) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '📊 Your Progress Chart',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    _buildChart(), // Display chart with legend
                    const SizedBox(height: 20),
                    // Weight and BMI comparison cards in the same row
                    Row(
                      children: [
                        Expanded(
                          child: _buildComparisonCard('Weight', targetWeight, currentWeight, Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildComparisonCard(
                            'BMI',
                            _calculateBmiFromWeight(targetWeight),
                            currentBmi,
                            Colors.purple,
                            isBmi: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Progress Summary',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _generateSummaryNote(),
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}