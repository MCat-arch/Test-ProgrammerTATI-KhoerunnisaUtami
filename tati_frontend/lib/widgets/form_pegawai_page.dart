import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pegawai_model.dart';
import '../providers/user_provider.dart';
import '../providers/pegawai_provider.dart';
import '../providers/role_provider.dart';

class FormPegawaiWidget extends StatefulWidget {
  // Jika null = Create User Baru (Lengkap)
  // Jika ada = Edit Profil Pegawai (Nama, Jabatan, Atasan saja)
  final PegawaiModel? pegawaiToEdit;

  const FormPegawaiWidget({super.key, this.pegawaiToEdit});

  @override
  State<FormPegawaiWidget> createState() => _FormPegawaiWidgetState();
}

class _FormPegawaiWidgetState extends State<FormPegawaiWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller Fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _jabatanController = TextEditingController();
  
  // Dropdown Values
  int? _selectedRoleId;
  int? _selectedAtasanId;
  
  bool _isLoading = false;
  bool get _isEditing => widget.pegawaiToEdit != null;

  @override
  void initState() {
    super.initState();
    
    // Load data Roles & Pegawai (untuk dropdown atasan)
    Future.microtask(() {
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
      // Kita perlu daftar pegawai untuk dijadikan atasan
      Provider.of<PegawaiProvider>(context, listen: false).fetchPegawais();
    });

    if (_isEditing) {
      _namaController.text = widget.pegawaiToEdit!.nama;
      _jabatanController.text = widget.pegawaiToEdit!.jabatan;
      _selectedAtasanId = widget.pegawaiToEdit!.atasanId;
      // Note: Role ID & Email tidak bisa diambil langsung dari PegawaiModel 
      // kecuali Anda passing object User lengkap. 
      // Tapi sesuai request, edit tidak mengubah email/role, jadi aman.
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // --- MODE EDIT (PegawaiProvider) ---
        // Email & Pass diabaikan
        await Provider.of<PegawaiProvider>(context, listen: false).editPegawai(
          widget.pegawaiToEdit!.id,
          _namaController.text,
          _jabatanController.text,
          _selectedAtasanId,
        );
      } else {
        // --- MODE CREATE (UserProvider) ---
        // Wajib Email, Pass, Role
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

  @override
  Widget build(BuildContext context) {
    // Ambil Data untuk Dropdown
    final roleProvider = Provider.of<RoleProvider>(context);
    final pegawaiProvider = Provider.of<PegawaiProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Profil Pegawai" : "Registrasi Pegawai Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEKSI AKUN (Hanya muncul saat Create) ---
              if (!_isEditing) ...[
                const Text("Informasi Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? "Min 6 karakter" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  items: roleProvider.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.namaRole))).toList(),
                  onChanged: (val) => setState(() => _selectedRoleId = val),
                  decoration: const InputDecoration(labelText: "Role User", border: OutlineInputBorder()),
                  validator: (v) => v == null ? "Pilih Role" : null,
                ),
                const Divider(height: 40, thickness: 2),
              ],

              // --- SEKSI PROFIL (Muncul di Create & Edit) ---
              const Text("Data Pegawai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _jabatanController,
                decoration: const InputDecoration(labelText: "Jabatan", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
              ),
              const SizedBox(height: 10),
              
              // Dropdown Atasan
              DropdownButtonFormField<int>(
                value: _selectedAtasanId,
                items: [
                   // Opsi Tidak Punya Atasan (Misal untuk Kadis)
                   const DropdownMenuItem(value: null, child: Text("Tidak Ada Atasan / Paling Atas")),
                   ...pegawaiProvider.pegawais
                      // Jangan menampilkan diri sendiri sebagai atasan saat Edit
                      .where((p) => _isEditing ? p.id != widget.pegawaiToEdit!.id : true) 
                      .map((p) => DropdownMenuItem(value: p.id, child: Text("${p.nama} (${p.jabatan})")))
                ],
                onChanged: (val) => setState(() => _selectedAtasanId = val),
                decoration: const InputDecoration(labelText: "Atasan Langsung", border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SIMPAN DATA"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}