import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.autofillHints,
    this.enabled = true,
  });
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText, enabled;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          autocorrect: false,
          enableSuggestions: keyboardType != TextInputType.visiblePassword,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 21),
            suffixIcon: suffix,
          ),
        ),
      ],
    ),
  );
}
