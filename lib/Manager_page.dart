import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walet_app/login_page.dart';
import 'riwayat_manager.dart';

class ManagerPage extends StatelessWidget {
  const ManagerPage({super.key});

  Stream<QuerySnapshot> get _unprocessedPartaiStream {
    return FirebaseFirestore.instance
        .collection('partai')
        .where('status', isEqualTo: 'Belum Diproses')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        title: const Text("Dashboard Manager"),
        backgroundColor: const Color(0xFF4355B9),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _unprocessedPartaiStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada partai yang belum diproses',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['created_at'] as Timestamp).toDate();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(data['nama_partai'] ?? 'Tanpa Nama'),
                  subtitle: Text(
                    'Tanggal Masuk: ${date.day}-${date.month}-${date.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF4355B9)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RiwayatManagerPage(id: doc.id, data: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
