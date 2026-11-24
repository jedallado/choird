import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/app_version.dart';
import '../../models/auth_session.dart';
import '../login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _versionLabel = AppVersion.label;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }

      setState(() {
        _versionLabel = 'Version ${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      // Fall back to compile-time version from AppVersion.
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text(
            'You will need to sign in again to see songs and set lists. Downloads stay on this phone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await AuthScope.of(context).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).session?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (user != null) _AccountSection(user: user, onSignOut: _signOut),
          const Divider(height: 1),
          ListTile(
            title: const Text('Version'),
            trailing: Text(
              _versionLabel.replaceFirst('Version ', ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.user, required this.onSignOut});

  final AuthUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(user.name),
          subtitle: Text('${user.email}\n${user.roleLabel}'),
          isThreeLine: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
          ),
        ),
      ],
    );
  }
}
