import 'package:flutter/material.dart';
import 'package:employeemanagment/core/models/performance_review_model.dart';
import 'package:employeemanagment/core/utils/date_formatter.dart';
import 'package:employeemanagment/app/config/constants.dart';
import 'package:employeemanagment/features/performance/widgets/review_rating_widget.dart';

/// A card widget to display a summary and details of a performance review.
class PerformanceReviewCard extends StatelessWidget {
  final PerformanceReviewModel review;
  /// Whether to show the employee's name (e.g., when viewed by manager/HR).
  final bool showEmployeeName;

  const PerformanceReviewCard({
    super.key,
    required this.review,
    this.showEmployeeName = false,
  });

  /// Calculates the average rating from the review's criteria ratings.
  double get averageRating {
    if (review.ratings.isEmpty) return 0.0; // Avoid division by zero
    // Sum all rating values
    double sum = review.ratings.values.fold(0, (prev, element) => prev + element);
    // Calculate and return the average
    return sum / review.ratings.length;
  }

  /// Determines the background color for the leading avatar based on average rating.
  Color _getAverageRatingColor(double avgRating, ThemeData theme) {
     if (avgRating >= 4.0) return Colors.green.shade100;
     if (avgRating >= 2.5) return Colors.orange.shade100;
     return Colors.red.shade100; // Default to red for lower ratings
  }

   /// Determines the text color for the leading avatar based on average rating.
  Color _getAverageRatingTextColor(double avgRating, ThemeData theme) {
      if (avgRating >= 4.0) return Colors.green.shade800;
      if (avgRating >= 2.5) return Colors.orange.shade800;
      return Colors.red.shade800; // Default to red for lower ratings
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avgRating = averageRating; // Calculate average rating once

    return Card(
       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
       elevation: 2,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Slightly rounded corners
      child: ExpansionTile( // Make the card expandable to show details
        tilePadding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 8.0), // Adjust padding
         // --- Header Section ---
        leading: CircleAvatar( // Display average rating visually
           backgroundColor: _getAverageRatingColor(avgRating, theme),
           child: Text(
              avgRating.toStringAsFixed(1), // Format to one decimal place
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getAverageRatingTextColor(avgRating, theme),
              ),
           ),
        ),
        title: Text(
          'Évaluation: ${DateFormatter.formatTimestampDate(review.reviewDate)}',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          // Conditionally include employee name based on the flag
          '${showEmployeeName ? '${review.employeeName} | ' : ''}Période: ${DateFormatter.formatTimestampDate(review.periodStartDate)} - ${DateFormatter.formatTimestampDate(review.periodEndDate)}\nÉvaluateur: ${review.reviewerName}'
        ),
        // *** REMOVE THIS LINE ***
        // isThreeLine: true, // ExpansionTile does not have this parameter
        // *** END REMOVE LINE ***

         // --- Expanded Content (Details) ---
         children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                 AppConstants.defaultPadding,
                 0, // No top padding needed as ExpansionTile adds space
                 AppConstants.defaultPadding,
                 AppConstants.defaultPadding // Padding at the bottom
              ),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Divider(), // Separator
                    // Display Ratings if available
                    if (review.ratings.isNotEmpty) ...[
                       Text("Évaluations Critères:", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                       const SizedBox(height: 4),
                       // Map through ratings and display using ReviewRatingWidget
                       ...review.ratings.entries.map((entry) => ReviewRatingWidget(
                           criteria: entry.key,
                           rating: entry.value,
                           // No onChanged callback here, this is view-only
                       )),
                       const SizedBox(height: 12), // Space after ratings
                    ],

                    // Display Comments Sections
                     _buildCommentSection(theme, "Commentaires Généraux (Évaluateur)", review.overallComments),
                     _buildCommentSection(theme, "Commentaires Employé", review.employeeComments),
                     _buildCommentSection(theme, "Objectifs Prochaine Période", review.goalsForNextPeriod),

                     // TODO: Add Edit button/functionality for employee comments if required by workflow
                 ],
              ),
            ),
         ],
      ),
    );
  }

   /// Helper widget to build a section for displaying comments if content exists.
   Widget _buildCommentSection(ThemeData theme, String title, String content) {
     // Don't display the section if the content is empty or just whitespace
     if (content.trim().isEmpty) return const SizedBox.shrink();

     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 6.0),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Section title
             Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
             const SizedBox(height: 4),
             // Section content
             Text(content, style: theme.textTheme.bodyMedium),
          ],
       ),
     );
   }
}