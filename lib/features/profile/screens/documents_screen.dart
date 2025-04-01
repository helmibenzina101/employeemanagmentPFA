import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp needed in Dialog Model creation

// Core imports
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/models/document_metadata_model.dart';
import 'package:employeemanagment/core/widgets/loading_widget.dart';
import 'package:employeemanagment/core/widgets/error_message_widget.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/utils/validators.dart';
// ADD THIS IMPORT:
import 'package:employeemanagment/core/widgets/button_widget.dart'; // For the Dialog Button
// END ADD IMPORT

// Feature specific imports
import 'package:employeemanagment/features/profile/providers/profile_providers.dart';
import 'package:employeemanagment/features/profile/widgets/document_metadata_list_tile.dart';


class DocumentsScreen extends ConsumerWidget {
  // Optional: Pass userId if HR/Admin is viewing someone else's documents
  final String? targetUserId;

  const DocumentsScreen({super.key, this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDataProvider);
    // Determine whose documents to show: the target user or the current user
    // Fallback to empty string if current user is null (shouldn't happen if logged in)
    final String userIdToShow = targetUserId ?? currentUser?.uid ?? '';
    final bool isViewingOwnDocs = targetUserId == null || targetUserId == currentUser?.uid;
    // Determine if the current user can add document metadata
    final bool canAdd = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.rh;

    // Watch the stream for the documents of the user being viewed
    final documentsAsyncValue = ref.watch(userDocumentsStreamProvider(userIdToShow));

    return Scaffold(
      appBar: AppBar(
        title: Text(isViewingOwnDocs ? 'Mes Documents' : 'Documents Employé'),
      ),
      body: documentsAsyncValue.when(
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Text('Aucun document référencé pour le moment.'),
              ),
            );
          }
          // Display the list with pull-to-refresh
          return RefreshIndicator(
             onRefresh: () async => ref.invalidate(userDocumentsStreamProvider(userIdToShow)),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // Use the custom list tile widget
                return DocumentMetadataListTile(
                    document: documents[index],
                    viewingUserId: userIdToShow, // Pass the ID being viewed
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorMessageWidget(
          message: 'Erreur chargement documents: $error',
          onRetry: () => ref.invalidate(userDocumentsStreamProvider(userIdToShow)),
        ),
      ),
      // Show Floating Action Button only if the user has permission to add
      floatingActionButton: canAdd ? FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ajouter Réf.'),
        tooltip: 'Ajouter une référence de document',
        onPressed: () {
          // Ensure current user ID is available before showing dialog
          if (currentUser?.uid != null) {
            _showAddDocumentMetadataDialog(context, ref, userIdToShow, currentUser!.uid);
          } else {
             // Handle case where current user is somehow null (shouldn't happen)
             showErrorSnackbar(context, "Impossible d'identifier l'utilisateur actuel.");
          }
        },
      ) : null,
    );
  }


  // --- Dialog to Add Document Metadata ---
  void _showAddDocumentMetadataDialog(BuildContext context, WidgetRef ref, String targetUserId, String currentUserId) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    // Default selection for the dropdown
    DocumentType selectedType = DocumentType.other;

    showDialog(
      context: context,
      // Prevent dismissal by tapping outside if needed
      // barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage the dropdown's state locally within the dialog
        return StatefulBuilder(
           builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Ajouter Référence Document'),
                // Use Scrollbar and SingleChildScrollView for long content or small screens
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Take only needed vertical space
                      children: <Widget>[
                        TextFieldWidget(
                          controller: nameController,
                          labelText: 'Nom du document (Ex: Contrat 2024)',
                          validator: (value) => Validators.notEmpty(value, 'Nom du document'),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        DropdownButtonFormField<DocumentType>(
                          value: selectedType,
                          decoration: const InputDecoration(
                             labelText: 'Type de Document',
                             border: OutlineInputBorder(),
                          ),
                          // Generate dropdown items from the enum values
                          items: DocumentType.values.map((DocumentType type) {
                            // Use the display helper from the model for user-friendly names
                            return DropdownMenuItem<DocumentType>(
                              value: type,
                              // Create temporary instance just to get display name/icon
                              child: Row(
                                children: [
                                  Icon(DocumentMetadataModel(id:'', userId:'', documentName:'', type: type, uploadDate:Timestamp.now(), uploadedByUid:'').typeIcon, size: 18),
                                  const SizedBox(width: 8),
                                  Text(DocumentMetadataModel(id:'', userId:'', documentName:'', type: type, uploadDate:Timestamp.now(), uploadedByUid:'').typeDisplay),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (DocumentType? newValue) {
                             // Use the dialog's specific setState to update dropdown selection
                             setStateDialog(() {
                                if (newValue != null) {
                                   selectedType = newValue;
                                }
                             });
                          },
                          validator: (value) => value == null ? 'Veuillez sélectionner un type' : null,
                        ),
                         // TODO: Add Expiry Date Picker if needed for types like certificates
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Annuler'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                    },
                  ),
                  // Use the imported ButtonWidget for the submit action
                  ButtonWidget(
                    text: 'Ajouter',
                    // Disable button while the controller is processing
                    isLoading: ref.watch(documentMetadataControllerProvider).isLoading,
                    onPressed: () async {
                      // Validate the form first
                      if (formKey.currentState?.validate() ?? false) {
                        // Call the controller method to add the metadata
                        final success = await ref.read(documentMetadataControllerProvider.notifier).addDocumentMetadata(
                              userId: targetUserId, // The user this doc belongs to
                              documentName: nameController.text.trim(),
                              type: selectedType,
                              uploadedByUid: currentUserId, // Log who added it
                            );

                        // Handle success or failure, ensure context is still valid
                        if (dialogContext.mounted) {
                           if (success) {
                             Navigator.of(dialogContext).pop(); // Close dialog on success
                             showSuccessSnackbar(context, 'Référence ajoutée.');
                           } else {
                               // Show error if adding failed
                               final errorState = ref.read(documentMetadataControllerProvider);
                                if(errorState.hasError){
                                  showErrorSnackbar(context, errorState.error.toString());
                                } else {
                                   showErrorSnackbar(context, "Erreur lors de l'ajout.");
                                }
                           }
                        }
                      }
                    },
                  ),
                ],
              );
           }
        );
      },
    );
  }
}