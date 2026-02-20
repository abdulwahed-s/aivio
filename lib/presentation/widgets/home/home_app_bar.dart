import 'package:aivio/core/constant/color.dart';
import 'package:flutter/material.dart';

import '../../screens/settings_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const HomeAppBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Library',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      elevation: 0,
      backgroundColor: Appcolor.primaryColor,
      foregroundColor: Colors.white,
      bottom: TabBar(
        controller: tabController,
        indicatorColor: const Color.fromARGB(255, 255, 183, 0),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color.fromARGB(255, 255, 183, 0),
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: Colors.white,
        ),
        tabs: const [
          Tab(text: 'Quizzes'),
          Tab(text: 'Summaries'),
          Tab(text: 'Assignments'),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
