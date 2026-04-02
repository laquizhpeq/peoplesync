import 'package:flutter/material.dart';
import 'package:peoplesync/shared/widgets/design/buttons/app_primary_button.dart';

class AuthMainActionButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const AuthMainActionButton({
    super.key,
    required this.isLoading,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: AppPrimaryButton(
          onPressed: onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
