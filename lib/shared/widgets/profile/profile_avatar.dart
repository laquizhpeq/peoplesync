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
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colors.primary,
                const Color(0xFFFF5A5F),
                const Color(0xFFFFB347),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: colors.surface,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Icon(Icons.person_rounded, size: radius, color: colors.primary)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
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
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: onEditPhoto,
            ),
          ),
        ),
      ],
    );
  }
}
