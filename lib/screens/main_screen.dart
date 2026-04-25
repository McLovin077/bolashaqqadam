import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../widgets/glass_panel.dart';
import 'jasa_vacancies_screen.dart';
import 'registry_screen.dart';
import 'swipes_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    const screens = [SwipeScreen(), RegistryScreen(), JobsScreen()];

    const destinations = [
      _NavDestination(label: 'Свайпы', icon: LucideIcons.sparkles),
      _NavDestination(label: 'Реестр', icon: LucideIcons.fileBadge),
      _NavDestination(label: 'Jasa', icon: LucideIcons.briefcase),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF050816),
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: GlassPanel(
          padding: const EdgeInsets.all(8),
          radius: 28,
          blur: 26,
          color: const Color(0xFF0A1020).withValues(alpha: 0.86),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF101A31).withValues(alpha: 0.96),
              const Color(0xFF0A1020).withValues(alpha: 0.82),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF59A8FF).withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
          child: Row(
            children: List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final isSelected = navigationProvider.currentIndex == index;

              return Expanded(
                child: _BottomNavItem(
                  destination: destination,
                  isSelected: isSelected,
                  onTap: () => navigationProvider.changeTab(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF15315A), Color(0xFF0D1F40)],
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF59A8FF).withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  destination.icon,
                  size: 18,
                  color: isSelected ? const Color(0xFF7EBBFF) : Colors.white70,
                ),
                const SizedBox(height: 8),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

class _NavDestination {
  const _NavDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
