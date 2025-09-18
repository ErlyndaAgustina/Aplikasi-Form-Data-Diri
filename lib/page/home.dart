import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'form.dart';
import 'edit.dart';
import 'dart:io';
import 'dart:async';
import 'splashscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> siswaList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> _dusunList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _fetchData();
    _fetchDusun();
    _searchController.addListener(_onSearchChanged);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      for (ConnectivityResult result in results) {
        if (result == ConnectivityResult.none) {
          _showErrorDialog(
            title: 'Tidak Ada Koneksi Internet',
            message: 'Silakan periksa jaringan Anda.',
            lottieAsset: 'assets/animations/no_internet.json',
          );
          return; // Exit the loop after showing the error dialog
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorDialog(
        title: 'Tidak Ada Koneksi Internet',
        message: 'Silakan periksa jaringan Anda.',
        lottieAsset: 'assets/animations/no_internet.json',
      );
    }
  }

  Future<void> _showErrorDialog({
    required String title,
    required String message,
    required String lottieAsset,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async =>
            false, // Mencegah penutupan dialog dengan back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottieAsset,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF95BB72),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF95BB72),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchData();
                _fetchDusun();
              },
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchDusun() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await _showErrorDialog(
          title: 'Tidak Ada Koneksi Internet',
          message: 'Silakan periksa jaringan Anda.',
          lottieAsset: 'assets/animations/no_internet.json',
        );
        return;
      }

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
    } catch (e) {
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          isLoading = false;
        });
        await Future.delayed(Duration.zero);
        await _showErrorDialog(
          title: 'Tidak Ada Koneksi Internet',
          message: 'Silakan periksa jaringan Anda.',
          lottieAsset: 'assets/animations/no_internet.json',
        );
        return;
      }

      final response = await supabase
          .from('siswa')
          .select(
            '*, wali(nama_wali, nama_ayah, nama_ibu, jalan, rt_rw, dusun, desa, kecamatan, kabupaten, provinsi, kode_pos, alamat_id)',
          )
          .order('nama', ascending: true);
      List<Map<String, dynamic>> data = [];
      if (response != null && response is List) {
        data = (response).cast<Map<String, dynamic>>();
      }

      setState(() {
        siswaList = data;
        filteredList = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();
      setState(() {
        filteredList = siswaList.where((siswa) {
          final nama = (siswa['nama'] ?? '').toString().toLowerCase();
          final nisn = (siswa['nisn'] ?? '').toString().toLowerCase();
          final namaAyah = (siswa['wali']?['nama_ayah'] ?? '')
              .toString()
              .toLowerCase();
          final namaIbu = (siswa['wali']?['nama_ibu'] ?? '')
              .toString()
              .toLowerCase();
          return nama.contains(query) ||
              nisn.contains(query) ||
              namaAyah.contains(query) ||
              namaIbu.contains(query);
        }).toList();
      });
    });
  }

  Future<void> _deleteData(int id, String nama) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await _showErrorDialog(
          title: 'Tidak Ada Koneksi Internet',
          message: 'Silakan periksa jaringan Anda.',
          lottieAsset: 'assets/animations/no_internet.json',
        );
        return;
      }

      final siswa = siswaList.firstWhere((s) => s['id'] == id);
      final waliId = siswa['wali_id'];
      final alamatIdSiswa = siswa['alamat_id'];
      final alamatIdWali = siswa['wali']?['alamat_id'];

      await supabase.from('siswa').delete().eq('id', id);
      if (waliId != null) {
        await supabase.from('wali').delete().eq('id', waliId);
      }

      if (alamatIdSiswa != null) {
        final siswaCount =
            (await supabase
                    .from('siswa')
                    .select()
                    .eq('alamat_id', alamatIdSiswa)
                    .count())
                .count;
        if (siswaCount == 0) {
          await supabase.from('alamat_master').delete().eq('id', alamatIdSiswa);
        }
      }
      if (alamatIdWali != null) {
        final waliCount =
            (await supabase
                    .from('wali')
                    .select()
                    .eq('alamat_id', alamatIdWali)
                    .count())
                .count;
        if (waliCount == 0) {
          await supabase.from('alamat_master').delete().eq('id', alamatIdWali);
        }
      }

      await _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data siswa '$nama' berhasil dihapus"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
    }
  }

  void _confirmDelete(int id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/hapus.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              "Konfirmasi Hapus",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Yakin ingin menghapus data siswa '$nama'?",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF95BB72),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteData(id, nama);
            },
            child: Text(
              "Hapus",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          "Detail Siswa:\n${siswa['nama']}",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: Text(
                  "Data Siswa",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF95BB72),
                  ),
                ),
                children: [
                  _buildDetailTile("NISN", siswa['nisn']),
                  _buildDetailTile("Nama", siswa['nama']),
                  _buildDetailTile("Jenis Kelamin", siswa['jenis_kelamin']),
                  _buildDetailTile("Agama", siswa['agama']),
                  _buildDetailTile("Tempat, Tanggal Lahir", siswa['ttl']),
                  _buildDetailTile("No. Tlp/HP", siswa['no_hp']),
                  _buildDetailTile("NIK", siswa['nik']),
                ],
              ),
              ExpansionTile(
                title: Text(
                  "Alamat",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF95BB72),
                  ),
                ),
                children: [
                  _buildDetailTile("Jalan", siswa['jalan']),
                  _buildDetailTile("RT/RW", siswa['rt_rw']),
                  _buildDetailTile("Dusun", siswa['dusun']),
                  _buildDetailTile("Desa", siswa['desa']),
                  _buildDetailTile("Kecamatan", siswa['kecamatan']),
                  _buildDetailTile("Kabupaten", siswa['kabupaten']),
                  _buildDetailTile("Provinsi", siswa['provinsi']),
                  _buildDetailTile("Kode Pos", siswa['kode_pos']),
                ],
              ),
              ExpansionTile(
                title: Text(
                  "Orang Tua / Wali",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF95BB72),
                  ),
                ),
                children: [
                  _buildDetailTile(
                    "Nama Ayah",
                    siswa['wali']?['nama_ayah'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Nama Ibu",
                    siswa['wali']?['nama_ibu'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Nama Wali",
                    siswa['wali']?['nama_wali'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Jalan",
                    siswa['wali']?['jalan'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "RT/RW",
                    siswa['wali']?['rt_rw'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Dusun",
                    siswa['wali']?['dusun'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Desa",
                    siswa['wali']?['desa'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Kecamatan",
                    siswa['wali']?['kecamatan'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Kabupaten",
                    siswa['wali']?['kabupaten'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Provinsi",
                    siswa['wali']?['provinsi'] ?? 'Tidak tersedia',
                  ),
                  _buildDetailTile(
                    "Kode Pos",
                    siswa['wali']?['kode_pos'] ?? 'Tidak tersedia',
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF95BB72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditPage(Map<String, dynamic> siswa) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPage(siswa: siswa)),
    ).then((result) {
      if (result == true) {
        _fetchData();
      }
    });
  }

  void _openFormPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPage()),
    ).then((_) => _fetchData());
  }

  Widget _buildDetailTile(String title, String? value) {
    return ListTile(
      title: Text(
        "$title: ${value ?? '-'}",
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Theme(
      data: ThemeData(
        primaryColor: const Color(0xFF95BB72),
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF95BB72),
          secondary: Color(0xFFA8D08D),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black87,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineSmall: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
            horizontal: 16,
            vertical: 12,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
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
          errorStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF95BB72),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Data Siswa',
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari siswa, NISN, atau nama orang tua...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF95BB72),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) => RefreshIndicator(
                  onRefresh: () async {
                    await _fetchData();
                  },
                  color: const Color(0xFF95BB72),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF95BB72),
                          ),
                        )
                      : filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animations/no_data.json',
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data siswa',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final siswa = filteredList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: const Color(0xFF95BB72),
                                  child: Text(
                                    siswa['nama']
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  siswa['nama'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "NISN: ${siswa['nisn'] ?? '-'}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'detail') _showDetail(siswa);
                                    if (value == 'edit') _openEditPage(siswa);
                                    if (value == 'delete')
                                      _confirmDelete(
                                        siswa['id'],
                                        siswa['nama'],
                                      );
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'detail',
                                      child: Text(
                                        'Detail',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Hapus',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: screenWidth * 0.2,
          width: screenWidth * 0.2,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF95BB72),
            elevation: 0,
            onPressed: _openFormPage,
            child: Icon(
              Icons.add,
              size: screenWidth * 0.1,
              color: Colors.white,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: const Color(0xFF95BB72),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.home,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: screenWidth * 0.1125,
                ),
              ),
              SizedBox(width: screenWidth * 0.3),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: screenWidth * 0.1125,
                ),
                onPressed: () async {
                  await _fetchData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
