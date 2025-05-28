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

  // List to hold dynamic pencuci entries
  List<Map<String, TextEditingController>> _pencuciControllers = [];

  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    // Initialize with one empty pencuci entry
    _addPencuciEntry();
  }

  void _addPencuciEntry() {
    setState(() {
      _pencuciControllers.add({
        'name': TextEditingController(),
        'gram': TextEditingController(),
        'pcs': TextEditingController(),
      });
    });
  }

  void _removePencuciEntry(int index) {
    setState(() {
      _pencuciControllers[index]['name']!.dispose();
      _pencuciControllers[index]['gram']!.dispose();
      _pencuciControllers[index]['pcs']!.dispose();
      _pencuciControllers.removeAt(index);
    });
  }

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

      // Collect pencuci entries into a list of maps
      List<Map<String, dynamic>> pencuciList = _pencuciControllers.map((entry) {
        final name = entry['name']!.text.trim();
        final gram = int.tryParse(entry['gram']!.text.trim()) ?? 0;
        final pcs = int.tryParse(entry['pcs']!.text.trim()) ?? 0;
        return {
          'name': name,
          'gram': gram,
          'pcs': pcs,
        };
      }).toList();

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
        'pencuci': pencuciList,
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
        // Clear all pencuci controllers
        for (var entry in _pencuciControllers) {
          entry['name']!.clear();
          entry['gram']!.clear();
          entry['pcs']!.clear();
        }
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

  Widget _buildPencuciEntry(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: _pencuciControllers[index]['name'],
              decoration: const InputDecoration(
                labelText: 'Nama Pencuci',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _pencuciControllers[index]['gram'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gram',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _pencuciControllers[index]['pcs'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pcs',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _removePencuciEntry(index);
            },
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
              // Render dynamic pencuci entries
              Column(
                children: List.generate(_pencuciControllers.length, (index) {
                  return _buildPencuciEntry(index);
                }),
              ),
              TextButton.icon(
                onPressed: _addPencuciEntry,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Pencuci'),
              ),
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
onPressed: _isLoading
    ? null
    : () async {
        // Validation: check if any required field is empty
        if (_beratBersihController.text.trim().isEmpty ||
            _kikisController.text.trim().isEmpty ||
            _bubukController.text.trim().isEmpty ||
            _gerindaController.text.trim().isEmpty ||
            _karatanController.text.trim().isEmpty ||
            _hancuranController.text.trim().isEmpty) {
          setState(() {
            _error = 'Semua field harus diisi sebelum submit.';
            _success = null;
          });
          return;
        }

        // Validate pencuci entries: all fields must be filled
        for (var entry in _pencuciControllers) {
          if (entry['name']!.text.trim().isEmpty ||
              entry['gram']!.text.trim().isEmpty ||
              entry['pcs']!.text.trim().isEmpty) {
            setState(() {
              _error = 'Semua field pencuci harus diisi sebelum submit.';
              _success = null;
            });
            return;
          }
        }

        setState(() {
          _error = null;
        });

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
          _submitHasilCuci();
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
    );
  }
}
