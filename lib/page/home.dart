import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> siswaList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await supabase.from('siswa').select();
      debugPrint("Response from Supabase: $response");
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
      debugPrint("Error fetching data: $e");
      setState(() {
        siswaList = [];
        filteredList = [];
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredList = siswaList.where((siswa) {
        final nama = (siswa['nama'] ?? '').toString().toLowerCase();
        final nisn = (siswa['nisn'] ?? '').toString().toLowerCase();
        return nama.contains(query) || nisn.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteData(int id, String nama) async {
    await supabase.from('siswa').delete().eq('id', id);
    _fetchData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data siswa '$nama' berhasil dihapus"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _confirmDelete(int id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          "Konfirmasi Hapus",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          "Yakin ingin menghapus data siswa '$nama'?",
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteData(id, nama);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailAndEdit(Map<String, dynamic> siswa) {
    final nisnController = TextEditingController(text: siswa['nisn']);
    final namaController = TextEditingController(text: siswa['nama']);
    final jenisKelaminController = TextEditingController(
      text: siswa['jenis_kelamin'],
    );
    final agamaController = TextEditingController(text: siswa['agama']);
    final ttlController = TextEditingController(text: siswa['ttl']);
    final noHpController = TextEditingController(text: siswa['no_hp']);
    final nikController = TextEditingController(text: siswa['nik']);
    final jalanController = TextEditingController(text: siswa['jalan']);
    final rtRwController = TextEditingController(text: siswa['rt_rw']);
    final dusunController = TextEditingController(text: siswa['dusun']);
    final desaController = TextEditingController(text: siswa['desa']);
    final kecamatanController = TextEditingController(text: siswa['kecamatan']);
    final kabupatenController = TextEditingController(text: siswa['kabupaten']);
    final provinsiController = TextEditingController(text: siswa['provinsi']);
    final kodePosController = TextEditingController(text: siswa['kode_pos']);
    final ayahController = TextEditingController(text: siswa['nama_ayah']);
    final ibuController = TextEditingController(text: siswa['nama_ibu']);
    final waliController = TextEditingController(text: siswa['nama_wali']);
    final alamatWaliController = TextEditingController(
      text: siswa['alamat_wali'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          "Detail & Edit Siswa",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: const Text(
                  "Data Siswa",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  _buildTextField(nisnController, "NISN"),
                  _buildTextField(namaController, "Nama Lengkap"),
                  _buildTextField(jenisKelaminController, "Jenis Kelamin"),
                  _buildTextField(agamaController, "Agama"),
                  _buildTextField(ttlController, "Tempat, Tanggal Lahir"),
                  _buildTextField(noHpController, "No. Tlp/HP"),
                  _buildTextField(nikController, "NIK"),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  "Alamat",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  _buildTextField(jalanController, "Jalan"),
                  _buildTextField(rtRwController, "RT/RW"),
                  _buildTextField(dusunController, "Dusun"),
                  _buildTextField(desaController, "Desa"),
                  _buildTextField(kecamatanController, "Kecamatan"),
                  _buildTextField(kabupatenController, "Kabupaten"),
                  _buildTextField(provinsiController, "Provinsi"),
                  _buildTextField(kodePosController, "Kode Pos"),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  "Orang Tua / Wali",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  _buildTextField(ayahController, "Nama Ayah"),
                  _buildTextField(ibuController, "Nama Ibu"),
                  _buildTextField(waliController, "Nama Wali"),
                  _buildTextField(alamatWaliController, "Alamat Wali"),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              await supabase
                  .from('siswa')
                  .update({
                    'nisn': nisnController.text,
                    'nama': namaController.text,
                    'jenis_kelamin': jenisKelaminController.text,
                    'agama': agamaController.text,
                    'ttl': ttlController.text,
                    'no_hp': noHpController.text,
                    'nik': nikController.text,
                    'jalan': jalanController.text,
                    'rt_rw': rtRwController.text,
                    'dusun': dusunController.text,
                    'desa': desaController.text,
                    'kecamatan': kecamatanController.text,
                    'kabupaten': kabupatenController.text,
                    'provinsi': provinsiController.text,
                    'kode_pos': kodePosController.text,
                    'nama_ayah': ayahController.text,
                    'nama_ibu': ibuController.text,
                    'nama_wali': waliController.text,
                    'alamat_wali': alamatWaliController.text,
                  })
                  .eq('id', siswa['id']);
              Navigator.pop(context);
              _fetchData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Data berhasil diperbarui"),
                  backgroundColor: Colors.yellow.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.yellowAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
          ),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  void _openFormPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPage()),
    ).then((_) => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blueAccent,
          secondary: Colors.yellowAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data Siswa'),
          backgroundColor: Colors.blueAccent,
          elevation: 2,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari siswa...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    )
                  : filteredList.isEmpty
                  ? const Center(child: Text('Belum ada data siswa'))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final siswa = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              siswa['nama'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("NISN: ${siswa['nisn'] ?? '-'}"),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _showDetailAndEdit(siswa);
                                if (value == 'delete')
                                  _confirmDelete(siswa['id'], siswa['nama']);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openFormPage,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String? value) {
    return ListTile(
      title: Text(
        "$title: ${value ?? '-'}",
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
