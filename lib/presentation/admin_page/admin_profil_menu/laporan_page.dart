import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Package untuk memformat timestamp

class LaporanUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Text('Laporan User'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png', width: 50, height: 50), // Logo image
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('laporan').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada laporan saat ini.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var laporanData = snapshot.data!.docs[index].data() as Map<String, dynamic>?;
              if (laporanData != null) {
                String username = laporanData.containsKey('username') ? laporanData['username'] : 'Anonim';
                String text = laporanData.containsKey('text') ? laporanData['text'] : 'Laporan tidak tersedia';
                Timestamp? timestamp = laporanData['timestamp'] as Timestamp?;

                String formattedTime = timestamp != null
                    ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                    : 'Waktu tidak tersedia';

                return _buildLaporanCard(username, text, formattedTime);
              } else {
                return _buildLaporanCard('Anonim', 'Laporan tidak tersedia', 'Waktu tidak tersedia');
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_home.png', width: 24, height: 24),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_mutasi.png', width: 24, height: 24),
            label: 'Mutasi',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/icon_qr_code.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_info.png', width: 24, height: 24),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_profile.png', width: 24, height: 24),
            label: 'Profile',
          ),
        ],
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/mutasi');
              break;
            case 2:
            // QR handling
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/info');
              break;
            case 4:
            // Profile
              break;
          }
        },
      ),
    );
  }

  Widget _buildLaporanCard(String username, String laporan, String formattedTime) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu: $formattedTime',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Laporan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              laporan,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
