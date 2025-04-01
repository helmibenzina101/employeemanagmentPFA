import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import
import 'package:employeemanagment/features/communication/providers/communication_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/text_field_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/button_widget.dart'; // Ensure this import is correct
import 'package:employeemanagment/core/utils/validators.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:go_router/go_router.dart'; // Corrected import
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Add dependency: multi_select_flutter


class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends ConsumerState<CreateAnnouncementScreen> {
   final _formKey = GlobalKey<FormState>();
   final _titleController = TextEditingController();
   final _contentController = TextEditingController();
   bool _isPinned = false;
   List<UserRole> _selectedRoles = []; // Store selected roles

    final _roleItems = UserRole.values
        .map((role) => MultiSelectItem<UserRole>(role, role.displayName))
        .toList();


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _submit() async {
      if (_formKey.currentState!.validate()) {
          final success = await ref.read(announcementControllerProvider.notifier).createAnnouncement(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              isPinned: _isPinned,
              // Pass null if no roles selected, meaning it's for everyone
              targetRoles: _selectedRoles.isEmpty ? null : _selectedRoles,
          );

         if (success && mounted) {
            showSuccessSnackbar(context, 'Annonce publiée avec succès.');
            context.pop(); // Go back
         } else if (!success && mounted) {
             final errorState = ref.read(announcementControllerProvider);
             if(errorState.hasError){
                showErrorSnackbar(context, errorState.error.toString());
             }
         }
      }
  }


  @override
  Widget build(BuildContext context) {
     final controllerState = ref.watch(announcementControllerProvider);
     final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Créer une Annonce')),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(AppConstants.defaultPadding),
         child: Form(
           key: _formKey,
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  TextFieldWidget(
                     controller: _titleController,
                     labelText: 'Titre',
                     prefixIcon: Icons.title,
                     validator: (value) => Validators.notEmpty(value, 'Titre'),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                   TextFieldWidget(
                     controller: _contentController,
                     labelText: 'Contenu de l\'annonce',
                     prefixIcon: Icons.article_outlined,
                      maxLines: 6,
                      validator: (value) => Validators.notEmpty(value, 'Contenu'),
                       textCapitalization: TextCapitalization.sentences,
                  ),
                   const SizedBox(height: AppConstants.defaultPadding),

                  // Target Roles Selector
                  MultiSelectDialogField<UserRole>(
                     items: _roleItems,
                     title: const Text("Visible par"),
                     selectedColor: theme.primaryColor,
                     buttonIcon: Icon(Icons.group_outlined, color: theme.colorScheme.secondary),
                     buttonText: Text(
                       "Audience Cible (laisser vide pour tous)",
                       style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                     ),
                     chipDisplay: MultiSelectChipDisplay(
                        chipColor: theme.colorScheme.primaryContainer,
                        textStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                        icon: Icon(Icons.close, color: theme.colorScheme.onPrimaryContainer, size: 14),
                        onTap: (value) {
                           setState(() {
                              _selectedRoles.remove(value);
                           });
                        },
                     ),
                     onConfirm: (results) {
                       setState(() {
                         _selectedRoles = results;
                       });
                     },
                      // validator: (value) => value == null || value.isEmpty ? "Sélectionnez au moins un rôle" : null,
                      initialValue: _selectedRoles, // Pre-select if needed
                       decoration: BoxDecoration(
                         border: Border.all(color: theme.dividerColor),
                         borderRadius: BorderRadius.circular(4),
                       ),
                   ),
                  const SizedBox(height: AppConstants.defaultPadding),

                   // Pinned Switch
                   SwitchListTile(
                     title: const Text('Épingler l\'annonce'),
                      subtitle: const Text('Apparaîtra en haut de la liste'),
                      value: _isPinned,
                      onChanged: (bool value) {
                          setState(() {
                             _isPinned = value;
                          });
                      },
                       secondary: Icon(Icons.push_pin_outlined, color: _isPinned ? theme.colorScheme.secondary : theme.disabledColor),
                   ),
                   const SizedBox(height: AppConstants.defaultPadding * 2),

                    ButtonWidget(
                       text: 'Publier l\'Annonce',
                       isLoading: controllerState.isLoading,
                       onPressed: controllerState.isLoading ? null : _submit,
                    ),
              ],
           ),
         ),
      ),
    );
  }
}