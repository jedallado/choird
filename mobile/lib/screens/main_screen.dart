import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'posts/posts_screen.dart';
import 'scheduled/scheduled_screen.dart';
import 'settings/settings_screen.dart';
import 'songs/song_list_screen.dart';

enum AppMenuSection { home, posts, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppMenuSection _section = AppMenuSection.home;
  int _tabIndex = 0;

  static const _tabs = [
    (
      label: 'Songs',
      icon: Icons.music_note_outlined,
      selectedIcon: Icons.music_note,
    ),
    (
      label: 'Set Lists',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
    ),
  ];

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _selectSection(AppMenuSection section) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _section = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showHome = _section == AppMenuSection.home;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(section: _section, onSelected: _selectSection),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: !showHome,
            child: IndexedStack(
              index: _tabIndex,
              children: [
                SongListScreen(onOpenMenu: _openMenu),
                ScheduledScreen(onOpenMenu: _openMenu),
              ],
            ),
          ),
          if (_section == AppMenuSection.posts)
            PostsScreen(onOpenMenu: _openMenu),
          if (_section == AppMenuSection.settings)
            SettingsScreen(onOpenMenu: _openMenu),
        ],
      ),
      bottomNavigationBar: showHome
          ? NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.label,
                  ),
              ],
            )
          : null,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.section, required this.onSelected});

  final AppMenuSection section;
  final ValueChanged<AppMenuSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: AppColors.background,
      selectedIndex: section.index,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        onSelected(AppMenuSection.values[index]);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 16, 16),
          child: Text(
            'Choird',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: Text('Posts'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}
