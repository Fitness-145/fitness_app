import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerMessageScreen extends StatefulWidget {
  const TrainerMessageScreen({super.key});

  @override
  _TrainerMessageScreenState createState() => _TrainerMessageScreenState();
}

class _TrainerMessageScreenState extends State<TrainerMessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  String _selectedRecipient = 'all'; // Default recipient (All users)

  @override
  Widget build(BuildContext context) {
    final trainer = _auth.currentUser;
    final trainerId = trainer?.uid;
    final trainerName = trainer?.displayName ?? "Trainer";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainer Messages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Message list display (Messages sent by users to trainer)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('user_messages')
                  .where('receiverId',
                      isEqualTo: trainerId) // Messages from users to trainer
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageData = message.data() as Map<String, dynamic>;

                    bool isSentByTrainer = messageData['senderId'] == trainerId;
                    String senderName = messageData['senderName'];
                    String senderRole = messageData['senderRole'];
                    Timestamp timestamp = messageData['timestamp'];
                    DateTime messageTime = timestamp.toDate();
                    String formattedTime =
                        "${messageTime.hour}:${messageTime.minute}";

                    return Align(
                      alignment: isSentByTrainer
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSentByTrainer
                              ? Colors.deepPurple
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByTrainer
                                  ? "You"
                                  : "$senderName ($senderRole)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSentByTrainer
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageData['message'],
                              style: TextStyle(
                                color: isSentByTrainer
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSentByTrainer
                                    ? Colors.white70
                                    : Colors.black45,
                              ),
                            ),
                            // Reply Button (Only for trainer)
                            if (isSentByTrainer)
                              IconButton(
                                icon: const Icon(Icons.reply,
                                    color: Colors.deepPurple),
                                onPressed: () {
                                  // Action when replying to the message
                                  _replyToMessage(message.id);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Recipient Dropdown (To select 'All' or 'Specific User')
                DropdownButton<String>(
                  value: _selectedRecipient,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text("All Users")),
                    // Add more options if needed (like specific users)
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecipient = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage(trainerId, trainerName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to send a message
  void _sendMessage(String? trainerId, String trainerName) async {
    if (_messageController.text.isEmpty || trainerId == null) return;

    String receiverId = _selectedRecipient == 'all'
        ? 'all_users' // Broadcast to all users
        : _selectedRecipient; // Send to a specific user

    String receiverName = _selectedRecipient == 'all' ? "All Users" : "User";

    // Add message to Firestore
    await _firestore.collection('trainer_messages').add({
      'senderId': trainerId,
      'senderName': trainerName,
      'senderRole': 'trainer',
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': _messageController.text,
      'timestamp': Timestamp.now(),
    });

    // Add a separate collection for broadcasting to all users
    if (_selectedRecipient == 'all') {
      await _firestore.collection('user_messages').add({
        'senderId': trainerId,
        'senderName': trainerName,
        'senderRole': 'trainer',
        'receiverId': 'all_users', // This is for all users
        'receiverName': 'All Users',
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      });
    }

    // Clear the message input after sending
    _messageController.clear();
  }

  // Method to reply to a user message
  void _replyToMessage(String messageId) async {
    String replyMessage =
        "Thank you for your message!"; // You can customize this as needed.

    final trainer = _auth.currentUser;
    final trainerId = trainer?.uid;
    final trainerName = trainer?.displayName ?? "Trainer";

    if (trainerId == null) return;

    // Fetch the original message data to reply to
    var originalMessage =
        await _firestore.collection('user_messages').doc(messageId).get();

    var originalMessageData = originalMessage.data() as Map<String, dynamic>;
    String userId = originalMessageData['senderId'];

    // Send the reply
    await _firestore.collection('user_messages').add({
      'senderId': trainerId,
      'senderName': trainerName,
      'senderRole': 'trainer',
      'receiverId': userId, // Reply to the user who sent the message
      'receiverName': originalMessageData['senderName'],
      'message': replyMessage,
      'timestamp': Timestamp.now(),
    });

    // You can customize the reply message above.
  }
}
 