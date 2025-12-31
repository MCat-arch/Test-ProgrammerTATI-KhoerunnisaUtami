import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/widgets/my_log.dart';
import 'package:tati_frontend/widgets/verification.dart';
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';

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
      // Jika atasan tab length 2, jika staff 1
      _tabController = TabController(length: isAtasan ? 2 : 1, vsync: this);
      
      // Load data awal
      Provider.of<LogProvider>(context, listen: false).fetchMyLogs();
      if (isAtasan) {
        Provider.of<LogProvider>(context, listen: false).fetchTeamLogs();
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAtasan = auth.isAtasan;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("E-Kinerja", style: TextStyle(fontSize: 18)),
            Text(
              "Halo, ${auth.user?.pegawai?.nama ?? 'Pegawai'}", 
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: "Log Saya", icon: Icon(Icons.note_alt)),
            if (isAtasan) const Tab(text: "Verifikasi Tim", icon: Icon(Icons.supervised_user_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const MyLogTab(), // Widget Tab 1
          if (isAtasan) const VerificationTab(), // Widget Tab 2
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-log');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
