import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tati_frontend/models/logs_model.dart';
import '../providers/log_provider.dart';

class FormLogWidget extends StatefulWidget {
  // Jika null = Mode Create, Jika ada isi = Mode Edit
  final LogsModel? logToEdit; 

  const FormLogWidget({super.key, this.logToEdit});

  @override
  State<FormLogWidget> createState() => _FormLogWidgetState();
}

class _FormLogWidgetState extends State<FormLogWidget> {
  final _aktivitasController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.logToEdit != null;

  @override
  void initState() {
    super.initState();
    // Jika Mode Edit, isi form dengan data lama
    if (_isEditing) {
      _aktivitasController.text = widget.logToEdit!.aktivitas;
      _selectedDate = widget.logToEdit!.tanggal;
    }
  }

  void _save() async {
    if (_aktivitasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aktivitas wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<LogProvider>(context, listen: false);

      if (_isEditing) {
        // --- MODE UPDATE ---
        await provider.editLog(
          widget.logToEdit!.id,
          _aktivitasController.text,
          _selectedDate,
        );
      } else {
        // --- MODE CREATE ---
        await provider.addLog(
          _aktivitasController.text,
          _selectedDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? "Log diperbarui" : "Log berhasil dibuat")),
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Log" : "Tambah Log Baru"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Tanggal"),
              subtitle: Text(DateFormat('EEEE, d MMMM y').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aktivitasController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Aktivitas",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(_isEditing ? "UPDATE LOG" : "SIMPAN LOG"),
              ),
            )
          ],
        ),
      ),
    );
  }
}