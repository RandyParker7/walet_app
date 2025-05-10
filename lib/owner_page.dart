import 'package:flutter/material.dart';

class OwnerPage extends StatelessWidget {
  const OwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Kembali ke halaman login
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, Owner!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Ini adalah halaman dashboard Owner. Di sini kamu bisa melihat informasi penting, statistik, atau mengakses fitur lainnya.',
            ),
            SizedBox(height: 24),
            // Tambahkan widget lain sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
