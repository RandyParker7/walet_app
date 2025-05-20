import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_manager.dart';

class ManagerListPage extends StatelessWidget {
  const ManagerListPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchManagers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'manager')
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Manager', 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4355B9),
        foregroundColor: Colors.white,
        
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddManagerPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchManagers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final managers = snapshot.data!;
          if (managers.isEmpty) {
            return const Center(child: Text('Tidak ada manager yang ditemukan.'));
          }

          return ListView.builder(
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final manager = managers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(manager['username'] ?? 'Tanpa nama'),
                  subtitle: Text('ID: ${manager['id']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
