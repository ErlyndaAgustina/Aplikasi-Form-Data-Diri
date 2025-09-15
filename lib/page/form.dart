import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  int _currentStep = 0;

  // Controller untuk tiap field
  final _nisnController = TextEditingController();
  final _namaController = TextEditingController();
  String? _jenisKelamin;
  String? _agama;
  final _ttlController = TextEditingController();
  final _noHpController = TextEditingController();
  final _nikController = TextEditingController();

  final _jalanController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _dusunController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kodePosController = TextEditingController();

  final _ayahController = TextEditingController();
  final _ibuController = TextEditingController();
  final _waliController = TextEditingController();
  final _alamatWaliController = TextEditingController();

  @override
  void dispose() {
    _nisnController.dispose();
    _namaController.dispose();
    _ttlController.dispose();
    _noHpController.dispose();
    _nikController.dispose();

    _jalanController.dispose();
    _rtRwController.dispose();
    _dusunController.dispose();
    _desaController.dispose();
    _kecamatanController.dispose();
    _kabupatenController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();

    _ayahController.dispose();
    _ibuController.dispose();
    _waliController.dispose();
    _alamatWaliController.dispose();

    super.dispose();
  }

  Future<void> _simpanData() async {
    // Validasi input wajib
    if (_nisnController.text.isEmpty || _namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NISN dan Nama harus diisi!')),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      final data = {
        'nisn': _nisnController.text,
        'nama': _namaController.text,
        'jenis_kelamin': _jenisKelamin ?? '',
        'agama': _agama ?? '',
        'ttl': _ttlController.text,
        'no_hp': _noHpController.text,
        'nik': _nikController.text,
        'jalan': _jalanController.text,
        'rt_rw': _rtRwController.text,
        'dusun': _dusunController.text,
        'desa': _desaController.text,
        'kecamatan': _kecamatanController.text,
        'kabupaten': _kabupatenController.text,
        'provinsi': _provinsiController.text,
        'kode_pos': _kodePosController.text,
        'nama_ayah': _ayahController.text,
        'nama_ibu': _ibuController.text,
        'nama_wali': _waliController.text,
        'alamat_wali': _alamatWaliController.text,
      };

      await supabase.from('siswa').insert(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
      Navigator.pop(context); // Kembali ke HomePage setelah simpan
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step(
        title: const Text('Data Siswa'),
        content: Column(
          children: [
            TextField(
              controller: _nisnController,
              decoration: const InputDecoration(
                labelText: 'NISN',
                hintText: 'Masukkan NISN',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
              ),
            ),
            DropdownButtonFormField<String>(
              value: _jenisKelamin,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                hintText: 'Pilih jenis kelamin',
              ),
              items: ['Laki-laki', 'Perempuan']
                  .map((jk) => DropdownMenuItem(value: jk, child: Text(jk)))
                  .toList(),
              onChanged: (val) => setState(() => _jenisKelamin = val),
            ),
            DropdownButtonFormField<String>(
              value: _agama,
              decoration: const InputDecoration(
                labelText: 'Agama',
                hintText: 'Pilih agama',
              ),
              items: [
                'Islam',
                'Kristen',
                'Katolik',
                'Hindu',
                'Budha',
                'Konghucu',
              ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) => setState(() => _agama = val),
            ),
            TextField(
              controller: _ttlController,
              decoration: const InputDecoration(
                labelText: 'Tempat, Tanggal Lahir',
                hintText: 'Contoh: Jakarta, 01-01-2000',
              ),
            ),
            TextField(
              controller: _noHpController,
              decoration: const InputDecoration(
                labelText: 'No. Tlp/HP',
                hintText: 'Masukkan nomor telepon',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: 'NIK',
                hintText: 'Masukkan NIK',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Alamat'),
        content: Column(
          children: [
            TextField(
              controller: _jalanController,
              decoration: const InputDecoration(
                labelText: 'Jalan',
                hintText: 'Masukkan nama jalan',
              ),
            ),
            TextField(
              controller: _rtRwController,
              decoration: const InputDecoration(
                labelText: 'RT/RW',
                hintText: 'Contoh: 001/002',
              ),
            ),
            TextField(
              controller: _dusunController,
              decoration: const InputDecoration(
                labelText: 'Dusun',
                hintText: 'Masukkan nama dusun',
              ),
            ),
            TextField(
              controller: _desaController,
              decoration: const InputDecoration(
                labelText: 'Desa',
                hintText: 'Masukkan nama desa',
              ),
            ),
            TextField(
              controller: _kecamatanController,
              decoration: const InputDecoration(
                labelText: 'Kecamatan',
                hintText: 'Masukkan nama kecamatan',
              ),
            ),
            TextField(
              controller: _kabupatenController,
              decoration: const InputDecoration(
                labelText: 'Kabupaten',
                hintText: 'Masukkan nama kabupaten',
              ),
            ),
            TextField(
              controller: _provinsiController,
              decoration: const InputDecoration(
                labelText: 'Provinsi',
                hintText: 'Masukkan nama provinsi',
              ),
            ),
            TextField(
              controller: _kodePosController,
              decoration: const InputDecoration(
                labelText: 'Kode Pos',
                hintText: 'Masukkan kode pos',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Orang Tua / Wali'),
        content: Column(
          children: [
            TextField(
              controller: _ayahController,
              decoration: const InputDecoration(
                labelText: 'Nama Ayah',
                hintText: 'Masukkan nama ayah',
              ),
            ),
            TextField(
              controller: _ibuController,
              decoration: const InputDecoration(
                labelText: 'Nama Ibu',
                hintText: 'Masukkan nama ibu',
              ),
            ),
            TextField(
              controller: _waliController,
              decoration: const InputDecoration(
                labelText: 'Nama Wali',
                hintText: 'Masukkan nama wali (opsional)',
              ),
            ),
            TextField(
              controller: _alamatWaliController,
              decoration: const InputDecoration(
                labelText: 'Alamat Wali',
                hintText: 'Masukkan alamat wali (opsional)',
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.indexed : StepState.complete,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Form Data Siswa')),
      body: Stepper(
        currentStep: _currentStep.clamp(0, steps.length - 1),
        steps: steps,
        onStepContinue: () {
          if (_currentStep < steps.length - 1) {
            setState(() {
              _currentStep++;
            });
          } else {
            _simpanData();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            Navigator.pop(context); // Kembali ke HomePage jika di step pertama
          }
        },
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: details.onStepCancel,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Kembali'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  _currentStep == steps.length - 1 ? 'Simpan' : 'Lanjut',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
