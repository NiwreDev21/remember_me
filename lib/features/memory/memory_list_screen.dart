import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/capture/capture_screen.dart';
import 'package:memorias_ancladas/features/memory/memory_view_screen.dart';

class MemoryListScreen extends StatefulWidget {
  const MemoryListScreen({super.key});

  @override
  State<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  final StorageService _storageService = StorageService();
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    await _storageService.init();
    setState(() {
      _memories = _storageService.getAllMemories();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recuerdos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Aquí puedes agregar búsqueda si quieres
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
          ? _buildEmptyState()
          : _buildMemoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory,
              size: 50,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay recuerdos guardados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza a crear tus primeros recuerdos',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CaptureScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear recuerdo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final memory = _memories[index];
        return _buildMemoryListItem(memory);
      },
    );
  }

  Widget _buildMemoryListItem(Memory memory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryViewScreen(memory: memory),
          ),
        ).then((_) => _loadMemories());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.surfaceLight,
                child: FutureBuilder(
                  future: memory.anchorImagePaths.isNotEmpty
                      ? StorageService.getImageFromPath(memory.anchorImagePaths[0])
                      : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      );
                    }
                    return const Icon(
                      Icons.image,
                      size: 40,
                      color: AppColors.textTertiary,
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(memory.memoryType).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(memory.memoryType),
                                size: 12,
                                color: _getTypeColor(memory.memoryType),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getTypeText(memory.memoryType),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getTypeColor(memory.memoryType),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(memory.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      memory.previewText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${memory.anchorImagePaths.length} foto(s)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(memory.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeText(MemoryType type) {
    switch (type) {
      case MemoryType.text:
        return 'Texto';
      case MemoryType.image:
        return 'Imagen';
      case MemoryType.video:
        return 'Video';
    }
  }

  IconData _getTypeIcon(MemoryType type) {
    switch (type) {
      case MemoryType.text:
        return Icons.description;
      case MemoryType.image:
        return Icons.image;
      case MemoryType.video:
        return Icons.video_library;
    }
  }

  Color _getTypeColor(MemoryType type) {
    switch (type) {
      case MemoryType.text:
        return AppColors.primary;
      case MemoryType.image:
        return AppColors.secondary;
      case MemoryType.video:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    if (difference.inDays < 30) return 'Hace ${(difference.inDays / 7).floor()} semanas';
    if (difference.inDays < 365) return 'Hace ${(difference.inDays / 30).floor()} meses';
    return 'Hace ${(difference.inDays / 365).floor()} años';
  }
}