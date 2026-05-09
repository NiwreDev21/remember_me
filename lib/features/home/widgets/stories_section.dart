import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/capture/capture_screen.dart';
import 'package:memorias_ancladas/features/memory/memory_view_screen.dart';

class StoriesSection extends StatefulWidget {
  const StoriesSection({super.key});

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  final StorageService _storageService = StorageService();
  List<dynamic> _recentMemories = [];

  @override
  void initState() {
    super.initState();
    _loadRecentMemories();
  }

  Future<void> _loadRecentMemories() async {
    await _storageService.init();
    setState(() {
      _recentMemories = _storageService.getAllMemories().take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentMemories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStoryAdd(context);
          }
          final memory = _recentMemories[index - 1];
          return _buildStoryItem(context, memory);
        },
      ),
    );
  }

  Widget _buildStoryAdd(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CaptureScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(

        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, dynamic memory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryViewScreen(memory: memory),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: FutureBuilder(
                    future: StorageService.getImageFromPath(
                      memory.anchorImagePaths.isNotEmpty
                          ? memory.anchorImagePaths[0]
                          : '',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(snapshot.data!, fit: BoxFit.cover);
                      }
                      return Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.memory, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(memory.createdAt),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    return '${date.day}/${date.month}';
  }
}