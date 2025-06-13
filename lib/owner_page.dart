import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:walet_app/manager_list.dart';
import 'input_partai.dart';
import 'riwayat_owner.dart';
import 'package:walet_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilteringByDate = false;
  String _searchQuery = '';

  Stream<QuerySnapshot> get _walletStream {
    Query collection = FirebaseFirestore.instance
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

  // Filter the documents by date after they are retrieved
  List<QueryDocumentSnapshot> _filterDocumentsByDate(List<QueryDocumentSnapshot> docs) {
    if (!_isFilteringByDate || (_startDate == null && _endDate == null)) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final docDate = (data['created_at'] as Timestamp).toDate();

      if (_startDate != null && _endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        return !docDate.isBefore(_startDate!) && !docDate.isAfter(endOfDay);
      } else if (_startDate != null) {
        return !docDate.isBefore(_startDate!);
      } else if (_endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        return !docDate.isAfter(endOfDay);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('username');
            await prefs.remove('role');
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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final searchResult = await showSearch<String>(
                context: context,
                delegate: _PartaiSearchDelegate(),
              );
              if (searchResult != null) {
                setState(() {
                  _searchQuery = searchResult;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: () {
              _showDateFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showAddConfirmation();
            },
          ),
        ],
    ),
      body: Column(
        children: [
          _buildFilterTabs(),
          if (_isFilteringByDate) _buildDateFilterChip(),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hasil pencarian: "$_searchQuery"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),
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

                final filteredDocsByDate = _filterDocumentsByDate(snapshot.data!.docs);

                final filteredDocs = _searchQuery.isNotEmpty
                    ? filteredDocsByDate.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final namaPartai = (data['nama_partai'] ?? '').toString().toLowerCase();
                        final managerUsername = (data['manager_username'] ?? '').toString().toLowerCase();
                        final queryLower = _searchQuery.toLowerCase();
                        return namaPartai.contains(queryLower) || managerUsername.contains(queryLower);
                      }).toList()
                    : filteredDocsByDate;

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('Tidak ada data wallet dalam rentang tanggal yang dipilih'));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
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

  Widget _buildDateFilterChip() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String filterText = 'Filter: ';
    if (_startDate != null && _endDate != null) {
      filterText += '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      filterText += 'Dari ${dateFormat.format(_startDate!)}';
    } else if (_endDate != null) {
      filterText += 'Sampai ${dateFormat.format(_endDate!)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Chip(
        backgroundColor: Colors.blue[100],
        label: Text(
          filterText,
          style: TextStyle(color: Colors.blue[800]),
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () {
          setState(() {
            _startDate = null;
            _endDate = null;
            _isFilteringByDate = false;
          });
        },
      ),
    );
  }

  Future<void> _showDateFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Berdasarkan Tanggal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (context, setTileState) {
                    return ListTile(
                      title: const Text('Tanggal Mulai'),
                      subtitle: Text(_startDate != null
                          ? DateFormat('dd/MM/yyyy').format(_startDate!)
                          : 'Pilih tanggal'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            _isFilteringByDate = true;
                          });
                          setTileState(() {});
                          setDialogState(() {});
                        }
                      },
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setTileState) {
                    return ListTile(
                      title: const Text('Tanggal Akhir'),
                      subtitle: Text(_endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : 'Pilih tanggal'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                            _isFilteringByDate = true;
                          });
                          setTileState(() {});
                          setDialogState(() {});
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InputPartaiPage()),
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
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeleteDialog(context, id);
              },
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

  void _confirmDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus partai ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePartai(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePartai(String id) async {
    try {
      await FirebaseFirestore.instance.collection('partai').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partai berhasil dihapus')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus partai: $e')),
      );
    }
  }
}

class _PartaiSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Cari nama partai atau nama manager';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    close(context, query);
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
