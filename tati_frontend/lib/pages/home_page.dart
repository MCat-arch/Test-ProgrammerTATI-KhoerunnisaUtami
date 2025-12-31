import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/pages/my_logs_tab.dart';
import 'package:tati_frontend/widgets/form_log.dart';
import 'package:tati_frontend/widgets/verification.dart';
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';
import '../utils/app_theme.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final isAtasan = Provider.of<AuthProvider>(context, listen: false).isAtasan;
      // Logic Tab: Jika atasan 2 tab, staff 1 tab
      _tabController = TabController(length: isAtasan ? 2 : 1, vsync: this);
      
      _refreshData(); // Panggil fungsi refresh terpisah agar rapi
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // Fungsi untuk refresh data log
  Future<void> _refreshData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    
    await logProvider.fetchMyLogs();
    if (auth.isAtasan) {
      await logProvider.fetchTeamLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final isAtasan = auth.isAtasan;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey, // Background abu muda agar card kontras
      
      // --- HEADER ENTERPRISE STYLE ---
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "E-Kinerja Dashboard", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 2),
              Text(
                "${user?.pegawai?.nama ?? 'Pegawai'} | ${user?.pegawai?.jabatan ?? '-'}",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          // POPUP MENU (Profile & Logout)
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == 'profile') {
                // Navigasi ke Form Pegawai (Mode Edit)
                // Kita asumsikan route '/profile' mengarah ke FormPegawaiScreen dengan parameter user
                // Atau push manual seperti ini:
                Navigator.of(context).pushNamed('/add-pegawai', arguments: user?.pegawai);
              } else if (value == 'logout') {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text("Edit Profil Saya"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.errorRed),
                    SizedBox(width: 8),
                    Text("Keluar"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        // --- TAB BAR ---
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isAtasan ? 48 : 0),
          child: isAtasan
              ? Container(
                  color: Colors.white, // Background putih untuk tab agar bersih
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: AppTheme.textGrey,
                    indicatorColor: AppTheme.secondaryBlue,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: "Aktivitas Saya", icon: Icon(Icons.assignment_ind_outlined, size: 20)),
                      Tab(text: "Verifikasi Tim", icon: Icon(Icons.how_to_reg_outlined, size: 20)),
                    ],
                  ),
                )
              : const SizedBox(), // Staff tidak butuh tab bar visual jika cuma 1 tab
        ),
      ),

      // --- BODY ---
      body: TabBarView(
        controller: _tabController,
        children: [
          const MyLogTab(), 
          
          if (isAtasan) const VerificationTab(),
        ],
      ),

      // --- FAB (Tombol Tambah) ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text("Tambah Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          // Navigasi ke Form Create
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormLogWidget()),
          );
        },
      ),
    );
  }
}
