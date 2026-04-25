import 'package:flutter/material.dart';

import '../widgets/section_placeholder.dart';

class RegistryScreen extends StatelessWidget {
  const RegistryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _LiftSectionAppBar(title: 'Реестр'),
      body: SafeArea(
        child: SectionPlaceholder(
          title: 'Экран реестра',
          subtitle:
              'Здесь будет список сертификатов, отсортированный по HR-весу.',
          icon: Icons.workspace_premium_outlined,
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
