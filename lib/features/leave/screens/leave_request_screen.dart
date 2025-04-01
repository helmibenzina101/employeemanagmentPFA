import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For context.pop()
// For Timestamp used by model

// Core Imports
import 'package:employeemanagment/core/models/leave_request_model.dart';
import 'package:employeemanagment/core/widgets/text_field_widget.dart';
import 'package:employeemanagment/core/widgets/button_widget.dart';
import 'package:employeemanagment/core/utils/validators.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/app/config/constants.dart';
// Import for snackbar helper functions:
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Added Import

// Feature Imports
import 'package:employeemanagment/features/leave/providers/leave_providers.dart';


/// Screen for users to submit a new leave request.
class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  // State variables for selected dates and leave type
  DateTime? _startDate;
  DateTime? _endDate;
  LeaveType _selectedLeaveType = LeaveType.paid; // Default to 'Paid'

  @override
  void dispose() {
    // Dispose controllers to free resources
    _reasonController.dispose();
    super.dispose();
  }

  /// Shows a DatePicker and updates the state variable for start or end date.
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Determine initial date for the picker
    final initialDate = (isStartDate ? _startDate : _endDate) ?? DateTime.now();
    // Define allowed date range
    final firstDate = DateTime.now().subtract(const Duration(days: 30)); // Allow requests slightly in past?
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2)); // Allow requests up to 2 years ahead

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
       locale: const Locale('fr', 'FR'), // Set locale for French date format
    );

    // If a date was picked, update the corresponding state variable
    if (picked != null && mounted) { // Check if mounted after await
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Auto-adjust end date if it becomes invalid
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
             _endDate = null; // Reset end date if start date is now after it
          }
        } else { // isEndDate
          _endDate = picked;
           // Auto-adjust start date if it becomes invalid
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
             _startDate = null; // Reset start date if end date is now before it
          }
        }
      });
    }
  }

  /// Validates the form and submits the leave request via the controller.
  Future<void> _submit() async {
    // Validate the form fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit if form is invalid
    }
    // Ensure dates are selected
    if (_startDate == null || _endDate == null) {
        // Use the imported snackbar function
        showErrorSnackbar(context, 'Veuillez sélectionner les dates de début et de fin.');
        return;
    }

    // Call the controller method to submit the request
    final success = await ref.read(leaveRequestControllerProvider.notifier).submitLeaveRequest(
          type: _selectedLeaveType,
          startDate: _startDate!, // Use non-null assertion as checked above
          endDate: _endDate!, // Use non-null assertion
          reason: _reasonController.text.trim(),
        );

    // Show feedback and navigate back if successful, check if mounted
    if (success && mounted) {
        // Use the imported snackbar function
        showSuccessSnackbar(context, 'Demande de congé soumise avec succès.');
        context.pop(); // Go back to the previous screen (likely LeaveBalanceScreen)
    } else if (!success && mounted) {
        // Show error message if submission failed
         final errorState = ref.read(leaveRequestControllerProvider);
         if(errorState.hasError){
            // Use the imported snackbar function
            showErrorSnackbar(context, errorState.error.toString());
         } else {
             showErrorSnackbar(context, "Erreur lors de la soumission."); // Generic fallback
         }
    }
  }


  @override
  Widget build(BuildContext context) {
     // Watch the controller state for loading indicator on the button
     final requestState = ref.watch(leaveRequestControllerProvider);
     final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Demande de Congé')),
      body: SingleChildScrollView( // Allow scrolling on smaller devices
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch button
            children: [
               // --- Leave Type Dropdown ---
               DropdownButtonFormField<LeaveType>(
                 value: _selectedLeaveType,
                 decoration: const InputDecoration(
                   labelText: 'Type de Congé',
                   border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                 ),
                 // Generate items from the LeaveType enum
                 items: LeaveType.values.map((LeaveType type) {
                   return DropdownMenuItem<LeaveType>(
                     value: type,
                     // Get user-friendly display name from the model helper
                     child: Text(LeaveRequestModel.getLeaveTypeDisplay(type)),
                   );
                 }).toList(),
                 // Update state when selection changes
                 onChanged: (LeaveType? newValue) {
                   if (newValue != null) {
                     setState(() {
                       _selectedLeaveType = newValue;
                     });
                   }
                 },
                 validator: (value) => value == null ? 'Veuillez sélectionner un type' : null,
               ),
               const SizedBox(height: AppConstants.defaultPadding),

               // --- Date Pickers ---
               Row(
                 children: [
                   // Start Date Picker Field
                   Expanded(
                      child: _buildDatePickerField(context, 'Date de Début', _startDate, true),
                   ),
                   const SizedBox(width: AppConstants.defaultPadding), // Space between date fields
                   // End Date Picker Field
                   Expanded(
                      child: _buildDatePickerField(context, 'Date de Fin', _endDate, false),
                   ),
                 ],
               ),
                const SizedBox(height: AppConstants.defaultPadding),

               // --- Reason Text Field ---
                TextFieldWidget(
                  controller: _reasonController,
                  labelText: 'Raison de la demande',
                   prefixIcon: Icons.notes_outlined,
                   maxLines: 3, // Allow multiple lines for reason
                  validator: (value) => Validators.notEmpty(value, 'Raison'), // Ensure reason is provided
                   textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppConstants.defaultPadding * 2),

                // --- Submit Button ---
                 ButtonWidget(
                   text: 'Soumettre la Demande',
                   isLoading: requestState.isLoading, // Show loading state
                   onPressed: requestState.isLoading ? null : _submit, // Disable button when loading
                 ),
            ],
          ),
        ),
      ),
    );
  }

   /// Helper widget to create a tappable field for date selection.
   Widget _buildDatePickerField(BuildContext context, String label, DateTime? dateValue, bool isStartDate) {
     final theme = Theme.of(context);
     return InkWell( // Make the field tappable
      onTap: () => _selectDate(context, isStartDate), // Trigger date picker on tap
      child: InputDecorator( // Provides InputDecoration styling
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        // Display selected date or placeholder text
        child: Text(
          dateValue != null ? DateFormatter.formatDate(dateValue) : 'Sélectionner...',
          style: TextStyle(
             // Use hint color for placeholder text
             color: dateValue != null ? theme.textTheme.bodyLarge?.color : theme.hintColor,
             fontSize: theme.textTheme.bodyLarge?.fontSize
          ),
        ),
      ),
    );
   }
}

// Add static helper method to LeaveRequestModel for display names if not already there
// Example modification to lib/core/models/leave_request_model.dart:
/*
class LeaveRequestModel {
  // ... existing properties ...

  // ADD THIS STATIC METHOD
  static String getLeaveTypeDisplay(LeaveType type) {
     switch (type) {
       case LeaveType.paid: return 'Congé Payé';
       case LeaveType.unpaid: return 'Sans Solde';
       case LeaveType.sick: return 'Maladie';
       case LeaveType.special: return 'Événement Spécial';
     }
  }

  // Keep instance getter if needed elsewhere
  String get typeDisplay => getLeaveTypeDisplay(type);

  // ... rest of the model ...
}
*/