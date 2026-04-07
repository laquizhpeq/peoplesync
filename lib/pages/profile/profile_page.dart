import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/shared/widgets/profile/profile_section_card.dart';
import 'package:peoplesync/shared/widgets/profile/profile_summary_card.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await getIt<AuthService>().signOut();
    getIt<NavigationProvider>().clearMenus();

    if (context.mounted) {
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileViewModel>(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          final profile = viewModel.profile;
          if (profile == null) {
            return const Center(child: Text('No se encontro el perfil'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileSummaryCard(
                  profile: profile,
                  onEditPhoto: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La edicion de foto llegara en otro paso',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _QrIdentityCard(profile: profile),
                const SizedBox(height: 24),
                const _AffinityHighlights(),
                const SizedBox(height: 24),
                _IdentitySnapshot(profile: profile),
                const SizedBox(height: 24),
                const ProfileSectionCard(
                  title: 'Modelo de contacto',
                  subtitle:
                      'La agenda no se mezcla con la cuenta. Cada relacion se guarda como una ficha propia y editable.',
                  child: _ContactModelNotes(),
                ),
                const SizedBox(height: 24),
                ProfileSectionCard(
                  title: 'Cuenta',
                  child: Column(
                    children: [
                      const _AccountRow(
                        icon: Icons.security_rounded,
                        title: 'Autenticacion separada del perfil',
                        subtitle:
                            'Tu cuenta sigue dependiendo de Firebase Auth y el perfil solo representa la informacion visible y contextual.',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.push(Routes.profileEdit),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Editar perfil'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Cerrar sesion'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IdentitySnapshot extends StatelessWidget {
  final UserProfile profile;

  const _IdentitySnapshot({required this.profile});

  @override
  Widget build(BuildContext context) {
    final socialCount = profile.socialProfiles.length;

    return ProfileSectionCard(
      title: 'Tu identidad en PeopleSync',
      subtitle:
          'Tu perfil publico se separa de tus conexiones privadas y puedes editarlo cuando quieras.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AccountRow(
            icon: Icons.person_pin_circle_outlined,
            title: profile.city?.trim().isNotEmpty == true
                ? profile.city!
                : 'Ciudad pendiente',
            subtitle: profile.bio?.trim().isNotEmpty == true
                ? profile.bio!
                : 'Anade una bio breve para que los demas entiendan mejor tu perfil.',
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.public_rounded,
            title: socialCount > 0
                ? '$socialCount redes visibles'
                : 'Sin redes visibles',
            subtitle: socialCount > 0
                ? 'Tu ficha ya muestra presencia social estructurada.'
                : 'Puedes anadir redes sociales a tu perfil desde editar perfil.',
          ),
        ],
      ),
    );
  }
}

class _AffinityHighlights extends StatelessWidget {
  const _AffinityHighlights();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        if (isCompact) {
          return const Column(
            children: [
              _HighlightCard(
                icon: Icons.music_note_rounded,
                title: 'Cancion favorita',
                subtitle:
                    'Una pista rapida para recordar el tono y la energia de esa persona',
              ),
              SizedBox(height: 12),
              _HighlightCard(
                icon: Icons.favorite_rounded,
                title: 'Gustos y afinidades',
                subtitle: 'Intereses, hobbies y rasgos que quieres recordar',
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: _HighlightCard(
                icon: Icons.music_note_rounded,
                title: 'Cancion favorita',
                subtitle:
                    'Una pista rapida para recordar el tono y la energia de esa persona',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HighlightCard(
                icon: Icons.favorite_rounded,
                title: 'Gustos y afinidades',
                subtitle: 'Intereses, hobbies y rasgos que quieres recordar',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.onSurfaceVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5A5F), Color(0xFFFF7A59)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _ContactModelNotes extends StatelessWidget {
  const _ContactModelNotes();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BulletLine(
          text:
              'users/{uid} representa a la persona real dentro de la plataforma y su ficha propia.',
        ),
        SizedBox(height: 12),
        _BulletLine(
          text:
              'users/{uid}/contacts/{contactId} representa la agenda personal de ese usuario y el contexto que guarda sobre otras personas.',
        ),
        SizedBox(height: 12),
        _BulletLine(
          text:
              'Cada contacto puede nacer manualmente, desde un usuario enlazado o por importacion futura mediante QR, siempre con campos opcionales y editables.',
        ),
        SizedBox(height: 12),
        _BulletLine(
          text:
              'La ficha esta pensada para guardar identidad, afinidades, contexto y redes sociales sin depender de mensajeria interna.',
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.favorite_rounded,
            size: 16,
            color: Color(0xFFFF5A5F),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _QrIdentityCard extends StatelessWidget {
  final UserProfile profile;

  const _QrIdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrData = getIt<QrService>().generateProfileQrData(profile.uid);

    return ProfileSectionCard(
      title: 'Tu Código QR',
      subtitle: 'Muestra este código para que otros te añadan al instante.',
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
              child: SizedBox(
                width: 160,
                height: 160,
                child: PrettyQrView.data(
                  data: qrData,
                  decoration: PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Escanea para conectar',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AccountRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
