import 'package:flutter/material.dart';
import 'package:employeemanagment/core/models/user_model.dart'; // Optional: if passing UserModel

class UserAvatar extends StatelessWidget {
  final String? initials;
  final double radius;
  final double fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const UserAvatar({
    super.key,
    this.initials,
    this.radius = 24.0, // Default size
    this.fontSize = 16.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  // Factory constructor to create from UserModel
  factory UserAvatar.fromModel(UserModel user, {double radius = 24.0, double fontSize = 16.0, Color? backgroundColor, Color? foregroundColor}) {
      return UserAvatar(
        initials: user.initials,
        radius: radius,
        fontSize: fontSize,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer; // Use a container color
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimaryContainer;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials?.toUpperCase() ?? '??', // Handle null initials
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      ),
    );
  }
}