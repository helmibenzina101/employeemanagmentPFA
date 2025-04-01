import 'package:flutter/material.dart';

class ReviewRatingWidget extends StatelessWidget {
  final String criteria;
  final int rating; // e.g., 1 to 5
  final int maxRating;
  final ValueChanged<int>? onChanged; // If editable

  const ReviewRatingWidget({
    super.key,
    required this.criteria,
    required this.rating,
    this.maxRating = 5,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEditable = onChanged != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(criteria, style: theme.textTheme.bodyLarge)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxRating, (index) {
              final currentStar = index + 1;
              return IconButton(
                icon: Icon(
                  currentStar <= rating ? Icons.star : Icons.star_border,
                  color: currentStar <= rating ? Colors.amber : theme.disabledColor,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Remove default padding
                onPressed: isEditable ? () => onChanged!(currentStar) : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}