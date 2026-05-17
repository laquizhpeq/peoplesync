import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/shared/widgets/profile/profile_section_card.dart';
import 'package:peoplesync/shared/widgets/profile/profile_summary_card.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:peoplesync/core/constants/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                Align(
                  alignment: Alignment.centerRight,
                  child: _ProfileSettingsMenu(),
                ),
                ProfileSummaryCard(
                  profile: profile,
                  onEditPhoto: () {
                    context.push(Routes.profileEdit);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(Routes.profileEdit),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar mi perfil'),
                  ),
                ),
                const SizedBox(height: 24),
                _QrIdentityCard(profile: profile),
                const SizedBox(height: 24),
                _AboutYouSection(profile: profile),
                const SizedBox(height: 24),
                _AffinityHighlights(profile: profile),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _ProfileMenuAction { settings, logout }

class _ProfileSettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Configuracion',
      padding: EdgeInsets.zero,
      onSelected: (value) => _handleSelection(context, value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => const [
        PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.settings,
          child: Row(
            children: [
              Icon(Icons.tune_rounded),
              SizedBox(width: 10),
              Text('Configuracion'),
            ],
          ),
        ),
        PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.logout,
          child: Row(
            children: [
              Icon(Icons.logout_rounded),
              SizedBox(width: 10),
              Text('Cerrar sesion'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajustes',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSelection(
    BuildContext context,
    _ProfileMenuAction action,
  ) async {
    switch (action) {
      case _ProfileMenuAction.settings:
        if (context.mounted) {
          context.push(Routes.settings);
        }
        break;
      case _ProfileMenuAction.logout:
        await getIt<AuthService>().signOut();
        getIt<NavigationProvider>().clearMenus();
        getIt<ConnectionsViewModel>().clear();

        if (context.mounted) {
          context.go(Routes.login);
        }
        break;
    }
  }
}

class _AboutYouSection extends StatelessWidget {
  final UserProfile profile;

  const _AboutYouSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final socialCount = profile.socialProfiles.length;
    final cards = <Widget>[
      _AboutInfoCard(
        icon: Icons.mail_outline_rounded,
        title: 'Email',
        value: (profile.email?.trim().isNotEmpty ?? false)
            ? profile.email!
            : 'Email pendiente',
      ),
      _AboutInfoCard(
        icon: Icons.location_on_outlined,
        title: 'Ciudad',
        value: (profile.city?.trim().isNotEmpty ?? false)
            ? profile.city!
            : 'Ciudad pendiente',
      ),
      _AboutInfoCard(
        icon: Icons.person_outline_rounded,
        title: 'Rol',
        value: profile.rolId.trim().isNotEmpty ? profile.rolId : 'Usuario',
      ),
      _AboutInfoCard(
        icon: Icons.public_rounded,
        title: 'Redes',
        value: socialCount > 0 ? '$socialCount visibles' : 'Sin redes visibles',
      ),
    ];

    return ProfileSectionCard(
      title: 'Mas informacion de ti',
      subtitle:
          'Tu ficha publica debe dejar claro quien eres, donde estas y que contexto compartes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;

              if (compact) {
                return Column(
                  children: cards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(width: double.infinity, child: card),
                        ),
                      )
                      .toList(),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 6),
          _AboutBioBlock(
            text: (profile.bio?.trim().isNotEmpty ?? false)
                ? profile.bio!
                : 'Anade una bio breve para que los demas entiendan mejor tu perfil.',
          ),
        ],
      ),
    );
  }
}

class _AffinityHighlights extends StatelessWidget {
  final UserProfile profile;

  const _AffinityHighlights({required this.profile});

  @override
  Widget build(BuildContext context) {
    final favoriteSong =
        'Tu cancion favorita ayuda a que la gente te recuerde mejor.';
    final affinityText = profile.bio?.trim().isNotEmpty == true
        ? 'Tu bio ya aporta tono personal. Completa afinidades desde editar perfil para que tu ficha tenga mas identidad.'
        : 'Intereses, hobbies y rasgos que quieres que otros asocien contigo.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HighlightCard(
                icon: Icons.music_note_rounded,
                title: 'Cancion favorita',
                subtitle: favoriteSong,
              ),
              SizedBox(height: 12),
              _HighlightCard(
                icon: Icons.favorite_rounded,
                title: 'Gustos y afinidades',
                subtitle: affinityText,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _HighlightCard(
                icon: Icons.music_note_rounded,
                title: 'Cancion favorita',
                subtitle: favoriteSong,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HighlightCard(
                icon: Icons.favorite_rounded,
                title: 'Gustos y afinidades',
                subtitle: affinityText,
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
                colors: [Color(0xFFE83E6C), Color(0xFFF2994A)],
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

class _AboutInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AboutInfoCard({
    required this.icon,
    required this.title,
    required this.value,
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutBioBlock extends StatelessWidget {
  final String text;

  const _AboutBioBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
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
