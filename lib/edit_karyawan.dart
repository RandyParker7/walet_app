import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditKaryawanPage extends StatefulWidget {
  final String karyawanId;
  final String currentUsername;

  const EditKaryawanPage({Key? key, required this.karyawanId, required this.currentUsername}) : super(key: key);

  @override
  _EditKaryawanPageState createState() => _EditKaryawanPageState();
}

class _EditKaryawanPageState extends State<EditKaryawanPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentUsername;
  }

  Future<void> _updateKaryawan() async {
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
      if (name != widget.currentUsername) {
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
      }

      Map<String, dynamic> updateData = {
        'username': name,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.karyawanId)
          .update(updateData);

      setState(() {
        _success = 'Karyawan berhasil diperbarui';
      });

      await Future.delayed(const Duration(seconds: 1));
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
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      appBar: AppBar(
        title: const Text('Edit Karyawan'),
        backgroundColor: const Color(0xFF4355B9),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                    backgroundColor: const Color(0xFF4355B9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _isLoading ? null : _updateKaryawan,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text(
                          'Update',
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
