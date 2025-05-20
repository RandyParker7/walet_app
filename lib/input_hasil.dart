import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputHasilCuciPage extends StatefulWidget {
  final String partaiId;
  final String username;

  const InputHasilCuciPage({super.key, required this.partaiId, required this.username});

  @override
  State<InputHasilCuciPage> createState() => _InputHasilCuciPageState();
}

class _InputHasilCuciPageState extends State<InputHasilCuciPage> {
  final TextEditingController _beratBersihController = TextEditingController();
  final TextEditingController _kikisController = TextEditingController();
  final TextEditingController _bubukController = TextEditingController();
  final TextEditingController _gerindaController = TextEditingController();
  final TextEditingController _karatanController = TextEditingController();
  final TextEditingController _hancuranController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _submitHasilCuci() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final kikis = double.tryParse(_kikisController.text.trim()) ?? 0;
      final bubuk = double.tryParse(_bubukController.text.trim()) ?? 0;
      final gerinda = double.tryParse(_gerindaController.text.trim()) ?? 0;
      final karatan = double.tryParse(_karatanController.text.trim()) ?? 0;
      final hancuran = double.tryParse(_hancuranController.text.trim()) ?? 0;
      final beratBersih = double.tryParse(_beratBersihController.text.trim()) ?? 0;

      final total = kikis + bubuk + gerinda + karatan + hancuran;

      final hasilCuci = {
        'berat_bersih': beratBersih,
        'kikis': kikis,
        'bubuk': bubuk,
        'gerinda': gerinda,
        'karatan': karatan,
        'hancuran': hancuran,
        'total': total,
      };

      await FirebaseFirestore.instance
          .collection('partai')
          .doc(widget.partaiId)
          .update({
        'hasil_cuci': hasilCuci,
        'manager_username': widget.username,
        'status': 'Sudah Diproses',
        'updated_at': Timestamp.now(),
      });

      setState(() {
        _success = 'Hasil cuci berhasil disimpan';
        _beratBersihController.clear();
        _kikisController.clear();
        _bubukController.clear();
        _gerindaController.clear();
        _karatanController.clear();
        _hancuranController.clear();
      });

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      Navigator.pop(context);

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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
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
            'Input Hasil Cuci',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Berat Bersih', _beratBersihController),
              _buildTextField('Kikis', _kikisController),
              _buildTextField('Bubuk', _bubukController),
              _buildTextField('Gerinda', _gerindaController),
              _buildTextField('Karatan', _karatanController),
              _buildTextField('Hancuran', _hancuranController),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_success != null)
                Text(_success!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _submitHasilCuci,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
