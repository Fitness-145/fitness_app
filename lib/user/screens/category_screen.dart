import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key, required this.selectedInterests});

  final List<Map<String, dynamic>> selectedInterests;

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int? selectedCategoryIndex; // To track the selected category
  Map<String, String?> selectedSubcategories = {}; // Store subcategory selections
  String? selectedBatch; // Track selected batch
  String? selectedTime; // Track selected time

  // Map of categories and their subcategories
  final Map<String, List<String>> subcategories = {
    'Gym': ['Weight Loss', 'Weight Gain', 'Overall Fitness'],
    'Karate': ['Beginner', 'Amateur', 'Mature', 'Pro'],
    'Martial Arts': ['Beginner', 'Intermediate', 'Advanced'],
    'Shooting': ['Handgun', 'Rifle', 'Shotgun'],
    'Boxing': ['Beginner', 'Intermediate', 'Advanced'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
  };

  // Details for each subcategory including fees
  final Map<String, Map<String, String>> subcategoryDetails = {
    'Weight Loss': {
      'description': 'Proven support for weight loss through cardio and strength training.',
      'fee': '₹2,500/month',
    },
    'Weight Gain': {
      'description': 'Effective programs for muscle building and healthy weight gain.',
      'fee': '₹2,800/month',
    },
    'Overall Fitness': {
      'description': 'Comprehensive approach to fitness, focusing on strength, endurance, and flexibility.',
      'fee': '₹3,000/month',
    },
    'Beginner': {
      'description': 'Introductory lessons for those new to Karate.',
      'fee': '₹1,500/month',
    },
    'Amateur': {
      'description': 'Intermediate training for hobbyists looking to improve.',
      'fee': '₹2,000/month',
    },
    'Mature': {
      'description': 'Advanced Karate techniques for seasoned practitioners.',
      'fee': '₹2,500/month',
    },
    'Pro': {
      'description': 'Professional training for those aiming to compete at higher levels.',
      'fee': '₹3,000/month',
    },
    'Intermediate': {
      'description': 'Skill development for those with a basic understanding of Martial Arts.',
      'fee': '₹2,000/month',
    },
    'Advanced': {
      'description': 'Refinement of techniques and preparation for competitions.',
      'fee': '₹2,500/month',
    },
    'Handgun': {
      'description': 'Training focusing on accuracy and safety with handguns.',
      'fee': '₹2,500/month',
    },
    'Rifle': {
      'description': 'Long-range shooting techniques and safety practices.',
      'fee': '₹2,800/month',
    },
    'Shotgun': {
      'description': 'Dynamic shooting and field experiences with shotguns.',
      'fee': '₹3,000/month',
    },
    'Singles': {
      'description': 'Training focused on one-on-one competition in Badminton.',
      'fee': '₹1,800/month',
    },
    'Doubles': {
      'description': 'Team strategies and techniques for doubles play.',
      'fee': '₹2,000/month',
    },
    'Mixed Doubles': {
      'description': 'Training for mixed-gender teams in Badminton competition.',
      'fee': '₹2,200/month',
    },
  };

  // Batch time options for both Daily and Weekend
  final Map<String, List<String>> batchTimes = {
    'Daily': [
      'Morning Batch: 6:00 AM - 9:00 AM',
      'Evening Batch: 5:00 PM - 10:00 PM',
    ],
    'Weekend': [
      'Morning Batch: 6:00 AM - 9:00 AM',
      'Evening Batch: 5:00 PM - 10:00 PM',
    ],
  };

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

                // Display available categories with grid layout
                _buildCategoryGrid(),

                const SizedBox(height: 20),

                // Display subcategories if a category is selected
                if (selectedCategoryIndex != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Select a Subcategory for ${widget.selectedInterests[selectedCategoryIndex!]['interest']}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  buildSubcategoryList(widget.selectedInterests[selectedCategoryIndex!]['interest']!),
                ],

                const SizedBox(height: 20),

                // Batch Selection
                if (selectedSubcategories.isNotEmpty) ...[
                  const Text(
                    "Select Batch Type",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  buildBatchSelection(),
                ],

                const SizedBox(height: 20),

                // Time Slot Selection
                if (selectedBatch != null) ...[
                  const Text(
                    "Select a Time Slot",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  buildTimeSelection(),
                ],

                const SizedBox(height: 30),

                // Show selected categories and subcategories summary
                if (selectedSubcategories.isNotEmpty) ...[
                  const Text(
                    "Selected Summary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  buildSelectedSummary(),
                ],

                const SizedBox(height: 30),

                // Centered "Continue" button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Selected Subcategories: $selectedSubcategories');
                      print('Selected Batch: $selectedBatch');
                      print('Selected Time: $selectedTime');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the category options with a grid layout
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: widget.selectedInterests.length,
      itemBuilder: (context, index) {
        final interest = widget.selectedInterests[index];
        return buildCategoryOption(index, interest['interest'], interest['icon']);
      },
    );
  }

  // Category Option Widget
  Widget buildCategoryOption(int index, String label, IconData icon) {
    bool hasSelectedSubcategory = selectedSubcategories[label] != null;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryIndex = selectedCategoryIndex == index ? null : index;
        });
      },
      child: _buildBubbleCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: hasSelectedSubcategory ? Colors.green : (selectedCategoryIndex == index ? Colors.purple : Colors.grey),
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hasSelectedSubcategory ? Colors.green : (selectedCategoryIndex == index ? Colors.purple : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a bubble card style
  Widget _buildBubbleCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }

  // Build the subcategory list for the selected category
  Widget buildSubcategoryList(String category) {
    List<String> subcategoryList = subcategories[category] ?? [];
    return Column(
      children: subcategoryList.map((sub) {
        bool isSelected = selectedSubcategories[category] == sub;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSubcategories.remove(category); // Deselect if already selected
              } else {
                selectedSubcategories[category] = sub; // Select this subcategory
              }
            });
            categoryDetails(context, sub);
          },
          child: _buildBubbleCard(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.green), // Tick mark if selected
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Show details for selected subcategory in a modal
  void categoryDetails(BuildContext context, String subCategory) {
    String description = subcategoryDetails[subCategory]?['description'] ?? "No details available.";
    String fee = subcategoryDetails[subCategory]?['fee'] ?? "No fee available.";

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subCategory,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Description: $description",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Fee: $fee",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget to build batch selection
  Widget buildBatchSelection() {
    return Wrap(
      spacing: 8.0,
      children: batchTimes.keys.map((batch) {
        bool isSelected = selectedBatch == batch;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBatch = isSelected ? null : batch;
              selectedTime = null; // Reset time slot when batch changes
            });
          },
          child: _buildBubbleCard(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    batch,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.purple : Colors.black,
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.purple),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget to build time selection based on the selected batch
  Widget buildTimeSelection() {
    final List<String>? timeSlots = batchTimes[selectedBatch];

    return Wrap(
      spacing: 8.0,
      children: timeSlots!.map((time) {
        bool isSelected = selectedTime == time;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = isSelected ? null : time;
            });
          },
          child: _buildBubbleCard(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.purple : Colors.black,
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.purple),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget to display summary of selected options
  Widget buildSelectedSummary() {
    double totalFee = 0;

    return _buildBubbleCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...selectedSubcategories.entries.map((entry) {
              String subCategory = entry.value!;
              String feeString = subcategoryDetails[subCategory]?['fee'] ?? "0";
              double fee = double.tryParse(feeString.replaceAll('₹', '').replaceAll(',', '')) ?? 0;
              totalFee += fee;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${entry.key}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Subcategory: ${entry.value}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (selectedBatch != null)
                    Text(
                      'Batch: $selectedBatch',
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (selectedTime != null)
                    Text(
                      'Time Slot: $selectedTime',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              );
            }),
            const SizedBox(height: 10),
            Text(
              'Total Fee: ₹${totalFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
