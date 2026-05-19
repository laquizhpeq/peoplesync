import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback? onEditPhoto;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.onEditPhoto,
    this.radius = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colors.primary,
                const Color(0xFFE83E6C),
                const Color(0xFFFFD36E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipOval(
            child: SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: photoUrl != null
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.person_rounded,
                          size: radius,
                          color: colors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Container(
                      color: colors.surface,
                      child: Icon(
                        Icons.person_rounded,
                        size: radius,
                        color: colors.primary,
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: onEditPhoto,
            ),
          ),
        ),
      ],
    );
  }
}
