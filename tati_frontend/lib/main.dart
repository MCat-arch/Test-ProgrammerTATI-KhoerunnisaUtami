import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/models/logs_model.dart';
import 'package:tati_frontend/pages/home_page.dart';
import 'package:tati_frontend/pages/login_page.dart';
import 'package:tati_frontend/widgets/form_log.dart';
import 'package:tati_frontend/widgets/form_pegawai_page.dart';
import 'package:tati_frontend/widgets/form_role.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/pegawai_provider.dart';
import 'providers/log_provider.dart';
import 'providers/role_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PegawaiProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
      ],
      child: MaterialApp(
        title: 'E-Kinerja Pemda',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false, // Biar tampilan agak klasik & tegas
        ),
        home: const LoginPage(),
        routes: {
          '/home': (ctx) => const HomePage(),
          '/add-log': (ctx) => const FormLogWidget(),
          '/add-pegawai':(ctx) => const FormPegawaiWidget(),
          '/add-role': (ctx) => const FormRoleWidget(),
          // '/edit-log':(ctx) => FormLogWidget(logToEdit: LogsModel data),
        },
      ),
    );
  }
}