import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/shared/widgets/profile/profile_form.dart';
import 'package:peoplesync/shared/widgets/profile/profile_section_card.dart';
import 'package:peoplesync/shared/widgets/profile/profile_summary_card.dart';

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
                        content: Text('La edicion de foto llegara en otro paso'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _AffinityHighlights(),
                const SizedBox(height: 24),
                ProfileSectionCard(
                  title: 'Tu identidad en PeopleSync',
                  subtitle:
                      'Una ficha rica en contexto ayuda a que los demas te entiendan rapido y recuerden el tono de vuestra relacion.',
                  child: ProfileForm(
                    profile: profile,
                    isSaving: viewModel.isSaving,
                    onSave: (name) async {
                      await viewModel.updateProfile(fullName: name);

                      if (!context.mounted) return;

                      if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage!)),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil guardado con exito')),
                      );
                    },
                  ),
                ),
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
                    'Una pista rapida para abrir conversaciones con contexto',
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
                    'Una pista rapida para abrir conversaciones con contexto',
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
              'Cada contacto puede ser manual o enlazado a otro usuario real, pero ambos comparten campos ricos como bio, intereses, cancion favorita y notas.',
        ),
        SizedBox(height: 12),
        _BulletLine(
          text:
              'Las invitaciones o altas mutuas deberian vivir luego en una coleccion separada de requests para no contaminar contacts.',
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
          child: Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF5A5F)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
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
