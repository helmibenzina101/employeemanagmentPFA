import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres Application')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: const [
          // TODO: Implement Application Settings
          ListTile(
            leading: Icon(Icons.leave_bags_at_home_outlined),
            title: Text('Types de Congés'),
            subtitle: Text('Définir les types et soldes initiaux'),
            // onTap: () => context.push(...) // Navigate to leave type settings
          ),
          ListTile(
            leading: Icon(Icons.star_outline),
            title: Text('Critères d\'Évaluation'),
            subtitle: Text('Gérer les critères pour les évaluations'),
            // onTap: () => context.push(...) // Navigate to performance criteria settings
          ),
          ListTile(
            leading: Icon(Icons.timer), // Corrected icon name
            title: Text('Paramètres Pointage'),
            subtitle: Text('Heures attendues, règles heures supp...'),
            // onTap: () => context.push(...) // Navigate to presence settings
          ),
           // Add other settings...
           Center(
             child: Padding(
               padding: EdgeInsets.symmetric(vertical: 40.0),
               child: Text('Section Paramètres à implémenter.'),
             ),
           ),
        ],
      ),
    );
  }
}