import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> categories = const [
    {'id': 'todos', 'label': 'Todos', 'icon': Icons.grid_view},
    {'id': 'pareja', 'label': 'Pareja', 'icon': Icons.favorite},
    {'id': 'eventos', 'label': 'Eventos', 'icon': Icons.celebration},
    {'id': 'familia', 'label': 'Familia', 'icon': Icons.family_restroom},
    {'id': 'viajes', 'label': 'Viajes', 'icon': Icons.flight},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(category['label']),
                ],
              ),
              onSelected: (_) => onCategorySelected(category['id']),
              backgroundColor: AppColors.surfaceLight,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}