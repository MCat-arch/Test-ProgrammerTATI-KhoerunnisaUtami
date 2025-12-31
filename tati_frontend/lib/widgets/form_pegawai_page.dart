import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pegawai_model.dart';
import '../providers/user_provider.dart';
import '../providers/pegawai_provider.dart';
import '../providers/role_provider.dart';
import '../utils/app_theme.dart'; // Import theme

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
      Provider.of<PegawaiProvider>(context, listen: false).fetchPegawais();
    });

    if (_isEditing) {
      _namaController.text = widget.pegawaiToEdit!.nama;
      _jabatanController.text = widget.pegawaiToEdit!.jabatan;
      _selectedAtasanId = widget.pegawaiToEdit!.atasanId;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await Provider.of<PegawaiProvider>(context, listen: false).editPegawai(
          widget.pegawaiToEdit!.id,
          _namaController.text,
          _jabatanController.text,
          _selectedAtasanId,
        );
      } else {
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

  // Helper untuk membuat Section Title
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Data Pegawai" : "Registrasi Pegawai"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CARD 1: INFORMASI AKUN (Hanya saat Create) ---
              if (!_isEditing) 
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildSectionTitle("Informasi Akun Login", Icons.lock_outline),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                          validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.key_outlined)),
                          obscureText: true,
                          validator: (v) => v!.length < 6 ? "Min 6 karakter" : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedRoleId,
                          items: roleProvider.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.namaRole))).toList(),
                          onChanged: (val) => setState(() => _selectedRoleId = val),
                          decoration: const InputDecoration(labelText: "Role System", prefixIcon: Icon(Icons.security_outlined)),
                          validator: (v) => v == null ? "Pilih Role" : null,
                        ),
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
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jabatanController,
                        decoration: const InputDecoration(labelText: "Jabatan", prefixIcon: Icon(Icons.work_outline)),
                        validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedAtasanId,
                        isExpanded: true, // Agar teks panjang tidak overflow
                        items: [
                           const DropdownMenuItem(value: null, child: Text("Paling Atas / Tidak Ada Atasan")),
                           ...pegawaiProvider.pegawais
                              .where((p) => _isEditing ? p.id != widget.pegawaiToEdit!.id : true) 
                              .map((p) => DropdownMenuItem(value: p.id, child: Text("${p.nama} (${p.jabatan})")))
                        ],
                        onChanged: (val) => setState(() => _selectedAtasanId = val),
                        decoration: const InputDecoration(labelText: "Atasan Langsung", prefixIcon: Icon(Icons.supervisor_account_outlined)),
                      ),
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
                    : const Text("SIMPAN DATA PEGAWAI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}