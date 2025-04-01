import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
import 'package:employeemanagment/core/models/user_model.dart'; // Corrected import
import 'package:employeemanagment/features/performance/providers/performance_providers.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/loading_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/error_message_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/text_field_widget.dart'; // Corrected import
import 'package:employeemanagment/core/widgets/button_widget.dart'; // Corrected import
import 'package:employeemanagment/core/utils/validators.dart'; // Corrected import
import 'package:employeemanagment/core/utils/date_formatter.dart'; // Corrected import
import 'package:employeemanagment/features/performance/widgets/review_rating_widget.dart'; // Corrected import
import 'package:employeemanagment/app/config/constants.dart'; // Corrected import
import 'package:go_router/go_router.dart'; // For pop


class CreateReviewScreen extends ConsumerStatefulWidget {
  final String? employeeId; // Passed via query parameter

  const CreateReviewScreen({super.key, this.employeeId});

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _periodStartDate;
  DateTime? _periodEndDate;
  final _overallCommentsController = TextEditingController();
  final _employeeCommentsController = TextEditingController(); // Optional: Can employee fill later?
  final _goalsController = TextEditingController();

  // --- Example Rating Criteria ---
   final Map<String, int> _ratings = {
      'Communication': 3, // Default rating
      'Travail d\'équipe': 3,
      'Compétences Techniques': 3,
      'Initiative': 3,
      'Respect des délais': 3,
   };
  // --- End Example Criteria ---

   UserModel? _targetEmployee; // To store fetched employee data


   @override
   void initState() {
      super.initState();
      // Fetch target employee data when screen initializes
      if (widget.employeeId != null) {
         ref.read(userStreamByIdProvider(widget.employeeId!).future).then((user) {
            if (mounted) setState(() => _targetEmployee = user);
         });
      }
   }


  @override
  void dispose() {
    _overallCommentsController.dispose();
    _employeeCommentsController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _periodStartDate : _periodEndDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // Allow past periods
      lastDate: DateTime.now().add(const Duration(days: 90)), // Allow periods ending slightly in future
       locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _periodStartDate = picked;
          if (_periodEndDate != null && _periodEndDate!.isBefore(_periodStartDate!)) _periodEndDate = null;
        } else {
          _periodEndDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) _startDate = null; // Use correct variables
        }
      });
    }
  }


  Future<void> _submit() async {
     if (_formKey.currentState!.validate()) {
        if (_periodStartDate == null || _periodEndDate == null) {
           showErrorSnackbar(context, 'Veuillez sélectionner les dates de début et de fin de période.');
           return;
        }
         if (_targetEmployee == null) {
           showErrorSnackbar(context, 'Employé cible non trouvé.');
           return;
         }

         final success = await ref.read(performanceReviewControllerProvider.notifier).createReview(
             employeeUid: _targetEmployee!.uid,
             employeeName: _targetEmployee!.nomComplet,
             periodStartDate: Timestamp.fromDate(_periodStartDate!),
             periodEndDate: Timestamp.fromDate(_periodEndDate!),
             ratings: _ratings, // Use the state map
             overallComments: _overallCommentsController.text.trim(),
             employeeComments: _employeeCommentsController.text.trim(), // Consider if this should be editable by employee later
             goalsForNextPeriod: _goalsController.text.trim(),
         );

        if (success && mounted) {
           showSuccessSnackbar(context, 'Évaluation enregistrée avec succès.');
           context.pop(); // Go back
        } else if (!success && mounted) {
            final errorState = ref.read(performanceReviewControllerProvider);
            if(errorState.hasError){
               showErrorSnackbar(context, errorState.error.toString());
            }
        }
     }
  }


  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(performanceReviewControllerProvider);
     final theme = Theme.of(context);

     // Handle cases where employeeId is missing or data is loading
     if (widget.employeeId == null) {
        return Scaffold(appBar: AppBar(), body: const ErrorMessageWidget(message: 'ID Employé manquant.'));
     }
      if (_targetEmployee == null) {
         // Could use a FutureProvider here for better loading/error state handling
         return Scaffold(appBar: AppBar(), body: const LoadingWidget());
      }


    return Scaffold(
       appBar: AppBar(title: Text('Évaluation pour ${_targetEmployee!.nomComplet}')),
       body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                  Text('Période d\'Évaluation', style: theme.textTheme.titleLarge),
                   const SizedBox(height: AppConstants.defaultPadding),
                   Row(
                     children: [
                       Expanded(child: _buildDatePickerField(context, 'Début Période', _periodStartDate, true)),
                       const SizedBox(width: AppConstants.defaultPadding),
                       Expanded(child: _buildDatePickerField(context, 'Fin Période', _periodEndDate, false)),
                     ],
                   ),
                   const SizedBox(height: AppConstants.defaultPadding * 1.5),

                   Text('Évaluations par Critère', style: theme.textTheme.titleLarge),
                   const SizedBox(height: AppConstants.defaultPadding / 2),
                   // --- Display Rating Widgets ---
                   ..._ratings.entries.map((entry) => ReviewRatingWidget(
                       criteria: entry.key,
                       rating: entry.value,
                       onChanged: (newRating) {
                          setState(() {
                             _ratings[entry.key] = newRating; // Update the rating in the map
                          });
                       },
                   )),
                    // --- End Rating Widgets ---

                   const SizedBox(height: AppConstants.defaultPadding * 1.5),

                    TextFieldWidget(
                       controller: _overallCommentsController,
                       labelText: 'Commentaires Généraux / Bilan',
                       maxLines: 5,
                       validator: (v) => Validators.notEmpty(v, 'Commentaires généraux'),
                        textCapitalization: TextCapitalization.sentences,
                    ),
                     const SizedBox(height: AppConstants.defaultPadding),
                      TextFieldWidget(
                       controller: _goalsController,
                       labelText: 'Axes d\'amélioration / Objectifs N+1',
                       maxLines: 4,
                       // validator: (v) => Validators.notEmpty(v, 'Objectifs'), // Optional validation
                       textCapitalization: TextCapitalization.sentences,
                    ),
                      const SizedBox(height: AppConstants.defaultPadding),
                     TextFieldWidget(
                       controller: _employeeCommentsController,
                       labelText: 'Commentaires de l\'Employé (Optionnel)',
                       maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                       // Note: Decide on workflow - can employee add this later?
                    ),
                    const SizedBox(height: AppConstants.defaultPadding * 2),

                     ButtonWidget(
                        text: 'Enregistrer l\'Évaluation',
                        isLoading: reviewState.isLoading,
                        onPressed: reviewState.isLoading ? null : _submit,
                     ),
               ],
            ),
          ),
       ),
    );
  }

   // Duplicated from Leave Request Screen - consider moving to a shared utility/widget
    Widget _buildDatePickerField(BuildContext context, String label, DateTime? dateValue, bool isStartDate) {
     final theme = Theme.of(context);
     return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          dateValue != null ? DateFormatter.formatDate(dateValue) : 'Sélectionner...',
          style: TextStyle(
             color: dateValue != null ? theme.textTheme.bodyLarge?.color : theme.hintColor,
             fontSize: theme.textTheme.bodyLarge?.fontSize
          ),
        ),
      ),
    );
   }

  // Need these variables accessible in _selectDate
  DateTime? _startDate;
  DateTime? _endDate;
}