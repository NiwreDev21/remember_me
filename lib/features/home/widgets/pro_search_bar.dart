// lib/features/home/widgets/pro_search_bar.dart (Versión más avanzada)
import 'package:flutter/material.dart';
import 'package:memorias_ancladas/core/theme/app_theme.dart';

class ProSearchBar extends StatefulWidget {
  final VoidCallback onScanTap;
  final VoidCallback onCameraTap;
  final Function(String)? onSearchSubmitted;

  const ProSearchBar({
    super.key,
    required this.onScanTap,
    required this.onCameraTap,
    this.onSearchSubmitted,
  });

  @override
  State<ProSearchBar> createState() => _ProSearchBarState();
}

class _ProSearchBarState extends State<ProSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? 120 : 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Barra principal
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(_isExpanded ? 20 : 20),
                border: Border.all(
                  color: _isExpanded
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.05),
                  width: _isExpanded ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isExpanded
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: _isExpanded ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icono de scan animado
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(_isExpanded ? 20 : 20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 32 + (_pulseController.value * 8),
                              height: 32 + (_pulseController.value * 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2 - _pulseController.value * 0.1),
                              ),
                            );
                          },
                        ),
                        const Icon(
                          Icons.qr_code_scanner_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  // Campo de texto o hint
                  Expanded(
                    child: _isExpanded
                        ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      onSubmitted: widget.onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Buscar recuerdos...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Buscar o escanear objeto....',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  // Iconos de acción
                  if (!_isExpanded)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mic_none,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),

                  if (_isExpanded)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: AppColors.primary,
                          onPressed: widget.onCameraTap,
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic, size: 20),
                          color: AppColors.primary,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: AppColors.textTertiary,
                          onPressed: () {
                            setState(() {
                              _isExpanded = false;
                              _searchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Sugerencias (cuando está expandido)
          if (_isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSuggestionChip('📸 Vacaciones'),
                  _buildSuggestionChip('❤️ Momentos especiales'),
                  _buildSuggestionChip('🎉 Celebraciones'),
                  _buildSuggestionChip('🏠 Familia'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        if (widget.onSearchSubmitted != null) {
          widget.onSearchSubmitted!(label);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}