import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walet_app/manager_list.dart';
import 'input_partai.dart';
import 'riwayat_owner.dart';
import 'package:walet_app/login_page.dart';


class OwnerPage extends StatelessWidget {
  const OwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF4355B9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4355B9),
        ),
      ),
      home: const WalletListScreen(),
    );
  }
}

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

enum FilterStatus { all, processed, unprocessed }

class _WalletListScreenState extends State<WalletListScreen> {
  FilterStatus _currentFilter = FilterStatus.all;

  Stream<QuerySnapshot> get _walletStream {
    final collection = FirebaseFirestore.instance
        .collection('partai')
        .orderBy('created_at', descending: true);

    switch (_currentFilter) {
      case FilterStatus.processed:
        return collection.where('status', isEqualTo: 'Sudah Diproses').snapshots();
      case FilterStatus.unprocessed:
        return collection.where('status', isEqualTo: 'Belum Diproses').snapshots();
      default:
        return collection.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
        title: const Text(
          'Daftar Walet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagerListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputPartaiPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _walletStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada data wallet'));
                }
                final wallets = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final doc = wallets[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final date = (data['created_at'] as Timestamp).toDate();
                    return _buildWalletCard(doc.id, data, date);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              title: 'All',
              isActive: _currentFilter == FilterStatus.all,
              onTap: () => _setFilter(FilterStatus.all),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(
              title: 'Sudah Diproses',
              isActive: _currentFilter == FilterStatus.processed,
              onTap: () => _setFilter(FilterStatus.processed),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(
              title: 'Belum Diproses',
              isActive: _currentFilter == FilterStatus.unprocessed,
              onTap: () => _setFilter(FilterStatus.unprocessed),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    Color color = Colors.grey,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(String id, Map<String, dynamic> data, DateTime date) {
    final status = data['status'] ?? 'Belum Diproses';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(_getMonthAbbreviation(date.month),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('${date.year}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        title: Text(
          data['nama_partai'] ?? 'Tanpa Nama',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: status == 'Sudah Diproses' ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == 'Sudah Diproses' ? Colors.green[700] : Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RiwayatOwnerPage(id: id, data: data),
            ),
          );
        },
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  void _setFilter(FilterStatus status) {
    setState(() {
      _currentFilter = status;
    });
  }
}
