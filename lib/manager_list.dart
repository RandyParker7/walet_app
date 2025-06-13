import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_manager.dart';
import 'edit_manager.dart';

class ManagerListPage extends StatefulWidget {
  const ManagerListPage({super.key});

  @override
  State<ManagerListPage> createState() => _ManagerListPageState();
}

class _ManagerListPageState extends State<ManagerListPage> {
  Stream<QuerySnapshot> _managerStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'manager')
      .snapshots();

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
      body: StreamBuilder<QuerySnapshot>(
        stream: _managerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final managers = snapshot.data?.docs ?? [];
          managers.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aName = aData['username']?.toString().toLowerCase() ?? '';
            final bName = bData['username']?.toString().toLowerCase() ?? '';
            return aName.compareTo(bName);
          });
          if (managers.isEmpty) {
            return const Center(child: Text('Tidak ada manager yang ditemukan.'));
          }

          return ListView.builder(
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final managerDoc = managers[index];
              final manager = managerDoc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(manager['username'] ?? 'Tanpa nama'),
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
                                builder: (_) => EditManagerPage(
                                  managerId: managerDoc.id,
                                  currentUsername: manager['username'] ?? '',
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
                                content: const Text('Apakah Anda yakin ingin menghapus manager ini?'),
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
                                    .doc(managerDoc.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Manager berhasil dihapus')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menghapus manager: $e')),
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
