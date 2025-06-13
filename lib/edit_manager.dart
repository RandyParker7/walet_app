import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditManagerPage extends StatefulWidget {
  final String managerId;
  final String currentUsername;

  const EditManagerPage({Key? key, required this.managerId, required this.currentUsername}) : super(key: key);

  @override
  _EditManagerPageState createState() => _EditManagerPageState();
}

class _EditManagerPageState extends State<EditManagerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentUsername;
  }

  Future<void> _updateManager() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

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
      if (password.isNotEmpty) {
        updateData['password'] = password;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.managerId)
          .update(updateData);

      setState(() {
        _success = 'Manager berhasil diperbarui';
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
        title: const Text('Edit Manager'),
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
                _buildTextField('Password (kosongkan jika tidak ingin mengubah)', _passwordController, obscure: true),
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
                  onPressed: _isLoading ? null : _updateManager,
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
