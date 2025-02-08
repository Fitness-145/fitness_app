import 'package:fitness_app/user/screens/paymet_screen.dart';
import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key, required this.selectedInterests});

  final List<String> selectedInterests;

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  Map<String, String?> selectedSubcategories = {};
  Map<String, String?> selectedTimes = {};
  Map<String, int> subcategoryFees = {};

  final Map<String, List<String>> subcategories = {
    'Gym': ['Weight Loss', 'Weight Gain', 'Overall Fitness'],
    'Karate': ['Beginner', 'Amateur', 'Mature', 'Pro'],
    'Martial Arts': ['Beginner', 'Intermediate', 'Advanced'],
    'Shooting': ['Handgun', 'Rifle', 'Shotgun'],
    'Boxing': ['Beginner', 'Intermediate', 'Advanced'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
  };

  final Map<String, int> subcategoryFeesData = {
    'Weight Loss': 1500,
    'Weight Gain': 1800,
    'Overall Fitness': 2000,
    'Beginner': 1200,
    'Amateur': 1500,
    'Mature': 1800,
    'Pro': 2000,
    'Intermediate': 1600,
    'Advanced': 2000,
    'Handgun': 1500,
    'Rifle': 1800,
    'Shotgun': 2000,
    'Singles': 1400,
    'Doubles': 1600,
    'Mixed Doubles': 1800,
  };

  final List<String> timeSlots = ['7 AM - 9 AM', '4 PM - 9 PM'];

  int get totalFee => subcategoryFees.values.fold(0, (sum, fee) => sum + fee);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Category Selection"),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Select Categories and Subcategories",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildCategoryGrid(),
                const SizedBox(height: 20),
                if (selectedSubcategories.isNotEmpty) _buildCategoryDetails(),
                const SizedBox(height: 20),
                if (selectedSubcategories.isNotEmpty) _buildSummarySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: widget.selectedInterests.length,
      itemBuilder: (context, index) {
        final interest = widget.selectedInterests[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedSubcategories.containsKey(interest)) {
                selectedSubcategories.remove(interest);
                selectedTimes.remove(interest);
              } else {
                selectedSubcategories[interest] = null;
                selectedTimes[interest] = null;
              }
            });
          },
          child: Card(
            color: selectedSubcategories.containsKey(interest)
                ? Colors.purple
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: Center(
              child: Text(
                interest,
                style: TextStyle(
                  color: selectedSubcategories.containsKey(interest)
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedSubcategories.keys.map((category) {
        final subcategoryList = subcategories[category] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Subcategory and Time Slot for $category",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...subcategoryList.map((subcategory) {
              final fee = subcategoryFeesData[subcategory] ?? 0;
              return RadioListTile<String>(
                title: Text("$subcategory (₹$fee)"),
                value: subcategory,
                groupValue: selectedSubcategories[category],
                onChanged: (value) {
                  setState(() {
                    selectedSubcategories[category] = value;
                    subcategoryFees[category] = fee;
                  });
                },
              );
            }),
            const SizedBox(height: 20),
            const Text(
              "Select Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...timeSlots.map((slot) {
              return RadioListTile<String>(
                title: Text(slot),
                value: slot,
                groupValue: selectedTimes[category],
                onChanged: (value) {
                  setState(() {
                    selectedTimes[category] = value;
                  });
                },
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Summary",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...selectedSubcategories.entries.map((entry) {
          final category = entry.key;
          final subcategory = entry.value ?? 'Not selected';
          final timeSlot = selectedTimes[category] ?? 'Not selected';
          final fee = subcategoryFees[category] ?? 0;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(10),
            child: Text(
              "$category - $subcategory, Time: $timeSlot, Fee: ₹$fee",
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
        const SizedBox(height: 10),
        Text(
          "Total Fee: ₹$totalFee",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedSubcategories.values.any((value) => value == null) ||
                  selectedTimes.values.any((value) => value == null)
              ? null // Disable button if subcategory or time slot is not selected
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        summaryDetails: selectedSubcategories,
                        totalFee: totalFee,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          child: const Center(
            child: Text(
              "Continue to Payment",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
