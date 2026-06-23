import 'package:flutter/material.dart';

import '../../../../design_system/tokens.dart';

/// Glass action bar with optimistic like/save/dismiss/open.
class ActionBar extends StatelessWidget {
  const ActionBar({
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onSave,
    required this.onDismiss,
    required this.onOpen,
    super.key,
  });

  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(64),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            label: 'Like',
            active: liked,
            onTap: onLike,
          ),
          _ActionButton(
            icon: saved ? Icons.bookmark : Icons.bookmark_border,
            label: 'Save',
            active: saved,
            onTap: onSave,
          ),
          _ActionButton(
            icon: Icons.close,
            label: 'Dismiss',
            onTap: onDismiss,
          ),
          _ActionButton(
            icon: Icons.open_in_new,
            label: 'Open',
            onTap: onOpen,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.error : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
