import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'input_hasil.dart';

class RiwayatManagerPage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final String username;

  const RiwayatManagerPage({super.key, required this.id, required this.data, required this.username});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final infoAwal = {
      'Nama Partai': data['nama_partai'],
      'Nama Bahan': data['nama_bahan'],
      'Berat Awal': data['berat_awal'],
      'Pengurangan Pengeringan': data['pengurangan_pengeringan'],
      'Tanggal Masuk': _formatDate(data['created_at']),
    };

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Detail Partai', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4355B9),
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(title: 'Informasi Partai', items: infoAwal),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputHasilCuciPage(partaiId: id, username: username),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4355B9),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tambahkan Hasil Pencucian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Map<String, dynamic> items}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4355B9),
              ),
            ),
            const SizedBox(height: 12),
            ...items.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.value ?? '-'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
