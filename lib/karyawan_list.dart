import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_karyawan.dart';
import 'edit_karyawan.dart';

class KaryawanListPage extends StatefulWidget {
  const KaryawanListPage({super.key});

  @override
  State<KaryawanListPage> createState() => _KaryawanListPageState();
}

class _KaryawanListPageState extends State<KaryawanListPage> {
  Stream<QuerySnapshot> _karyawanStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'karyawan')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Karyawan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4355B9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddKaryawanPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _karyawanStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final karyawans = snapshot.data?.docs ?? [];
          karyawans.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aName = aData['username']?.toString().toLowerCase() ?? '';
            final bName = bData['username']?.toString().toLowerCase() ?? '';
            return aName.compareTo(bName);
          });
          if (karyawans.isEmpty) {
            return const Center(child: Text('Tidak ada karyawan yang ditemukan.'));
          }

          return ListView.builder(
            itemCount: karyawans.length,
            itemBuilder: (context, index) {
              final karyawanDoc = karyawans[index];
              final karyawan = karyawanDoc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(karyawan['username'] ?? 'Tanpa nama'),
                  subtitle: Text('Jumlah Partai Dicuci: ${karyawan['counter'] ?? 0}'),
                  trailing: SizedBox(
                    width: 96,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditKaryawanPage(
                                  karyawanId: karyawanDoc.id,
                                  currentUsername: karyawan['username'] ?? '',
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: const Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(karyawanDoc.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Karyawan berhasil dihapus')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menghapus karyawan: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
