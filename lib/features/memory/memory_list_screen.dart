import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/constants/app_colors.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/memory/memory_view_screen.dart';

class MemoryListScreen extends StatefulWidget {
  const MemoryListScreen({super.key});

  @override
  State<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends State<MemoryListScreen> {
  final StorageService _storageService = StorageService();
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    await _storageService.init();
    setState(() {
      _memories = _storageService.getAllMemories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recuerdos'),
      ),
      body: _memories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No hay recuerdos guardados',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Toma una foto de un objeto para comenzar',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final memory = _memories[index];
          return _buildMemoryCard(memory);
        },
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoryViewScreen(memory: memory),
            ),
          ).then((_) => _loadMemories()); // Recargar al volver
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen ancla
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.background,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FutureBuilder(
                    future: StorageService.getImageFromPath(memory.anchorImagePath),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(snapshot.data!, fit: BoxFit.cover);
                      }
                      return Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.image, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor(memory.memoryType).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeText(memory.memoryType),
                            style: TextStyle(
                              color: _getTypeColor(memory.memoryType),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(memory.createdAt),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
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
                        color: AppColors.text,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
            ],
          ),
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
}