import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';
import 'package:memorias_ancladas/features/capture/capture_screen.dart';
import 'package:memorias_ancladas/features/home/widgets/custom_app_bar.dart';
import 'package:memorias_ancladas/features/home/widgets/stories_section.dart';
import 'package:memorias_ancladas/features/home/widgets/smart_search_bar.dart';
import 'package:memorias_ancladas/features/home/widgets/category_chips.dart';
import 'package:memorias_ancladas/features/home/widgets/memory_grid.dart';
import 'package:memorias_ancladas/features/scan/scan_screen.dart';
import 'package:memorias_ancladas/features/memory/memory_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'todos';
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ScanScreen(),
    const CaptureScreen(),
    const MemoryListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 'Inicio', 0),
                //_buildNavItem(Icons.search, 'Escanear', 1),
                _buildNavItem(Icons.add_circle, 'Crear', 2, isSpecial: true),
                _buildNavItem(Icons.list_alt, 'Mis Recuerdos', 3),
                _buildNavItem(Icons.person, 'Perfil', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {bool isSpecial = false}) {
    final isSelected = _selectedIndex == index;

    if (isSpecial) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary),
          iconSize: 28,
          onPressed: () => setState(() => _selectedIndex = index),
        ),
        if (isSelected)
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _searchQuery = '';
  String _selectedCategory = 'todos';

  void _navigateToScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomAppBar(),
              const SizedBox(height: 16),

              SmartSearchBar(
                onTap: _navigateToScan,
                hintText: 'Buscar o escanear objeto...',
              ),

              const SizedBox(height: 24),
              const StoriesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: CategoryChips(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: MemoryGrid(
            searchQuery: _searchQuery,
            category: _selectedCategory,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text('Usuario'),
            SizedBox(height: 8),
            Text('mis.memorias@ejemplo.com'),
            SizedBox(height: 16),
            Text('Próximamente más funciones...'),
          ],
        ),
      ),
    );
  }
}