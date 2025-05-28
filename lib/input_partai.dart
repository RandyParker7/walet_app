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
  String? _selectedNamaBahan;
  final List<String> _namaBahanOptions = [
    'Mangkok Bulu Berat',
    'Mangkok Bulu Sedang',
    'Mangkok Plontos',
    'Mangkok Patahan',
    'Mangkok Oval',
    'Mangkok Kakian',
  ];
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
      final namaBahan = _selectedNamaBahan?.trim() ?? '';
      final beratAwal = double.tryParse(_beratAwalController.text.trim());

      if (namaPartai.isEmpty || namaBahan.isEmpty || beratAwal == null) {
        setState(() {
          _error = 'Mohon isi semua data dengan benar';
        });
        return;
      }

      // Ambil persen pengurangan, default 10%
      final penguranganPersen =
          double.tryParse(_penguranganController.text.trim()) ?? 10;
      final pengurangan = beratAwal * (penguranganPersen / 100);
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
        _penguranganController.text = '10';
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
                // Replace TextField with Dropdown for Nama Bahan
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Bahan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                        child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            // Remove underline property as it is not supported
                            value: _selectedNamaBahan,
                            items: _namaBahanOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedNamaBahan = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Apakah Anda yakin ingin menyimpan data ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Ya'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            _submitData();
                          }
                        },
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
