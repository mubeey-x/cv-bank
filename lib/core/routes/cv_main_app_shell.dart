import 'package:cv_bank/core/common/widgets/cv_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CvMainAppShell extends StatelessWidget {
  final StatefulNavigationShell navShell;

  const CvMainAppShell({super.key, required this.navShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navShell,
      bottomNavigationBar: CvBottomNav(
        currentIndex: navShell.currentIndex,
        onTap: (index) => navShell.goBranch(
          index,
          initialLocation: index == navShell.currentIndex,
        ),
      ),
    );
  }
}
