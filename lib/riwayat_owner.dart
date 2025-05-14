import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatOwnerPage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const RiwayatOwnerPage({super.key, required this.id, required this.data});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Belum Diproses';
    final hasilCuci = data['hasil_cuci'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Detail Partai',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4355B9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInfoCard(
              title: 'Informasi Awal',
              items: {
                'Nama Partai': data['nama_partai'],
                'Nama Bahan': data['nama_bahan'],
                'Berat Awal': data['berat_awal'],
                'Pengurangan Pengeringan': data['pengurangan_pengeringan'],
                'Tanggal Masuk': _formatDate(data['created_at']),
              },
            ),
            const SizedBox(height: 20),
            if (status == 'Sudah Diproses')
              _buildInfoCard(
                title: 'Hasil Pencucian',
                items: {
                  'Berat Bersih': hasilCuci['berat_bersih'],
                  'Berat Kikis': hasilCuci['kikis'],
                  'Berat Bubuk': hasilCuci['bubuk'],
                  'Berat Gerinda': hasilCuci['gerinda'],
                  'Berat Karatan': hasilCuci['karatan'],
                  'Tanggal Selesai Pencucian': _formatDate(data['updated_at']),
                },
              ),
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
