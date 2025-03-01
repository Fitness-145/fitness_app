import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  _MyActivitiesScreenState createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen> {
  List<String> activities = []; // List to hold activity logs
  double totalCaloriesBurned = 0.0; // For tracking total calories burned
  String fitnessGoal = 'Lose Weight'; // This should be based on the plan

  final _activityController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // Save activity to shared preferences or database
  Future<void> _saveActivity() async {
    final activity = _activityController.text;
    final duration = int.tryParse(_durationController.text) ?? 0;
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;

    if (activity.isEmpty || duration <= 0 || calories <= 0.0) {
      // Validation
      return;
    }

    setState(() {
      activities.add('$activity - $duration min - ${calories.toStringAsFixed(1)} cal');
      totalCaloriesBurned += calories; // Track total calories burned
    });

    // Clear input fields
    _activityController.clear();
    _durationController.clear();
    _caloriesController.clear();

    // Optionally save to local storage (SharedPreferences, Firebase, etc.)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('activities', activities);
  }

  // Load activities from storage
  Future<void> _loadActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      activities = prefs.getStringList('activities') ?? [];
    });
  }

  // Calculate progress towards fitness goal (e.g., calories burned vs. goal)
  double _calculateGoalProgress() {
    // For example, we assume a weight loss goal that requires burning 3000 calories
    const double goalCalories = 3000;
    return (totalCaloriesBurned / goalCalories) * 100;
  }

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Tracking'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(  // Ensure the body is scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fitness Goal Progress
            Text(
              'Fitness Goal: $fitnessGoal',
              style: Theme.of(context).textTheme.displaySmall,  // Updated to Material 3
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _calculateGoalProgress() / 100,
              backgroundColor: Colors.grey[300],
              color: Colors.purple,
            ),
            const SizedBox(height: 10),
            Text(
              '${_calculateGoalProgress().toStringAsFixed(1)}% of goal completed',
              style: Theme.of(context).textTheme.bodyLarge,  // Updated to Material 3
            ),
            const SizedBox(height: 20),
            
            // Log New Activity Form
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(
                labelText: 'Activity',
                hintText: 'e.g., Running, Cycling, Weightlifting',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Calories Burned',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveActivity,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Log Activity'),
            ),
            const SizedBox(height: 30),
            
            // Display Logged Activities
            ListView.builder(
              shrinkWrap: true,  // To make it take only the required space
              physics: const NeverScrollableScrollPhysics(),  // Prevent scrolling within ListView
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      activities[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
