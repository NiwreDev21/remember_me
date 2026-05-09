import 'package:flutter/material.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/storage_service.dart';
import 'package:memorias_ancladas/features/home/widgets/memory_card.dart';
import 'package:memorias_ancladas/shared/widgets/empty_state.dart';

class MemoryGrid extends StatefulWidget {
  final String searchQuery;
  final String category;

  const MemoryGrid({
    super.key,
    required this.searchQuery,
    required this.category,
  });

  @override
  State<MemoryGrid> createState() => _MemoryGridState();
}

class _MemoryGridState extends State<MemoryGrid> {
  final StorageService _storageService = StorageService();
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void didUpdateWidget(MemoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.category != widget.category) {
      _filterMemories();
    }
  }

  Future<void> _loadMemories() async {
    await _storageService.init();
    setState(() {
      _memories = _storageService.getAllMemories();
      _isLoading = false;
    });
    _filterMemories();
  }

  void _filterMemories() {
    setState(() {
      _memories = _storageService.getAllMemories().where((memory) {
        // Filtrar por búsqueda
        final matchesSearch = widget.searchQuery.isEmpty ||
            memory.previewText
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase());

        // Filtrar por categoría
        final matchesCategory = widget.category == 'todos' ||
            _getMemoryCategory(memory) == widget.category;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _getMemoryCategory(Memory memory) {
    // Lógica simple para categorías basada en fecha o tipo
    final now = DateTime.now();
    final daysDiff = now.difference(memory.createdAt).inDays;

    if (daysDiff < 7) return 'eventos';
    if (daysDiff < 30) return 'familia';
    return 'viajes';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_memories.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.memory,
          title: 'Sin recuerdos',
          message: 'Comienza a crear tus primeros recuerdos',
          buttonText: 'Crear recuerdo',
          onPressed: () {},
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final memory = _memories[index];
          return MemoryCard(memory: memory);
        },
        childCount: _memories.length,
      ),
    );
  }
}