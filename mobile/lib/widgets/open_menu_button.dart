import 'package:flutter/material.dart';

class OpenMenuButton extends StatelessWidget {
  const OpenMenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static Widget? leading(VoidCallback? onOpenMenu) {
    if (onOpenMenu == null) {
      return null;
    }

    return OpenMenuButton(onPressed: onOpenMenu);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open menu',
      onPressed: onPressed,
      icon: const Icon(Icons.menu),
    );
  }
}
