import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

/// A reusable text form field widget with common styling and validation support.
class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  // *** ENSURE THIS PARAMETER IS DEFINED ***
  final Widget? suffixIcon; // Allows passing widgets like IconButton

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.suffixIcon, // *** ENSURE THIS IS IN THE CONSTRUCTOR ***
  });

  @override
  Widget build(BuildContext context) {
    // Use TextFormField for built-in validation integration with Form.
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Display prefix icon if provided.
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        // Ensure border styling is consistent (uses theme's OutlineInputBorder by default).
        border: const OutlineInputBorder(),
        // Align label nicely when using multiple lines.
        alignLabelWithHint: maxLines != null && maxLines! > 1,
        // --- ENSURE suffixIcon IS USED HERE ---
        suffixIcon: suffixIcon, // Pass the suffixIcon widget to InputDecoration
        // --- END suffixIcon USAGE ---
        // Other decoration properties inherit from the AppTheme's inputDecorationTheme.
      ),
      keyboardType: keyboardType,
      obscureText: obscureText, // For password fields.
      validator: validator, // Integrate with Form validation.
      inputFormatters: inputFormatters, // For input masking/formatting.
      maxLines: maxLines, // Allow multi-line input.
      textCapitalization: textCapitalization, // Control capitalization.
      readOnly: readOnly, // Make field non-editable if true.
      onTap: onTap, // Callback when the field is tapped (useful with readOnly).
      onChanged: onChanged, // Callback when the field's value changes.
    );
  }
}