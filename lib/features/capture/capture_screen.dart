import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorias_ancladas/core/constants/app_colors.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/memory/memory_view_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  MemoryType _selectedType = MemoryType.text;
  String? _anchorImagePath; // Foto del objeto
  String? _mediaPath; // Para imagen/video adicional
  bool _isSaving = false;
  bool _isTakingAnchorPhoto = true; // Para saber si está tomando la foto ancla

  @override
  void initState() {
    super.initState();
    _storageService.init();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _takeAnchorPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo != null) {
      final savedPath = await StorageService.saveImageLocally(
        File(photo.path),
        'anchor',
      );
      setState(() {
        _anchorImagePath = savedPath;
        _isTakingAnchorPhoto = false;
      });
    }
  }

  Future<void> _captureMedia() async {
    if (_selectedType == MemoryType.image) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final savedPath = await StorageService.saveImageLocally(
          File(photo.path),
          'memory_image',
        );
        setState(() {
          _mediaPath = savedPath;
        });
      }
    } else if (_selectedType == MemoryType.video) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        final savedPath = await StorageService.saveImageLocally(
          File(video.path),
          'memory_video',
        );
        setState(() {
          _mediaPath = savedPath;
        });
      }
    }
  }

  Future<void> _saveMemory() async {
    // Validaciones
    if (_anchorImagePath == null) {
      _showError('Primero toma una foto del objeto');
      return;
    }

    if (_selectedType == MemoryType.text && _textController.text.trim().isEmpty) {
      _showError('Escribe un recuerdo');
      return;
    }

    if ((_selectedType == MemoryType.image || _selectedType == MemoryType.video) &&
        (_mediaPath == null || _mediaPath!.isEmpty)) {
      _showError('Captura una imagen o video');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final memory = Memory.fromEnum(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        anchorImagePath: _anchorImagePath!,
        memoryType: _selectedType,
        content: _selectedType == MemoryType.text
            ? _textController.text.trim()
            : _mediaPath!,
        createdAt: DateTime.now(),
      );

      await _storageService.saveMemory(memory);

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Recuerdo guardado! ✨')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryViewScreen(memory: memory),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Error al guardar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar Recuerdo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto del objeto (ANCLA)
            Text(
              '1. Foto del objeto',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _takeAnchorPhoto,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: _anchorImagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FutureBuilder<File?>(
                    future: StorageService.getImageFromPath(_anchorImagePath!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(snapshot.data!, fit: BoxFit.cover);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Tomar foto del objeto',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tipo de recuerdo
            if (_anchorImagePath != null) ...[
              Text(
                '2. Tipo de recuerdo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeButton(MemoryType.text, Icons.text_fields, 'Texto'),
                  const SizedBox(width: 12),
                  _buildTypeButton(MemoryType.image, Icons.photo_camera, 'Imagen'),
                  const SizedBox(width: 12),
                  _buildTypeButton(MemoryType.video, Icons.videocam, 'Video'),
                ],
              ),
              const SizedBox(height: 32),

              // Contenido
              if (_selectedType == MemoryType.text)
                TextField(
                  controller: _textController,
                  maxLines: 8,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu recuerdo...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

              if (_selectedType == MemoryType.image || _selectedType == MemoryType.video)
                GestureDetector(
                  onTap: _captureMedia,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: _mediaPath != null && _selectedType == MemoryType.image
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FutureBuilder<File?>(
                        future: StorageService.getImageFromPath(_mediaPath!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(snapshot.data!, fit: BoxFit.cover);
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                        : _mediaPath != null && _selectedType == MemoryType.video
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_filled, size: 60, color: AppColors.secondary),
                          SizedBox(height: 12),
                          Text('Video grabado', style: TextStyle(color: AppColors.text)),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedType == MemoryType.image ? Icons.camera_alt : Icons.videocam,
                          size: 50,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedType == MemoryType.image ? 'Tomar foto' : 'Grabar video',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.text,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Guardar Recuerdo ✨',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(MemoryType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.background : AppColors.text),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.background : AppColors.text,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}