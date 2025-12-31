import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/pages/my_logs_tab.dart';
import 'package:tati_frontend/pages/verification_tab.dart';
import 'package:tati_frontend/widgets/form_log.dart';
// Pastikan import widget form pegawai yang baru
import 'package:tati_frontend/widgets/form_pegawai_page.dart';
// Import widgets tab yang sudah kita buat sebelumnya
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';
import '../utils/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final isAtasan = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).isAtasan;
      _tabController = TabController(length: isAtasan ? 2 : 1, vsync: this);
      _refreshData();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

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

    // Cek khusus apakah user adalah Kepala Dinas
    final bool isKadis = user?.role == 'Kepala Dinas';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user?.pegawai?.nama.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Kolom Nama & Jabatan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      user?.pegawai?.nama ?? 'Guest User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      user?.pegawai?.jabatan ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              // --- LOGIC NAVIGASI MENU ---
              onSelected: (value) {
                if (value == 'profile') {
                  // Aksi: EDIT PROFIL (Semua User)
                  // Kita kirim data user saat ini -> Form otomatis jadi Mode Edit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FormPegawaiWidget(pegawaiToEdit: user?.pegawai),
                    ),
                  );
                } else if (value == 'add_pegawai') {
                  // Aksi: TAMBAH PEGAWAI (Khusus Kadis)
                  // Kita kirim null -> Form otomatis jadi Mode Create (Lengkap)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const FormPegawaiWidget(pegawaiToEdit: null),
                    ),
                  );
                } else if (value == 'logout') {
                  auth.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },

              // --- ITEM MENU DROPDOWN ---
              // ...existing code...
              itemBuilder: (BuildContext context) {
                List<PopupMenuItem<String>> items = [];

                // 1. Menu Edit Profil (Untuk Semua)
                items.add(
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
                );

                // 2. Menu Tambah Pegawai (HANYA JIKA KADIS)
                if (isKadis) {
                  items.add(
                    const PopupMenuItem(
                      value: 'add_pegawai',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1_outlined,
                            color: AppTheme.secondaryBlue,
                          ),
                          SizedBox(width: 8),
                          Text("Tambah Pegawai"),
                        ],
                      ),
                    ),
                  );
                }

                // 3. Divider
                // items.add(const PopupMenuDivider());

                // 4. Menu Logout
                items.add(
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
                );

                return items;
              },
              // ...existing code...
            ),
          ),
        ],

        // --- TAB BAR ---
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isAtasan ? 50 : 0),
          child: isAtasan
              ? Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.secondaryBlue,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "Aktivitas Saya"),
                      Tab(text: "Verifikasi Tim"),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
      ),

      // --- BODY ---
      // Pastikan widget MyLogTab dan VerificationTab sudah dibuat di file terpisah
      body: TabBarView(
        controller: _tabController,
        children: [const MyLogTab(), if (isAtasan) const VerificationTab()],
      ),

      // --- FAB (Hanya untuk tambah LOG aktivitas) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke Form Log
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormLogWidget(),
            ), 
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          "Tambah Log",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
