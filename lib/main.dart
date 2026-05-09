import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';
import 'package:memorias_ancladas/data/adapters/memory_adapter.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MemoryAdapter());
  await Hive.openBox<Memory>('memories');

  runApp(const MemoriasAncladasApp());
}

class MemoriasAncladasApp extends StatelessWidget {
  const MemoriasAncladasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorias Ancladas',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}