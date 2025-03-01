 
import 'package:fitness_app/user/cardpayment.dart';
import 'package:flutter/material.dart';
import 'upi.dart'; // Ensure the correct import for UpiPaymentScreen
// Assuming you have this file for CardPaymentScreen

class PaymentScreen extends StatefulWidget {
  final Map<String, String?> summaryDetails;
  final int totalFee;

  const PaymentScreen({
    super.key,
    required this.summaryDetails,
    required this.totalFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod = "upi"; // Default to UPI as the first option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.summaryDetails.entries.map((entry) {
              return Text(
                "${entry.key}: ${entry.value}",
                style: const TextStyle(fontSize: 16),
              );
            }),
            const SizedBox(height: 10),
            Text(
              "Total Fee: ₹${widget.totalFee}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text("UPI"),
                  value: "upi",
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Credit/Debit Card"),
                  value: "card",
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Net Banking"),
                  value: "netbanking",
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_selectedPaymentMethod == "upi") {
                  // Navigate to UPI Payment Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpiPaymentScreen(
                        amount: widget.totalFee, // Pass the total fee as the amount
                      ),
                    ),
                  );
                } else if (_selectedPaymentMethod == "card") {
                  // Navigate to Card Payment Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardPaymentScreen(
                        totalFee: widget.totalFee, // Pass the total fee to CardPaymentScreen
                      ),
                    ),
                  );
                } else {
                  // For other payment methods (Net Banking)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Payment Successful via ${_selectedPaymentMethod ?? "N/A"}!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Navigate back to the previous screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              child: const Center(
                child: Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
