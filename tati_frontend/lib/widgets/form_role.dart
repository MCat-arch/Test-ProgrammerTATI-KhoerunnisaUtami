import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/role_model.dart';
import '../providers/role_provider.dart';
import '../utils/app_theme.dart';

class FormRoleWidget extends StatefulWidget {
  final Role? roleToEdit;

  const FormRoleWidget({super.key, this.roleToEdit});

  @override
  State<FormRoleWidget> createState() => _FormRoleWidgetState();
}

class _FormRoleWidgetState extends State<FormRoleWidget> {
  final _namaController = TextEditingController();
  bool _isLoading = false;
  
  bool get _isEditing => widget.roleToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _namaController.text = widget.roleToEdit!.namaRole;
    }
  }

  void _save() async {
    if (_namaController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<RoleProvider>(context, listen: false);
      
      if (_isEditing) {
        await provider.editRole(widget.roleToEdit!.id, _namaController.text);
      } else {
        await provider.addRole(_namaController.text);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Role Berhasil Disimpan")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Role" : "Tambah Role Baru"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar card tidak full height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Informasi Role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const SizedBox(height: 20),
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Role", 
                    prefixIcon: Icon(Icons.verified_user_outlined),
                    hintText: "Contoh: Staff, Kepala Bidang",
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIMPAN ROLE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}