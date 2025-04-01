import 'package:flutter/material.dart';
// Ensure LoadingWidget import is correct
import 'package:employeemanagment/core/widgets/loading_widget.dart';

// Define the enum for button types *outside* the class
// This ensures 'ButtonType' is defined before it's used in the constructor.
enum ButtonType { elevated, outlined, text }

/// A reusable button widget with different styles and loading state.
class ButtonWidget extends StatelessWidget {
  /// Callback function when the button is pressed. Null if disabled.
  final VoidCallback? onPressed;
  /// The text displayed on the button.
  final String text;
  /// The style type of the button (elevated, outlined, or text).
  final ButtonType type;
  /// Optional icon displayed before the text.
  final IconData? icon;
  /// If true, shows a loading indicator instead of the button content.
  final bool isLoading;
  /// Optional: Overrides the theme's background color for the button.
  final Color? backgroundColor;
  /// Optional: Overrides the theme's foreground color (text/icon) for the button.
  final Color? foregroundColor;
  /// Optional: Sets a minimum width for the button.
  final double? minWidth;

  /// Creates a ButtonWidget instance.
  const ButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.type = ButtonType.elevated, // Default style is elevated
    this.icon, // Parameter for the leading icon
    this.isLoading = false,
    this.backgroundColor, // Parameter for background color override
    this.foregroundColor, // Parameter for foreground color override
    this.minWidth, // Parameter for minimum width
  });

  @override
  Widget build(BuildContext context) {
    // Determine the content to display: loading indicator or icon+text
    Widget buttonContent = isLoading
        ? const LoadingWidget(size: 24.0, strokeWidth: 3.0) // Show loading indicator
        : Row(
            mainAxisSize: MainAxisSize.min, // Row takes minimum space needed
            mainAxisAlignment: MainAxisAlignment.center, // Center content within row
            children: [
              // Display icon if provided
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              // Display the button text
              Text(text),
            ],
          );

     // --- Generate ButtonStyle based on overrides ---
     // Create a base ButtonStyle to potentially apply overrides
     final ButtonStyle? overrideStyle = (backgroundColor != null || foregroundColor != null || minWidth != null)
      ? ButtonStyle(
          // Set background color, handling the disabled state (when isLoading is true)
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
             (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  // Use provided background color with reduced opacity when disabled
                  return backgroundColor?.withOpacity(0.5);
                }
                // Otherwise, use the provided background color
                return backgroundColor;
             },
          ),
          // Set foreground (text/icon) color
          foregroundColor: WidgetStateProperty.all(foregroundColor),
          // Set minimum size if minWidth is provided
          minimumSize: minWidth != null
             ? WidgetStateProperty.all(Size(minWidth!, 40)) // Example fixed height of 40
             : null,
          // Add other potential style overrides here if needed (e.g., padding, shape)
          // padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        )
      : null; // If no overrides, style is purely determined by the theme for the specific button type

    // --- Return the appropriate Flutter Button Widget ---
    // Based on the 'type' parameter, return ElevatedButton, OutlinedButton, or TextButton
    switch (type) {
      case ButtonType.elevated:
        return ElevatedButton(
          // Apply the generated override style. If null, ElevatedButton uses its default theme style.
          style: overrideStyle,
          // Disable onPressed callback when isLoading is true
          onPressed: isLoading ? null : onPressed,
          child: buttonContent, // Display loading or icon/text
        );
      case ButtonType.outlined:
        return OutlinedButton(
          style: overrideStyle,
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
      case ButtonType.text:
        return TextButton(
          style: overrideStyle,
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
      // No default needed as ButtonType enum covers all cases.
    }
  }
}