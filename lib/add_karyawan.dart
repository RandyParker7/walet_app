import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddKaryawanPage extends StatefulWidget {
  const AddKaryawanPage({Key? key}) : super(key: key);

  @override
  _AddKaryawanPageState createState() => _AddKaryawanPageState();
}

class _AddKaryawanPageState extends State<AddKaryawanPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _addKaryawan() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Nama harus diisi';
        _isLoading = false;
      });
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _error = 'Nama sudah digunakan';
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('users').add({
        'username': name,
        'role': 'karyawan',
      });

      setState(() {
        _success = 'Karyawan berhasil ditambahkan';
        _nameController.clear();
      });
      // Navigate back after adding
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Add Karyawan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildTextField('Nama', _nameController),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (_success != null)
                  Text(
                    _success!,
                    style: const TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _isLoading ? null : _addKaryawan,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
