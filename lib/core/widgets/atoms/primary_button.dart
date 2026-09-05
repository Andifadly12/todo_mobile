import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
    ),
  );
}
