import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/shared/widgets/profile/profile_section_card.dart';
import 'package:peoplesync/shared/widgets/profile/profile_summary_card.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';
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
            final theme = Theme.of(context);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: theme.colorScheme.error,
                            size: 42,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudo cargar tu perfil',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${viewModel.errorMessage!} Si se repite, cierra y vuelve a abrir la app.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: viewModel.reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
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
                _ProfileSocialsSection(profile: profile),
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
    final favoriteSong = profile.favoriteSong?.trim().isNotEmpty == true
        ? profile.favoriteSong!
        : 'No has definido una cancion favorita.';
    final affinities = profile.affinities;
    final affinityText = affinities.isNotEmpty
        ? affinities.join(', ')
        : 'No has definido gustos o afinidades.';

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
              child: _SpotifyFavoriteCard(
                profile: profile,
                fallbackText: favoriteSong,
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

class _ProfileSocialsSection extends StatelessWidget {
  final UserProfile profile;

  const _ProfileSocialsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final socialProfiles = profile.socialProfiles;

    return ProfileSectionCard(
      title: 'Redes visibles',
      subtitle:
          'Estas son las redes que has configurado en editar perfil y que forman parte de tu ficha.',
      child: socialProfiles.isEmpty
          ? const Text('No has agregado redes sociales todavia.')
          : Column(
              children: socialProfiles
                  .map(
                    (profileItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProfileSocialRow(profileItem: profileItem),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SpotifyFavoriteCard extends StatelessWidget {
  final UserProfile profile;
  final String fallbackText;

  const _SpotifyFavoriteCard({
    required this.profile,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final hasSpotify =
        profile.favoriteSongTrackId?.trim().isNotEmpty == true &&
        profile.favoriteSongExternalUrl?.trim().isNotEmpty == true;

    if (!hasSpotify) {
      return _HighlightCard(
        icon: Icons.music_note_rounded,
        title: 'Cancion favorita',
        subtitle: fallbackText,
      );
    }

    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(profile.favoriteSongExternalUrl!);
        if (uri != null) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: profile.favoriteSongCoverUrl?.trim().isNotEmpty == true
                  ? Image.network(
                      profile.favoriteSongCoverUrl!,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 54,
                      height: 54,
                      color: Colors.black12,
                      child: const Icon(Icons.music_note_rounded),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.favoriteSong ?? 'Cancion favorita',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.favoriteSongArtist ?? 'Spotify',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Abrir en Spotify',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ProfileSocialRow extends StatelessWidget {
  final ContactSocialProfile profileItem;

  const _ProfileSocialRow({required this.profileItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = profileItem.label?.trim().isNotEmpty == true
        ? profileItem.label!
        : _socialPlatformLabel(profileItem.platform);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.public_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(profileItem.value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _socialPlatformLabel(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return 'Instagram';
    case SocialPlatform.x:
      return 'X';
    case SocialPlatform.tiktok:
      return 'TikTok';
    case SocialPlatform.linkedin:
      return 'LinkedIn';
    case SocialPlatform.facebook:
      return 'Facebook';
    case SocialPlatform.telegram:
      return 'Telegram';
    case SocialPlatform.whatsapp:
      return 'WhatsApp';
    case SocialPlatform.youtube:
      return 'YouTube';
    case SocialPlatform.twitch:
      return 'Twitch';
    case SocialPlatform.snapchat:
      return 'Snapchat';
    case SocialPlatform.website:
      return 'Sitio web';
    case SocialPlatform.other:
      return 'Otra red';
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
