import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final String receiverId = 'admin@yahoo.com'; // Admin's email
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && currentUser != null) {
      String message = _messageController.text;
      String senderEmail = currentUser!.email ?? 'unknown@user.com';
      String senderId = currentUser!.uid;

      // Simpan pesan ke Firestore
      await FirebaseFirestore.instance.collection('chat').add({
        'message': message,
        'senderEmail': senderEmail,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
        'receiverId': receiverId,
      });

      _messageController.clear();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Height of the AppBar
        child: AppBar(
          backgroundColor: Colors.green[300],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin', // Menampilkan teks "Admin"
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/logo.png', width: 40, height: 40),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Display "Connected to" text outside AppBar and at the top center
          Padding(
            padding: const EdgeInsets.only(top: 20.0), // Space from the top
            child: Text(
              'Connected to ${receiverId}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada pesan'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var chatData = snapshot.data!.docs[index].data()
                    as Map<String, dynamic>;
                    bool isReceived =
                        chatData['senderEmail'] != currentUser?.email;
                    String time = chatData['timestamp'] != null
                        ? DateFormat('HH:mm').format(
                      chatData['timestamp'].toDate(),
                    )
                        : 'Mengirim...';

                    return Align(
                      alignment: isReceived
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isReceived
                              ? Colors.white
                              : Color(0xFFDCF8C6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatData['message'] ?? '',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
