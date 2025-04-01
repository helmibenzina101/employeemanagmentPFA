import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:employeemanagment/features/communication/providers/communication_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/features/communication/widgets/announcement_card.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import
import 'package:employeemanagment/app/navigation/app_routes.dart'; // Corrected import


class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsStreamProvider);
    final currentUser = ref.watch(currentUserDataProvider);
    final canCreate = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.rh;

    return Scaffold(
      appBar: AppBar(title: const Text('Annonces Internes')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsStreamProvider),
        child: announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Center(child: Text('Aucune annonce pour le moment.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return AnnouncementCard(announcement: announcements[index]);
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stack) => ErrorMessageWidget(
            message: 'Erreur chargement annonces: $error',
            onRetry: () => ref.invalidate(announcementsStreamProvider),
          ),
        ),
      ),
      floatingActionButton: canCreate ? FloatingActionButton.extended(
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Nouvelle Annonce'),
        onPressed: () => context.push(AppRoutes.createAnnouncement),
      ) : null,
    );
  }
}