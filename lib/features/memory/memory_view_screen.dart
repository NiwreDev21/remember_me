import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/constants/app_colors.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/home/home_screen.dart';

class MemoryViewScreen extends StatefulWidget {
  final Memory memory;

  const MemoryViewScreen({
    super.key,
    required this.memory,
  });

  @override
  State<MemoryViewScreen> createState() => _MemoryViewScreenState();
}

class _MemoryViewScreenState extends State<MemoryViewScreen> {
  final StorageService _storageService = StorageService();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _storageService.init();
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar recuerdo'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este recuerdo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteMemory(widget.memory.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recuerdo eliminado')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Recuerdo'),
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imágenes ancla (ahora múltiples)
            Column(
              children: [
                // Imagen actual
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FutureBuilder<File?>(
                      future: StorageService.getImageFromPath(
                          widget.memory.anchorImagePaths[_currentImageIndex]
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.file(snapshot.data!, fit: BoxFit.cover);
                        }
                        return Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    size: 50, color: AppColors.textSecondary),
                                SizedBox(height: 8),
                                Text('Imagen del objeto',
                                    style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Indicador de múltiples imágenes
                if (widget.memory.anchorImagePaths.length > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentImageIndex > 0
                            ? () => setState(() => _currentImageIndex--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        color: AppColors.primary,
                      ),
                      Text(
                        '${_currentImageIndex + 1}/${widget.memory.anchorImagePaths.length}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      IconButton(
                        onPressed: _currentImageIndex < widget.memory.anchorImagePaths.length - 1
                            ? () => setState(() => _currentImageIndex++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  // Miniaturas
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.memory.anchorImagePaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => setState(() => _currentImageIndex = index),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _currentImageIndex == index
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FutureBuilder<File?>(
                                future: StorageService.getImageFromPath(
                                    widget.memory.anchorImagePaths[index]
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    return Image.file(snapshot.data!, fit: BoxFit.cover);
                                  }
                                  return Container(color: AppColors.surface);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  'Objeto anclado (${widget.memory.anchorImagePaths.length} fotos)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Contenido del recuerdo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.memory.memoryType == MemoryType.text
                            ? Icons.description
                            : (widget.memory.memoryType == MemoryType.image
                            ? Icons.image
                            : Icons.video_library),
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.memory.memoryType == MemoryType.text
                            ? 'Recuerdo escrito'
                            : (widget.memory.memoryType == MemoryType.image
                            ? 'Fotografía'
                            : 'Video'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.textSecondary, height: 24),
                  const SizedBox(height: 12),

                  // Contenido específico
                  if (widget.memory.memoryType == MemoryType.text)
                    Text(
                      widget.memory.content,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                  if (widget.memory.memoryType == MemoryType.image)
                    FutureBuilder<File?>(
                      future: StorageService.getImageFromPath(widget.memory.content),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return const Center(
                          child: Text('Imagen no disponible',
                              style: TextStyle(color: AppColors.error)),
                        );
                      },
                    ),

                  if (widget.memory.memoryType == MemoryType.video)
                    const Center(
                      child: Column(
                        children: [
                          Icon(Icons.ondemand_video, size: 80, color: AppColors.primary),
                          SizedBox(height: 12),
                          Text(
                            'Video guardado localmente',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  Text(
                    'Guardado el ${_formatDate(widget.memory.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón para volver al inicio
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}