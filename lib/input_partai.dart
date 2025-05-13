import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputPartaiPage extends StatefulWidget {
  const InputPartaiPage({super.key});

  @override
  State<InputPartaiPage> createState() => _InputPartaiPageState();
}

class _InputPartaiPageState extends State<InputPartaiPage> {
  final TextEditingController _namaPartaiController = TextEditingController();
  final TextEditingController _namaBahanController = TextEditingController();
  final TextEditingController _beratAwalController = TextEditingController();
  final TextEditingController _penguranganController =
      TextEditingController(text: '10');

  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final namaPartai = _namaPartaiController.text.trim();
      final namaBahan = _namaBahanController.text.trim();
      final beratAwal = double.tryParse(_beratAwalController.text.trim());
      double pengurangan;

      if (beratAwal != null) {
        // Jika pengurangan tidak diisi, set nilai pengurangan ke 10% dari beratAwal
        pengurangan = double.tryParse(_penguranganController.text.trim()) ?? beratAwal * 0.10;
      } else {
        pengurangan = 0; // Jika beratAwal tidak valid, set pengurangan menjadi 0
      }

      if (namaPartai.isEmpty || namaBahan.isEmpty || beratAwal == null || pengurangan == null) {
        setState(() {
          _error = 'Mohon isi semua data dengan benar';
        });
        return;
      }

      final beratAwalKering = beratAwal - pengurangan;

      await FirebaseFirestore.instance.collection('partai').add({
        'nama_partai': namaPartai,
        'nama_bahan': namaBahan,
        'berat_awal': beratAwalKering,
        'pengurangan_pengeringan': pengurangan,
        'status': 'Belum Diproses',
        'created_at': Timestamp.now(),
      });

      setState(() {
        _success = 'Data berhasil disimpan';
        _namaPartaiController.clear();
        _namaBahanController.clear();
        _beratAwalController.clear();
        _penguranganController.clear();
      });
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
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              keyboardType: keyboardType,
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
            'Input Partai',
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Nama Partai', _namaPartaiController),
                _buildTextField('Nama Bahan', _namaBahanController),
                _buildTextField('Berat Awal', _beratAwalController,
                    keyboardType: TextInputType.number),
                _buildTextField(
                    'Pengurangan Pengeringan (default 10%)', _penguranganController,
                    keyboardType: TextInputType.number),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                if (_success != null)
                  Text(_success!, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitData,
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
      ),
    );
  }
}
