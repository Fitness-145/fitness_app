import 'package:flutter/material.dart';

class UpiPaymentScreen extends StatefulWidget {
  final int amount; // Amount passed from the previous screen

  const UpiPaymentScreen({super.key, required this.amount});

  @override
  _UpiPaymentScreenState createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  final TextEditingController _upiIdController = TextEditingController();

  // Function to validate UPI ID
  bool isValidUpiId(String upiId) {
    final upiIdRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+\.[a-zA-Z]+$');
    return upiIdRegex.hasMatch(upiId);
  }

  // Function to initiate UPI payment
  void initiateUpiPayment() {
    String upiId = _upiIdController.text.trim();

    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields!"),
      ));
      return;
    }

    if (!isValidUpiId(upiId)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid UPI ID! Please enter a valid UPI ID."),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("UPI Payment of ₹${widget.amount} to $upiId initiated!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UPI Payment"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Enter UPI ID",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                hintText: "Enter UPI ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Amount: ₹${widget.amount}", // Displaying the amount passed
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: initiateUpiPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
