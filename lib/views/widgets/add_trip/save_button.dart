import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback? onPressed;
  final String updateText;
  final String createText;

  const SaveButton({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onPressed,
    required this.updateText,
    required this.createText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 64,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(isEditing ? updateText : createText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
