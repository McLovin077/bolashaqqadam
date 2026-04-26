import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/glass_panel.dart';
import 'jobs_screen.dart';
import 'profile_screen.dart';
import 'swipes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AppProvider>().registerDailyVisit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    const screens = [SwipeScreen(), ProfileScreen(), JobsScreen()];

    const destinations = [
      _NavDestination(label: 'Свайпы', icon: LucideIcons.sparkles),
      _NavDestination(label: 'Профиль', icon: Icons.person_outline),
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
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassPanel(
          padding: const EdgeInsets.all(8),
          radius: 30,
          blur: 28,
          color: const Color(0xFF0A1020).withValues(alpha: 0.88),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF152240).withValues(alpha: 0.95),
              const Color(0xFF0A1020).withValues(alpha: 0.86),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF59A8FF).withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
          child: SizedBox(
            height: 78,
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
        borderRadius: BorderRadius.circular(24),
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B3F78), Color(0xFF112B57)],
              )
            : null,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4D7CFF).withValues(alpha: 0.22)
              : Colors.transparent,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF3A7BFF).withValues(alpha: 0.18),
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
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  destination.icon,
                  size: 19,
                  color: isSelected ? const Color(0xFFBFE1FF) : Colors.white60,
                ),
                const SizedBox(height: 6),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
