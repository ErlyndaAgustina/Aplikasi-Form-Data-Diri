import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'page/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mkpdjfgupligpougnwzu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1rcGRqZmd1cGxpZ3BvdWdud3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MDg5NzQsImV4cCI6MjA3MzQ4NDk3NH0.q71VdyQs_x-MtrOnwv5Csntu_V9sHMPP0XAU8wXXF6A', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Data Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo, 
      ),
      home: const SplashScreen(),
    );
  }
}
