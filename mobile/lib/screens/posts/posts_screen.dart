import 'package:flutter/material.dart';

import '../../widgets/open_menu_button.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: OpenMenuButton.leading(onOpenMenu),
        title: const Text('Posts'),
      ),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
