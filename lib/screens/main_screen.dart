import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'jasa_vacancies_screen.dart';
import 'registry_screen.dart';
import 'swipes_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    const screens = [SwipeScreen(), RegistryScreen(), JasaVacanciesScreen()];

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.currentIndex,
        onTap: navigationProvider.changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe_rounded),
            label: 'Свайпы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_outlined),
            label: 'Реестр',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            label: 'Jasa',
          ),
        ],
      ),
    );
  }
}
