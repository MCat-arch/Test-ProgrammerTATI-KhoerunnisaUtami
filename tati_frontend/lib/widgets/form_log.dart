import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/logs_model.dart';
import '../providers/log_provider.dart';
import '../utils/app_theme.dart'; // Pastikan import theme

class FormLogWidget extends StatefulWidget {
  final LogsModel? logToEdit; 

  const FormLogWidget({super.key, this.logToEdit});

  @override
  State<FormLogWidget> createState() => _FormLogWidgetState();
}

class _FormLogWidgetState extends State<FormLogWidget> {
  final _aktivitasController = TextEditingController();
  final _dateController = TextEditingController(); // Controller tambahan untuk tampilan tanggal
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.logToEdit != null;

  @override
  void initState() {
    super.initState();
    // Set tanggal awal ke controller
    _dateController.text = DateFormat('EEEE, d MMMM y').format(_selectedDate);

    if (_isEditing) {
      _aktivitasController.text = widget.logToEdit!.aktivitas;
      _selectedDate = widget.logToEdit!.tanggal;
      _dateController.text = DateFormat('EEEE, d MMMM y').format(_selectedDate);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Kustomisasi warna DatePicker agar sesuai tema
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEEE, d MMMM y').format(picked);
      });
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
        await provider.editLog(widget.logToEdit!.id, _aktivitasController.text, _selectedDate);
      } else {
        await provider.addLog(_aktivitasController.text, _selectedDate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Log Harian" : "Tambah Log Harian"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Detail Aktivitas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const SizedBox(height: 20),
                
                // Input Tanggal (Read Only tapi bisa diklik)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: "Tanggal",
                    prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Input Aktivitas
                TextFormField(
                  controller: _aktivitasController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Deskripsi Aktivitas",
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80), // Icon agak ke atas
                      child: Icon(Icons.edit_note, color: AppTheme.primaryBlue),
                    ),
                    border: OutlineInputBorder(),
                    hintText: "Jelaskan pekerjaan yang Anda lakukan...",
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(
                          _isEditing ? "PERBARUI DATA" : "SIMPAN LOG",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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
