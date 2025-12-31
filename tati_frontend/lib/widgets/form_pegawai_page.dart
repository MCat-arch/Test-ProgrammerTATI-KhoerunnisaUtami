import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pegawai_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pegawai_provider.dart';
import '../providers/role_provider.dart';
import '../utils/app_theme.dart';

class FormPegawaiWidget extends StatefulWidget {
  final PegawaiModel? pegawaiToEdit;

  const FormPegawaiWidget({super.key, this.pegawaiToEdit});

  @override
  State<FormPegawaiWidget> createState() => _FormPegawaiWidgetState();
}

class _FormPegawaiWidgetState extends State<FormPegawaiWidget> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _jabatanController = TextEditingController();
  
  int? _selectedRoleId;
  int? _selectedAtasanId;
  
  bool _isLoading = false;
  bool get _isEditing => widget.pegawaiToEdit != null;
  bool _isKadis = false; // Variable untuk cek akses

  @override
  void initState() {
    super.initState();
    
    // 1. Cek Role User yang sedang Login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isKadis = authProvider.user?.role == 'Kepala Dinas';

    // 2. Load Data HANYA JIKA KADIS
    // Jika Kabid/Staff, request ini akan 403, jadi jangan dijalankan agar tidak error/crash
    if (_isKadis) {
      Future.microtask(() {
        Provider.of<RoleProvider>(context, listen: false).fetchRoles();
        Provider.of<PegawaiProvider>(context, listen: false).fetchPegawais();
      });
    }

    // 3. Isi Form Data
    if (_isEditing) {
      _namaController.text = widget.pegawaiToEdit!.nama;
      _jabatanController.text = widget.pegawaiToEdit!.jabatan;
      _selectedAtasanId = widget.pegawaiToEdit!.atasanId;
      // Asumsi email ada di model atau biarkan kosong jika tidak diedit
      // _emailController.text = widget.pegawaiToEdit!.email ?? ""; 
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Mode Edit: Update User & Pegawai
        await Provider.of<UserProvider>(context, listen: false).editUser(
          id: widget.pegawaiToEdit!.id,
          email: _emailController.text,
          password: _passwordController.text.isEmpty ? null : _passwordController.text,
          nama: _namaController.text,
          // Kirim jabatan/atasan/role HANYA jika Kadis. Jika tidak, kirim null/nilai lama
          jabatan: _isKadis ? _jabatanController.text : widget.pegawaiToEdit!.jabatan,
          atasanId: _isKadis ? _selectedAtasanId : widget.pegawaiToEdit!.atasanId,
          roleId: _isKadis ? _selectedRoleId : null, // Backend harus handle jika null tidak update
        );
      } else {
        // Mode Create: Hanya bisa dilakukan Kadis (tombol menu tambah pegawai hanya muncul di Kadis)
        await Provider.of<UserProvider>(context, listen: false).addUser(
          email: _emailController.text,
          password: _passwordController.text,
          roleId: _selectedRoleId!,
          nama: _namaController.text,
          jabatan: _jabatanController.text,
          atasanId: _selectedAtasanId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Berhasil Disimpan")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.secondaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);
    final pegawaiProvider = Provider.of<PegawaiProvider>(context);

    // Filter list untuk Dropdown Atasan (Jangan tampilkan diri sendiri)
    final listBawahan = pegawaiProvider.pegawais
        .where((p) => _isEditing ? p.id != widget.pegawaiToEdit!.id : true)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Data" : "Registrasi Pegawai"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CARD 1: INFORMASI AKUN ---
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSectionTitle("Informasi Akun", Icons.lock_outline),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                        validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: _isEditing ? "Password Baru (Opsional)" : "Password", 
                          prefixIcon: const Icon(Icons.key_outlined),
                          helperText: _isEditing ? "Kosongkan jika tidak ingin mengganti" : null,
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (!_isEditing && (v == null || v.length < 6)) return "Min 6 karakter";
                          if (_isEditing && v!.isNotEmpty && v.length < 6) return "Min 6 karakter";
                          return null;
                        },
                      ),
                      
                      // DROPDOWN ROLE (Hanya tampil jika KADIS)
                      if (_isKadis) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedRoleId,
                          // Validasi agar value tidak error jika list kosong/belum loading
                          items: roleProvider.roles.isEmpty 
                            ? [] 
                            : roleProvider.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.namaRole))).toList(),
                          onChanged: (val) => setState(() => _selectedRoleId = val),
                          decoration: const InputDecoration(labelText: "Role System", prefixIcon: Icon(Icons.security_outlined)),
                          validator: (v) => (!_isEditing && v == null) ? "Pilih Role" : null,
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              // --- CARD 2: DATA PROFIL ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildSectionTitle("Profil Kepegawaian", Icons.badge_outlined),
                      const SizedBox(height: 10),
                      
                      // NAMA (Bisa diedit semua)
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),

                      // JABATAN (Hanya Kadis bisa edit)
                      TextFormField(
                        controller: _jabatanController,
                        readOnly: !_isKadis, // Kunci jika bukan Kadis
                        decoration: InputDecoration(
                          labelText: "Jabatan", 
                          prefixIcon: const Icon(Icons.work_outline),
                          filled: !_isKadis,
                          fillColor: !_isKadis ? Colors.grey[200] : null,
                        ),
                        validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),

                      // DROPDOWN ATASAN (Hanya Tampil Jika KADIS)
                      // Jika bukan Kadis, kita sembunyikan atau tampilkan Text "Terkunci"
                      // Karena kita tidak bisa fetch list atasan (Forbidden 403)
                      if (_isKadis) 
                        DropdownButtonFormField<int>(
                          value: _selectedAtasanId,
                          isExpanded: true,
                          // Pastikan value ada di listBawahan atau null, untuk mencegah error 'items == null' atau 'value not in items'
                          items: [
                             const DropdownMenuItem(value: null, child: Text("Paling Atas / Tidak Ada Atasan")),
                             ...listBawahan.map((p) => DropdownMenuItem(value: p.id, child: Text("${p.nama} (${p.jabatan})")))
                          ],
                          onChanged: (val) => setState(() => _selectedAtasanId = val),
                          decoration: const InputDecoration(labelText: "Atasan Langsung", prefixIcon: Icon(Icons.supervisor_account_outlined)),
                        )
                      else
                        // Tampilan Read-Only untuk Non-Kadis (Karena data atasan tidak bisa diambil via API)
                        TextFormField(
                          initialValue: "Atasan Terkunci (Hubungi Admin)",
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Atasan Langsung",
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SIMPAN DATA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}