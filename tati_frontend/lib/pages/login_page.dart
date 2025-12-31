import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart'; // Pastikan import theme

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // State untuk fitur lihat/sembunyikan password
  bool _isPasswordVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Menutup keyboard saat submit
    FocusScope.of(context).unfocus();

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: Stack(
        children: [
          // --- LAYER 1: BACKGROUND HEADER (Royal Blue) ---
          Container(
            height: size.height * 0.45, // Setengah layar ke atas warna biru
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // --- LAYER 2: CONTENT ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. LOGO & BRANDING
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "SISTEM E-KINERJA",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Pemerintah Daerah",
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. FORM CARD
                  Card(
                    elevation: 8, // Shadow lebih tebal agar terlihat melayang
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Masuk Akun",
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: AppTheme.primaryBlue
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Silakan login untuk melanjutkan aktivitas.",
                              style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                            ),
                            const SizedBox(height: 30),

                            // Input Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Pegawai',
                                hintText: 'contoh@pemda.go.id',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                            ),
                            
                            const SizedBox(height: 30),

                            // Tombol Masuk
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 2,
                                ),
                                onPressed: isLoading ? null : _submit,
                                child: isLoading 
                                  ? const SizedBox(
                                      height: 24, 
                                      width: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    ) 
                                  : const Text(
                                      "MASUK SEKARANG",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. FOOTER
                  const SizedBox(height: 30),
                  const Text(
                    "© 2024 Dinas Komunikasi dan Informatika",
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}