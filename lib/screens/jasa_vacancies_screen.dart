import 'package:flutter/material.dart';

import '../widgets/section_placeholder.dart';

class JasaVacanciesScreen extends StatelessWidget {
  const JasaVacanciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _LiftSectionAppBar(title: 'Jasa Вакансии'),
      body: SafeArea(
        child: SectionPlaceholder(
          title: 'Экран вакансий',
          subtitle: 'Здесь появится offline-first лента стажировок и вакансий.',
          icon: Icons.work_outline_rounded,
        ),
      ),
    );
  }
}

class _LiftSectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _LiftSectionAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}
