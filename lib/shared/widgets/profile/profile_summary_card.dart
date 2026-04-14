import 'package:flutter/material.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/shared/widgets/profile/profile_avatar.dart';

class ProfileSummaryCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onEditPhoto;

  const ProfileSummaryCard({
    super.key,
    required this.profile,
    this.onEditPhoto,
  });

  String _formatRole(String roleId) {
    if (roleId.isEmpty) return 'Usuario';
    final normalized = roleId.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _memberSince(DateTime? date) {
    if (date == null) return 'Miembro reciente';
    return 'Miembro desde ${date.day}/${date.month}/${date.year}';
  }

  String _lastLogin(DateTime? date) {
    if (date == null) return 'Sin ultimo acceso registrado';
    return 'Ultimo acceso ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE83E6C),
            const Color(0xFFF2994A),
            colors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE83E6C).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                photoUrl: profile.photoUrl,
                onEditPhoto: onEditPhoto,
                radius: 42,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName.isEmpty ? 'Tu perfil' : profile.fullName,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email ?? 'Email pendiente',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaChip(
                icon: Icons.favorite_rounded,
                label: _formatRole(profile.rolId),
              ),
              _MetaChip(
                icon: Icons.auto_awesome_rounded,
                label: _memberSince(profile.createdAt),
              ),
              _MetaChip(
                icon: Icons.access_time_filled_rounded,
                label: _lastLogin(profile.lastLogin),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Una ficha clara y expresiva ayuda a que tus contactos te recuerden por afinidades, contexto y tono de relacion.',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
