import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/role_model.dart';
import '../providers/role_provider.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Role Berhasil Disimpan")));
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
      appBar: AppBar(title: Text(_isEditing ? "Edit Role" : "Tambah Role")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: "Nama Role", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: Text("SIMPAN"),
            )
          ],
        ),
      ),
    );
  }
}