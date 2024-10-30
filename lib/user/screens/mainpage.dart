import 'package:flutter/material.dart';

class CustomizeInterestsScreen extends StatefulWidget {
  @override
  _CustomizeInterestsScreenState createState() => _CustomizeInterestsScreenState();
}

class _CustomizeInterestsScreenState extends State<CustomizeInterestsScreen> {
  // Track selected interests
  final Map<String, bool> interests = {
    'Gym': false,
    'Karate': false,
    'Martial Arts': false,
    'Badminton': false,
    'Shooting': false,
    'Boxing': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 20),

            // Title
            Text(
              'Time to customize your interests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Interest options
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .9,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: interests.keys.length,
                itemBuilder: (context, index) {
                  String interest = interests.keys.elementAt(index);
                  bool isSelected = interests[interest] ?? false;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        interests[interest] = !isSelected;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.purple[100] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.purple : Colors.grey,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            _getInterestIcon(interest),
                            color: isSelected ? Colors.purple : Colors.grey,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(interest, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Continue button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle continue action
                List<String> selectedInterests = interests.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                print("Selected interests: $selectedInterests");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getInterestIcon(String interest) {
    switch (interest) {
      case 'Gym':
        return Icons.fitness_center;
      case 'Karate':
        return Icons.sports_kabaddi;
      case 'Martial Arts':
        return Icons.sports_mma;
      case 'Badminton':
        return Icons.sports_tennis;
      case 'Shooting':
        return Icons.sports_esports; // Adjust icon if you prefer a different one
      case 'Boxing':
        return Icons.sports_mma;
      default:
        return Icons.help_outline;
    }
  }
}
