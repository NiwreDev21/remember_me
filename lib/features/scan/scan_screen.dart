import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorias_ancladas/core/constants/app_colors.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/memory/memory_view_screen.dart';

import '../capture/capture_screen.dart' show CaptureScreen;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _storageService.init();
  }

  Future<void> _scanObject() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Tomando foto...';
    });

    try {
      // Tomar foto del objeto
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        setState(() {
          _isScanning = false;
          _statusMessage = null;
        });
        return;
      }

      setState(() {
        _statusMessage = 'Analizando objeto...';
      });

      // Buscar recuerdo similar
      final similarMemory = await _storageService.findSimilarMemory(File(photo.path));

      setState(() {
        _isScanning = false;
        _statusMessage = null;
      });

      if (similarMemory != null) {
        // Mostrar el recuerdo encontrado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎯 ¡Objeto reconocido! Mostrando tu recuerdo...'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoryViewScreen(memory: similarMemory),
            ),
          );
        }
      } else {
        // No se encontró coincidencia
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Objeto no reconocido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No encontré un recuerdo asociado a este objeto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¿Quieres guardar un nuevo recuerdo para este objeto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaptureScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Guardar recuerdo'),
                ),
              ],
            ),
          );
        }
      }

    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Objeto'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 32),
                Text(
                  'Escanea un objeto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toma una foto del objeto y buscaré\nel recuerdo asociado automáticamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                if (_isScanning) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage ?? 'Procesando...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _scanObject,
                    icon: const Icon(Icons.camera_alt, size: 28),
                    label: const Text(
                      'Escanear Ahora',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, size: 20, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Consejo',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para mejores resultados, toma la foto desde un ángulo similar a cuando guardaste el recuerdo.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}