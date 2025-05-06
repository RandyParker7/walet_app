import 'package:flutter/material.dart';

void main() {
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

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

class WalletParty {
  final String name;
  final DateTime date;
  final bool isProcessed;

  WalletParty({
    required this.name,
    required this.date,
    required this.isProcessed,
  });
}

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class WalletDetailScreen extends StatelessWidget {
  final WalletParty wallet;
  
  const WalletDetailScreen({super.key, required this.wallet});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Page Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.grey[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4355B9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Daftar Walet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wallet.date.day.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        "Okt",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        wallet.date.year.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      wallet.isProcessed ? 'Sudah Diproses' : 'Belum Diproses',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletListScreenState extends State<WalletListScreen> {
  final List<WalletParty> _wallets = [
    WalletParty(
      name: 'Partai 42',
      date: DateTime(2024, 10, 30),
      isProcessed: true,
    ),
    WalletParty(
      name: 'Partai 7',
      date: DateTime(2024, 10, 29),
      isProcessed: true,
    ),
    WalletParty(
      name: 'Partai 18',
      date: DateTime(2024, 10, 27),
      isProcessed: false,
    ),
  ];

  FilterStatus _currentFilter = FilterStatus.all;

  List<WalletParty> get _filteredWallets {
    switch (_currentFilter) {
      case FilterStatus.processed:
        return _wallets.where((wallet) => wallet.isProcessed).toList();
      case FilterStatus.unprocessed:
        return _wallets.where((wallet) => !wallet.isProcessed).toList();
      default:
        return _wallets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Page Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.grey[600],
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4355B9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Daftar Walet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    onPressed: () {
                      // Calendar functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      _showAddWalletDialog();
                    },
                  ),
                ],
              ),
            ),
            _buildFilterTabs(),
            Expanded(
              child: _filteredWallets.isEmpty
                  ? const Center(
                      child: Text('Tidak ada data wallet'),
                    )
                  : ListView.builder(
                      itemCount: _filteredWallets.length,
                      itemBuilder: (context, index) {
                        final wallet = _filteredWallets[index];
                        return _buildWalletCard(wallet);
                      },
                    ),
            ),
          ],
        ),
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

  Widget _buildWalletCard(WalletParty wallet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          _showWalletDetails(wallet);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    wallet.date.day.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _getMonthAbbreviation(wallet.date.month),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    wallet.date.year.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Text(
                wallet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: wallet.isProcessed
                      ? Colors.green[400]
                      : Colors.red[400],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  wallet.isProcessed ? 'Sudah Diproses' : 'Belum Diproses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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

  void _showAddWalletDialog() {
    final nameController = TextEditingController();
    bool isProcessed = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Wallet Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Partai',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status: '),
                Switch(
                  value: isProcessed,
                  onChanged: (value) {
                    setState(() {
                      isProcessed = value;
                    });
                  },
                ),
                Text(isProcessed ? 'Sudah Diproses' : 'Belum Diproses'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _wallets.insert(
                    0,
                    WalletParty(
                      name: nameController.text,
                      date: DateTime.now(),
                      isProcessed: isProcessed,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showWalletDetails(WalletParty wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletDetailScreen(wallet: wallet),
      ),
    );
  }
}

enum FilterStatus {
  all,
  processed,
  unprocessed,
}