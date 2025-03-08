import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/user/screens/myplan.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

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

  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    print("Payment Success: ${response.paymentId}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId}")),
    );

    // Add data to Firestore
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String paymentId = response.paymentId!;
      String paymentStatus = "Success";
      int totalFee = this.totalFee;

      Map<String, dynamic> paymentData = {
        'userId': userId,
        'paymentId': paymentId,
        'paymentStatus': paymentStatus,
        'totalFee': totalFee,
        'selectedSubcategories': selectedSubcategories,
        'selectedTimes': selectedTimes,
        
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('my_plan').add(paymentData);
      await  _firestore.collection('users').doc(userId).update({
        'issubscribed': true,
      });

      // Store payment success in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPaymentSuccessful', true); 
      
      // Set payment success flag

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  MyPlanScreen()),
      );

      print("Data added to Firestore successfully!");
      print("Payment status saved in shared preferences");
    } catch (e) {
      print("Error adding data to Firestore: $e");
      print("Error saving payment status in shared preferences: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Error: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Error: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("External Wallet: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openRazorpayPayment() {
    var options = {
      'key': 'rzp_test_2vz3Qd309zM3YS', // Replace with your Razorpay key
      'amount': totalFee * 100, // Amount in paise
      'name': 'Fitness App',
      'description': 'Payment for selected categories',
      'prefill': {'contact': '1234567890', 'email': 'user@example.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Selection", style: TextStyle(color: Colors.purple)), // Appbar title in purple
        backgroundColor: Colors.white, // Appbar background white
        iconTheme: const IconThemeData(color: Colors.purple), // Back button in purple
      ),
      body: SizedBox( // Added SizedBox for full screen gradient
        height: MediaQuery.of(context).size.height,
        child: Container( // Container with gradient
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Select Categories and Subcategories",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), // Text in white
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
                ? Colors.white // Card in white when selected
                : const Color.fromARGB(255, 117, 38, 131), // Card in lighter purple when unselected
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: Center(
              child: Text(
                interest,
                style: TextStyle(
                  color: selectedSubcategories.containsKey(interest)
                      ? Colors.purple // Text in purple when card selected
                      : Colors.white, // Text in white when card unselected
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // Text in white
            ),
            const SizedBox(height: 10),
            ...subcategoryList.map((subcategory) {
              final fee = subcategoryFeesData[subcategory] ?? 0;
              return RadioListTile<String>(
                title: Text("$subcategory (₹$fee)", style: const TextStyle(color: Colors.white)), // Text in white
                value: subcategory,
                groupValue: selectedSubcategories[category],
                onChanged: (value) {
                  setState(() {
                    selectedSubcategories[category] = value;
                    subcategoryFees[category] = fee;
                  });
                },
                activeColor: Colors.white, // Radio button active color in white
                tileColor: Colors.deepPurple.withOpacity(0.2), // Tile background for better visibility
                dense: true, // To reduce vertical spacing
                contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Adjust padding as needed
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), // Rounded corners
              );
            }),
            const SizedBox(height: 20),
            const Text(
              "Select Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Text in white
            ),
            ...timeSlots.map((slot) {
              return RadioListTile<String>(
                title: Text(slot, style: const TextStyle(color: Colors.white)), // Text in white
                value: slot,
                groupValue: selectedTimes[category],
                onChanged: (value) {
                  setState(() {
                    selectedTimes[category] = value;
                  });
                },
                activeColor: Colors.white, // Radio button active color in white
                tileColor: Colors.deepPurple.withOpacity(0.2), // Tile background for better visibility
                dense: true, // To reduce vertical spacing
                contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Adjust padding as needed
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), // Rounded corners
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // Text in white
        ),
        const SizedBox(height: 10),
        ...selectedSubcategories.entries.map((entry) {
          final category = entry.key;
          final subcategory = entry.value ?? 'Not selected';
          final timeSlot = selectedTimes[category] ?? 'Not selected';
          final fee = subcategoryFees[category] ?? 0;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70), // Lighter border color
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(10),
            child: Text(
              "$category - $subcategory, Time: $timeSlot, Fee: ₹$fee",
              style: const TextStyle(fontSize: 16, color: Colors.white), // Text in white
            ),
          );
        }),
        const SizedBox(height: 10),
        Text(
          "Total Fee: ₹$totalFee",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Total fee in white
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedSubcategories.values.any((value) => value == null) ||
                  selectedTimes.values.any((value) => value == null)
              ? null
              : () {
                  _openRazorpayPayment();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button in white
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40), // Adjusted horizontal padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Center(
            child: Text(
              "Continue to Payment",
              style: TextStyle(fontSize: 18, color: Colors.purple, fontWeight: FontWeight.bold), // Button text in purple
            ),
          ),
        ),
      ],
    );
  }
}