import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> siswa;

  const EditPage({super.key, required this.siswa});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _currentStep = 0;

  late final _nisnController = TextEditingController(
    text: widget.siswa['nisn'],
  );
  late final _namaController = TextEditingController(
    text: widget.siswa['nama'],
  );
  late String? _jenisKelamin = widget.siswa['jenis_kelamin'];
  late String? _agama = widget.siswa['agama'];
  late final _tempatLahirController = TextEditingController(
    text: widget.siswa['ttl']?.split(', ')[0] ?? '',
  );
  late final _tanggalLahirController = TextEditingController(
    text: widget.siswa['ttl']?.split(', ')[1] ?? '',
  );
  late final _noHpController = TextEditingController(
    text: widget.siswa['no_hp'],
  );
  late final _nikController = TextEditingController(text: widget.siswa['nik']);
  late final _jalanController = TextEditingController(
    text: widget.siswa['jalan'],
  );
  late final _rtRwController = TextEditingController(
    text: widget.siswa['rt_rw'],
  );
  late final _dusunController = TextEditingController(
    text: widget.siswa['dusun'],
  );
  late final _desaController = TextEditingController(
    text: widget.siswa['desa'],
  );
  late final _kecamatanController = TextEditingController(
    text: widget.siswa['kecamatan'],
  );
  late final _kabupatenController = TextEditingController(
    text: widget.siswa['kabupaten'],
  );
  late final _provinsiController = TextEditingController(
    text: widget.siswa['provinsi'],
  );
  late final _kodePosController = TextEditingController(
    text: widget.siswa['kode_pos'],
  );
  late final _ayahController = TextEditingController(
    text: widget.siswa['wali']?['nama_ayah'] ?? '',
  );
  late final _ibuController = TextEditingController(
    text: widget.siswa['wali']?['nama_ibu'] ?? '',
  );
  late final _waliController = TextEditingController(
    text: widget.siswa['wali']?['nama_wali'] ?? '',
  );
  late final _alamatWaliJalanController = TextEditingController(
    text: widget.siswa['wali']?['jalan'] ?? '',
  );
  late final _alamatWaliRtRwController = TextEditingController(
    text: widget.siswa['wali']?['rt_rw'] ?? '',
  );
  late final _alamatWaliDusunController = TextEditingController(
    text: widget.siswa['wali']?['dusun'] ?? '',
  );
  late final _alamatWaliDesaController = TextEditingController(
    text: widget.siswa['wali']?['desa'] ?? '',
  );
  late final _alamatWaliKecamatanController = TextEditingController(
    text: widget.siswa['wali']?['kecamatan'] ?? '',
  );
  late final _alamatWaliKabupatenController = TextEditingController(
    text: widget.siswa['wali']?['kabupaten'] ?? '',
  );
  late final _alamatWaliProvinsiController = TextEditingController(
    text: widget.siswa['wali']?['provinsi'] ?? '',
  );
  late final _alamatWaliKodePosController = TextEditingController(
    text: widget.siswa['wali']?['kode_pos'] ?? '',
  );

  List<Map<String, dynamic>> _dusunList = [];

  @override
  void initState() {
    super.initState();
    _fetchDusun();
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _fetchDusun() async {
    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    try {
      final kalipare = await supabase.from('alamat_kalipare').select();
      final selorejo = await supabase.from('alamat_selorejo').select();
      final kromengan = await supabase.from('alamat_kromengan').select();
      final sumberpucung = await supabase.from('alamat_sumberpucung').select();

      setState(() {
        _dusunList = [
          ...kalipare.map((item) => {...item, 'table': 'alamat_kalipare'}),
          ...selorejo.map((item) => {...item, 'table': 'alamat_selorejo'}),
          ...kromengan.map((item) => {...item, 'table': 'alamat_kromengan'}),
          ...sumberpucung.map(
            (item) => {...item, 'table': 'alamat_sumberpucung'},
          ),
        ];
      });

      if (_dusunList.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tidak ada data dusun.')));
      }
    } catch (e) {
      String errorMessage = 'Gagal mengambil data dusun: $e';
      if (e is SocketException || e is TimeoutException) {
        errorMessage =
            'Gagal terhubung ke Supabase. Silakan periksa koneksi server.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF95BB72),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _validateInputs() {
    final nisn = _nisnController.text.trim();
    if (nisn.isEmpty) return 'NISN harus diisi!';
    if (nisn.length != 10) return 'NISN harus terdiri dari 10 karakter!';
    if (!RegExp(r'^\d{10}$').hasMatch(nisn))
      return 'NISN hanya boleh berisi angka!';

    if (_namaController.text.trim().isEmpty) return 'Nama Lengkap harus diisi!';
    if (_jenisKelamin == null) return 'Jenis Kelamin harus dipilih!';
    if (_agama == null) return 'Agama harus dipilih!';
    if (_tempatLahirController.text.trim().isEmpty)
      return 'Tempat Lahir harus diisi!';
    if (_tanggalLahirController.text.trim().isEmpty)
      return 'Tanggal Lahir harus diisi!';

    final noHp = _noHpController.text.trim();
    if (noHp.isEmpty) return 'No. Tlp/HP harus diisi!';
    if (noHp.length < 12 || noHp.length > 15)
      return 'No. Tlp/HP harus terdiri dari 12 hingga 15 karakter!';
    if (!RegExp(r'^\d+$').hasMatch(noHp))
      return 'No. Tlp/HP hanya boleh berisi angka!';

    final nik = _nikController.text.trim();
    if (nik.isEmpty) return 'NIK harus diisi!';
    if (nik.length != 16) return 'NIK harus terdiri dari 16 karakter!';
    if (!RegExp(r'^\d{16}$').hasMatch(nik))
      return 'NIK hanya boleh berisi angka!';

    if (_jalanController.text.trim().isEmpty) return 'Jalan harus diisi!';
    if (_rtRwController.text.trim().isEmpty) return 'RT/RW harus diisi!';
    if (!RegExp(r'^\d{3}/\d{3}$').hasMatch(_rtRwController.text.trim()))
      return 'RT/RW harus dalam format 001/002 dan hanya berisi angka!';

    if (_ayahController.text.trim().isEmpty) return 'Nama Ayah harus diisi!';
    if (_ibuController.text.trim().isEmpty) return 'Nama Ibu harus diisi!';
    return null;
  }

  Future<void> _updateData() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      final selectedDusunSiswa = _dusunList.firstWhere(
        (d) => d['dusun'] == _dusunController.text,
        orElse: () => {},
      );

      int? alamatIdSiswa;
      if (selectedDusunSiswa.isNotEmpty) {
        final alamatMasterDataSiswa = {
          if (selectedDusunSiswa['table'] == 'alamat_kalipare')
            'alamat_kalipare_id': selectedDusunSiswa['id'],
          if (selectedDusunSiswa['table'] == 'alamat_selorejo')
            'alamat_selorejo_id': selectedDusunSiswa['id'],
          if (selectedDusunSiswa['table'] == 'alamat_kromengan')
            'alamat_kromengan_id': selectedDusunSiswa['id'],
          if (selectedDusunSiswa['table'] == 'alamat_sumberpucung')
            'alamat_sumberpucung_id': selectedDusunSiswa['id'],
          'jalan': _jalanController.text.trim(),
          'rt_rw': _rtRwController.text.trim(),
        };

        final existingAlamatId = widget.siswa['alamat_id'];
        if (existingAlamatId != null) {
          await supabase
              .from('alamat_master')
              .update(alamatMasterDataSiswa)
              .eq('id', existingAlamatId);
          alamatIdSiswa = existingAlamatId;
        } else {
          final alamatMasterResponseSiswa = await supabase
              .from('alamat_master')
              .insert(alamatMasterDataSiswa)
              .select('id')
              .single();
          alamatIdSiswa = alamatMasterResponseSiswa['id'];
        }
      }

      final selectedDusunWali = _dusunList.firstWhere(
        (d) => d['dusun'] == _alamatWaliDusunController.text,
        orElse: () => {},
      );

      int? alamatIdWali;
      if (selectedDusunWali.isNotEmpty) {
        final alamatMasterDataWali = {
          if (selectedDusunWali['table'] == 'alamat_kalipare')
            'alamat_kalipare_id': selectedDusunWali['id'],
          if (selectedDusunWali['table'] == 'alamat_selorejo')
            'alamat_selorejo_id': selectedDusunWali['id'],
          if (selectedDusunWali['table'] == 'alamat_kromengan')
            'alamat_kromengan_id': selectedDusunWali['id'],
          if (selectedDusunWali['table'] == 'alamat_sumberpucung')
            'alamat_sumberpucung_id': selectedDusunWali['id'],
          'jalan': _alamatWaliJalanController.text.trim(),
          'rt_rw': _alamatWaliRtRwController.text.trim(),
        };

        final existingWaliAlamatId = widget.siswa['wali']?['alamat_id'];
        if (existingWaliAlamatId != null) {
          await supabase
              .from('alamat_master')
              .update(alamatMasterDataWali)
              .eq('id', existingWaliAlamatId);
          alamatIdWali = existingWaliAlamatId;
        } else {
          final alamatMasterResponseWali = await supabase
              .from('alamat_master')
              .insert(alamatMasterDataWali)
              .select('id')
              .single();
          alamatIdWali = alamatMasterResponseWali['id'];
        }
      }

      final waliData = {
        'nama_wali': _waliController.text.trim().isEmpty
            ? null
            : _waliController.text.trim(),
        'nama_ayah': _ayahController.text.trim(),
        'nama_ibu': _ibuController.text.trim(),
        'jalan': _alamatWaliJalanController.text.trim().isEmpty
            ? null
            : _alamatWaliJalanController.text.trim(),
        'rt_rw': _alamatWaliRtRwController.text.trim().isEmpty
            ? null
            : _alamatWaliRtRwController.text.trim(),
        'dusun': _alamatWaliDusunController.text.isEmpty
            ? null
            : _alamatWaliDusunController.text,
        'desa': _alamatWaliDesaController.text.isEmpty
            ? null
            : _alamatWaliDesaController.text,
        'kecamatan': _alamatWaliKecamatanController.text.isEmpty
            ? null
            : _alamatWaliKecamatanController.text,
        'kabupaten': _alamatWaliKabupatenController.text.isEmpty
            ? null
            : _alamatWaliKabupatenController.text,
        'provinsi': _alamatWaliProvinsiController.text.isEmpty
            ? null
            : _alamatWaliProvinsiController.text,
        'kode_pos': _alamatWaliKodePosController.text.isEmpty
            ? null
            : _alamatWaliKodePosController.text,
        if (alamatIdWali != null) 'alamat_id': alamatIdWali,
      };

      await supabase
          .from('wali')
          .update(waliData)
          .eq('id', widget.siswa['wali_id']);

      final ttl =
          '${_tempatLahirController.text.trim()}, ${_tanggalLahirController.text.trim()}';

      final data = {
        'nisn': _nisnController.text.trim(),
        'nama': _namaController.text.trim(),
        'jenis_kelamin': _jenisKelamin ?? '',
        'agama': _agama ?? '',
        'ttl': ttl,
        'no_hp': _noHpController.text.trim(),
        'nik': _nikController.text.trim(),
        'jalan': _jalanController.text.trim(),
        'rt_rw': _rtRwController.text.trim(),
        'dusun': _dusunController.text,
        'desa': _desaController.text,
        'kecamatan': _kecamatanController.text,
        'kabupaten': _kabupatenController.text,
        'provinsi': _provinsiController.text,
        'kode_pos': _kodePosController.text,
        'wali_id': widget.siswa['wali_id'],
        if (alamatIdSiswa != null) 'alamat_id': alamatIdSiswa,
      };

      await supabase.from('siswa').update(data).eq('id', widget.siswa['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Data siswa '${_namaController.text}' berhasil diperbarui",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          backgroundColor: const Color(0xFF95BB72),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      String errorMessage = 'Gagal memperbarui data: $e';
      if (e is SocketException || e is TimeoutException) {
        errorMessage =
            'Gagal terhubung ke Supabase. Silakan periksa koneksi server.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nisnController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
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
    _alamatWaliJalanController.dispose();
    _alamatWaliRtRwController.dispose();
    _alamatWaliDusunController.dispose();
    _alamatWaliDesaController.dispose();
    _alamatWaliKecamatanController.dispose();
    _alamatWaliKabupatenController.dispose();
    _alamatWaliProvinsiController.dispose();
    _alamatWaliKodePosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: const Color(0xFF95BB72),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF95BB72),
          secondary: Color(0xFFA8D08D),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineSmall: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF95BB72), width: 2),
          ),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[500],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF95BB72),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            elevation: 2,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Data Siswa',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF95BB72),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 32 : 16,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF95BB72),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF95BB72),
                        ),
                      ),
                      child: Stepper(
                        currentStep: _currentStep,
                        onStepContinue: () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            _updateData();
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        controlsBuilder: (context, details) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                if (_currentStep > 0)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF95BB72),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        'Kembali',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF95BB72),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_currentStep > 0) const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    child: Text(
                                      _currentStep == 2 ? 'Simpan' : 'Lanjut',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        steps: [
                          Step(
                            title: Text(
                              'Data Siswa',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _currentStep >= 0
                                    ? const Color(0xFF95BB72)
                                    : Colors.grey,
                              ),
                            ),
                            content: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _nisnController,
                                      decoration: InputDecoration(
                                        labelText: 'NISN',
                                        hintText:
                                            'Masukkan NISN, dengan jumlah 10 karakter',
                                        prefixIcon: const Icon(
                                          Icons.badge,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      onChanged: (value) {
                                        final cleanValue = value.replaceAll(
                                          RegExp(r'[^0-9]'),
                                          '',
                                        );
                                        if (cleanValue != value) {
                                          _nisnController
                                              .value = TextEditingValue(
                                            text: cleanValue,
                                            selection: TextSelection.collapsed(
                                              offset: cleanValue.length,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _namaController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Lengkap',
                                        hintText: 'Masukkan nama lengkap',
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _jenisKelamin,
                                      decoration: InputDecoration(
                                        labelText: 'Jenis Kelamin',
                                        prefixIcon: const Icon(
                                          Icons.transgender,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      items:
                                          [
                                            {
                                              "label": "Laki-laki",
                                              "icon": Icons.male,
                                              "color": Colors.blue,
                                            },
                                            {
                                              "label": "Perempuan",
                                              "icon": Icons.female,
                                              "color": Colors.pink,
                                            },
                                          ].map((jk) {
                                            return DropdownMenuItem<String>(
                                              value: jk["label"] as String?,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    jk["icon"] as IconData?,
                                                    color:
                                                        jk["color"] as Color?,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      jk["label"].toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (val) =>
                                          setState(() => _jenisKelamin = val),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _agama,
                                      decoration: InputDecoration(
                                        labelText: 'Agama',
                                        prefixIcon: const Icon(
                                          Icons.self_improvement,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      items:
                                          [
                                                'Islam',
                                                'Kristen',
                                                'Katolik',
                                                'Hindu',
                                                'Budha',
                                                'Konghucu',
                                              ]
                                              .map(
                                                (a) => DropdownMenuItem<String>(
                                                  value: a,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          a,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) =>
                                          setState(() => _agama = val),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _tempatLahirController,
                                      decoration: InputDecoration(
                                        labelText: 'Tempat Lahir',
                                        hintText: 'Masukkan tempat lahir',
                                        prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _tanggalLahirController,
                                      decoration: InputDecoration(
                                        labelText: 'Tanggal Lahir',
                                        hintText: 'Pilih tanggal lahir',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                      onTap: _selectDate,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _noHpController,
                                      decoration: InputDecoration(
                                        labelText: 'No. Tlp/HP',
                                        hintText:
                                            'Wajib diisi dengan jumlah 12-15 karakter',
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(15),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _nikController,
                                      decoration: InputDecoration(
                                        labelText: 'NIK',
                                        prefixIcon: const Icon(
                                          Icons.badge,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep > 0
                                ? StepState.complete
                                : StepState.indexed,
                          ),
                          Step(
                            title: Text(
                              'Alamat',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _currentStep >= 1
                                    ? const Color(0xFF95BB72)
                                    : Colors.grey,
                              ),
                            ),
                            content: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _jalanController,
                                      decoration: InputDecoration(
                                        labelText: 'Jalan',
                                        hintText: 'Masukkan nama jalan',
                                        prefixIcon: const Icon(
                                          Icons.location_on,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _rtRwController,
                                      decoration: InputDecoration(
                                        labelText: 'RT/RW',
                                        hintText:
                                            'Masukkan RT/RW (contoh: 001/002)',
                                        prefixIcon: const Icon(
                                          Icons.map,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Autocomplete<Map<String, dynamic>>(
                                      initialValue: TextEditingValue(
                                        text: _dusunController.text,
                                      ),
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                            final input = textEditingValue.text
                                                .toLowerCase();
                                            if (input.isEmpty)
                                              return _dusunList;
                                            return _dusunList.where((d) {
                                              final dusun =
                                                  (d['dusun'] as String?)
                                                      ?.toLowerCase() ??
                                                  '';
                                              return dusun.contains(input);
                                            }).toList();
                                          },
                                      displayStringForOption: (d) =>
                                          '${d['dusun']} (${d['desa']}, ${d['kecamatan']})',
                                      fieldViewBuilder:
                                          (
                                            context,
                                            controller,
                                            focusNode,
                                            onEditingComplete,
                                          ) {
                                            controller.text =
                                                _dusunController.text;
                                            return TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                labelText: 'Dusun',
                                                hintText:
                                                    'Ketik untuk mencari dusun',
                                                prefixIcon: const Icon(
                                                  Icons.location_on,
                                                  color: Color(0xFF95BB72),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                _dusunController.text = value;
                                              },
                                              onEditingComplete:
                                                  onEditingComplete,
                                            );
                                          },
                                      onSelected: (selected) {
                                        setState(() {
                                          _dusunController.text =
                                              selected['dusun']?.toString() ??
                                              '';
                                          _desaController.text =
                                              selected['desa']?.toString() ??
                                              '';
                                          _kecamatanController.text =
                                              selected['kecamatan']
                                                  ?.toString() ??
                                              '';
                                          _kabupatenController.text =
                                              selected['kabupaten']
                                                  ?.toString() ??
                                              '';
                                          _provinsiController.text =
                                              selected['provinsi']
                                                  ?.toString() ??
                                              '';
                                          _kodePosController.text =
                                              selected['kode_pos']
                                                  ?.toString() ??
                                              '';
                                          if (_jalanController.text.isEmpty) {
                                            _jalanController.text =
                                                selected['jalan']?.toString() ??
                                                '';
                                          }
                                          if (_rtRwController.text.isEmpty) {
                                            _rtRwController.text =
                                                selected['rt_rw']?.toString() ??
                                                '';
                                          }
                                        });
                                      },
                                      optionsViewBuilder:
                                          (context, onSelected, options) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                elevation: 4.0,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: 200,
                                                    maxWidth:
                                                        constraints.maxWidth -
                                                        32,
                                                  ),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: options.length,
                                                    itemBuilder: (context, index) {
                                                      final option = options
                                                          .elementAt(index);
                                                      return ListTile(
                                                        title: Text(
                                                          '${option['dusun']} (${option['desa']}, ${option['kecamatan']})',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        onTap: () =>
                                                            onSelected(option),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _desaController,
                                      decoration: InputDecoration(
                                        labelText: 'Desa',
                                        prefixIcon: const Icon(
                                          Icons.holiday_village,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _kecamatanController,
                                      decoration: InputDecoration(
                                        labelText: 'Kecamatan',
                                        prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _kabupatenController,
                                      decoration: InputDecoration(
                                        labelText: 'Kabupaten',
                                        prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _provinsiController,
                                      decoration: InputDecoration(
                                        labelText: 'Provinsi',
                                        prefixIcon: const Icon(
                                          Icons.public,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _kodePosController,
                                      decoration: InputDecoration(
                                        labelText: 'Kode Pos',
                                        prefixIcon: const Icon(
                                          Icons.local_post_office,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1
                                ? StepState.complete
                                : StepState.indexed,
                          ),
                          Step(
                            title: Text(
                              'Orang Tua / Wali',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _currentStep >= 2
                                    ? const Color(0xFF95BB72)
                                    : Colors.grey,
                              ),
                            ),
                            content: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _ayahController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Ayah',
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _ibuController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Ibu',
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _waliController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Wali (opsional)',
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _alamatWaliJalanController,
                                      decoration: InputDecoration(
                                        labelText: 'Jalan',
                                        hintText:
                                            'Masukkan nama jalan (opsional)',
                                        prefixIcon: const Icon(
                                          Icons.streetview,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _alamatWaliRtRwController,
                                      decoration: InputDecoration(
                                        labelText: 'RT/RW',
                                        hintText:
                                            'Masukkan RT/RW (contoh: 001/002)',
                                        prefixIcon: const Icon(
                                          Icons.map,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Autocomplete<Map<String, dynamic>>(
                                      initialValue: TextEditingValue(
                                        text: _alamatWaliDusunController.text,
                                      ),
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                            final input = textEditingValue.text
                                                .toLowerCase();
                                            if (input.isEmpty)
                                              return _dusunList;
                                            return _dusunList.where((d) {
                                              final dusun =
                                                  (d['dusun'] as String?)
                                                      ?.toLowerCase() ??
                                                  '';
                                              return dusun.contains(input);
                                            }).toList();
                                          },
                                      displayStringForOption: (d) =>
                                          '${d['dusun']} (${d['desa']}, ${d['kecamatan']})',
                                      fieldViewBuilder:
                                          (
                                            context,
                                            controller,
                                            focusNode,
                                            onEditingComplete,
                                          ) {
                                            controller.text =
                                                _alamatWaliDusunController.text;
                                            return TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                labelText: 'Dusun',
                                                hintText:
                                                    'Ketik untuk mencari dusun',
                                                prefixIcon: const Icon(
                                                  Icons.location_on,
                                                  color: Color(0xFF95BB72),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                _alamatWaliDusunController
                                                        .text =
                                                    value;
                                              },
                                              onEditingComplete:
                                                  onEditingComplete,
                                            );
                                          },
                                      onSelected: (selected) {
                                        setState(() {
                                          _alamatWaliDusunController.text =
                                              selected['dusun']?.toString() ??
                                              '';
                                          _alamatWaliDesaController.text =
                                              selected['desa']?.toString() ??
                                              '';
                                          _alamatWaliKecamatanController.text =
                                              selected['kecamatan']
                                                  ?.toString() ??
                                              '';
                                          _alamatWaliKabupatenController.text =
                                              selected['kabupaten']
                                                  ?.toString() ??
                                              '';
                                          _alamatWaliProvinsiController.text =
                                              selected['provinsi']
                                                  ?.toString() ??
                                              '';
                                          _alamatWaliKodePosController.text =
                                              selected['kode_pos']
                                                  ?.toString() ??
                                              '';
                                          if (_alamatWaliJalanController
                                              .text
                                              .isEmpty) {
                                            _alamatWaliJalanController.text =
                                                selected['jalan']?.toString() ??
                                                '';
                                          }
                                          if (_alamatWaliRtRwController
                                              .text
                                              .isEmpty) {
                                            _alamatWaliRtRwController.text =
                                                selected['rt_rw']?.toString() ??
                                                '';
                                          }
                                        });
                                      },
                                      optionsViewBuilder:
                                          (context, onSelected, options) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                elevation: 4.0,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: 200,
                                                    maxWidth:
                                                        constraints.maxWidth -
                                                        32,
                                                  ),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: options.length,
                                                    itemBuilder: (context, index) {
                                                      final option = options
                                                          .elementAt(index);
                                                      return ListTile(
                                                        title: Text(
                                                          '${option['dusun']} (${option['desa']}, ${option['kecamatan']})',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        onTap: () =>
                                                            onSelected(option),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _alamatWaliDesaController,
                                      decoration: InputDecoration(
                                        labelText: 'Desa',
                                        prefixIcon: const Icon(
                                          Icons.holiday_village,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller:
                                          _alamatWaliKecamatanController,
                                      decoration: InputDecoration(
                                        labelText: 'Kecamatan',
                                        prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller:
                                          _alamatWaliKabupatenController,
                                      decoration: InputDecoration(
                                        labelText: 'Kabupaten',
                                        prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _alamatWaliProvinsiController,
                                      decoration: InputDecoration(
                                        labelText: 'Provinsi',
                                        prefixIcon: const Icon(
                                          Icons.public,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _alamatWaliKodePosController,
                                      decoration: InputDecoration(
                                        labelText: 'Kode Pos',
                                        hintText:
                                            'Masukkan kode pos (opsional)',
                                        prefixIcon: const Icon(
                                          Icons.local_post_office,
                                          color: Color(0xFF95BB72),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      readOnly: true,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 2,
                            state: _currentStep == 2
                                ? StepState.indexed
                                : StepState.complete,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
