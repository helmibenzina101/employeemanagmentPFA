import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true, // Default to true for back buttons
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      // Inherits styling from AppTheme.lightTheme.appBarTheme or darkTheme
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}