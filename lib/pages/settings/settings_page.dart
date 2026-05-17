import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/settings/developer_token_viewmodel.dart';
import 'package:peoplesync/features/settings/models/developer_token_info.dart';
import 'package:peoplesync/features/settings/models/generated_developer_token.dart';
import 'package:peoplesync/features/settings/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<DeveloperTokenViewModel>(),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final developerTokenViewModel = context.watch<DeveloperTokenViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuracion', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Gestiona la apariencia y las opciones basicas de tu cuenta.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                icon: Icons.palette_rounded,
                title: 'Apariencia',
                child: Column(
                  children: [
                    _ThemeOption(
                      icon: Icons.brightness_auto_rounded,
                      title: 'Automatico',
                      subtitle: 'Sigue la configuracion del sistema',
                      isSelected: themeProvider.isSystemMode,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                    const SizedBox(height: 10),
                    _ThemeOption(
                      icon: Icons.light_mode_rounded,
                      title: 'Modo claro',
                      subtitle: 'Fondo claro con acentos calidos',
                      isSelected: themeProvider.isLightMode,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(height: 10),
                    _ThemeOption(
                      icon: Icons.dark_mode_rounded,
                      title: 'Modo oscuro',
                      subtitle: 'Fondo oscuro mas comodo de noche',
                      isSelected: themeProvider.isDarkMode,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                icon: Icons.manage_accounts_rounded,
                title: 'Cuenta',
                child: Column(
                  children: [
                    _SettingsAction(
                      icon: Icons.logout_rounded,
                      title: 'Cerrar sesion',
                      subtitle: 'Salir de la cuenta actual y volver al acceso',
                      accentColor: colors.error,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                icon: Icons.code_rounded,
                title: 'Para desarrolladores',
                child: _DeveloperTokenSection(
                  viewModel: developerTokenViewModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await getIt<AuthService>().signOut();
  getIt<NavigationProvider>().clearMenus();
  getIt<ConnectionsViewModel>().clear();

  if (context.mounted) {
    context.go(Routes.login);
  }
}

class _DeveloperTokenSection extends StatelessWidget {
  final DeveloperTokenViewModel viewModel;

  const _DeveloperTokenSection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokenInfo = viewModel.tokenInfo;

    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activa el modo desarrollador para habilitar herramientas locales de exportacion y acceso interno a tus contactos.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activar modo desarrollador',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.isServerSupported
                          ? 'Levanta un endpoint HTTP local en esta app para exportar contactos desde SQLite.'
                          : 'En esta plataforma no se levanta servidor local. El modo desarrollador deja disponible la exportacion JSON desde la interfaz.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: viewModel.developerModeEnabled,
                onChanged: viewModel.isUpdatingDeveloperMode
                    ? null
                    : (value) => _handleToggleDeveloperMode(
                          context,
                          viewModel,
                          value,
                        ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tokenInfo?.hasToken == true
                    ? 'Token activo'
                    : 'No hay token activo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _buildDeveloperTokenStatus(tokenInfo),
                style: theme.textTheme.bodySmall,
              ),
              if (viewModel.developerModeEnabled &&
                  viewModel.isServerSupported) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.isServerRunning
                      ? 'Servidor local activo en el puerto ${viewModel.serverPort ?? 8787}.'
                      : 'Servidor local detenido.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (viewModel.serverUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    viewModel.serverUrls.join('\n'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsAction(
          icon: Icons.key_rounded,
          title: tokenInfo?.hasToken == true ? 'Reemplazar token' : 'Generar token',
          subtitle: 'Se mostrara una sola vez y reemplazara el anterior.',
          accentColor: colors.primary,
          onTap: viewModel.isGenerating || viewModel.isRevoking
              ? () {}
              : () => _handleGenerateToken(context, viewModel),
          trailing: viewModel.isGenerating
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _SettingsAction(
          icon: Icons.download_rounded,
          title: 'Exportar contactos JSON',
          subtitle: kIsWeb
              ? 'Genera el JSON directamente desde la interfaz web.'
              : 'Genera el JSON manualmente desde la app.',
          accentColor: colors.secondary,
          onTap: viewModel.isExporting
              ? () {}
              : () => _handleExportContactsJson(context, viewModel),
          trailing: viewModel.isExporting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.secondary,
                  ),
                )
              : null,
        ),
        if (viewModel.hasToken) ...[
          const SizedBox(height: 10),
          _SettingsAction(
            icon: Icons.block_rounded,
            title: 'Revocar token',
            subtitle: 'Anula el token actual para que deje de funcionar.',
            accentColor: colors.error,
            onTap: viewModel.isGenerating || viewModel.isRevoking
                ? () {}
                : () => _handleRevokeToken(context, viewModel),
            trailing: viewModel.isRevoking
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.error,
                    ),
                  )
                : null,
          ),
        ],
      ],
    );
  }

  String _buildDeveloperTokenStatus(DeveloperTokenInfo? tokenInfo) {
    if (tokenInfo == null || !tokenInfo.hasToken) {
      return 'Todavia no has generado un token. Este token es local de la app y sirve para proteger el endpoint local cuando el modo desarrollador esta activo.';
    }

    final createdAt = _formatDateTime(tokenInfo.createdAt);
    final lastUsedAt = _formatDateTime(tokenInfo.lastUsedAt);

    return [
      if (tokenInfo.tokenPrefix != null) 'Prefijo: ${tokenInfo.tokenPrefix}',
      'Creado: $createdAt',
      'Ultimo uso: $lastUsedAt',
      'Scope: solo exportacion local de contactos desde la app.',
    ].join('\n');
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Sin registro';

    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final local = value.toLocal();
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  Future<void> _handleGenerateToken(
    BuildContext context,
    DeveloperTokenViewModel viewModel,
  ) async {
    final shouldReplace = !viewModel.hasToken ||
        await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reemplazar token'),
                content: const Text(
                  'Generar un token nuevo invalidara el actual dentro de esta app.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Reemplazar'),
                  ),
                ],
              ),
            ) ==
            true;

    if (!shouldReplace) return;

    try {
      final generatedToken = await viewModel.generateToken();
      if (!context.mounted) return;
      await _showGeneratedTokenDialog(context, generatedToken);
    } catch (error) {
      AppFeedbackService.showError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _handleToggleDeveloperMode(
    BuildContext context,
    DeveloperTokenViewModel viewModel,
    bool value,
  ) async {
    try {
      await viewModel.setDeveloperModeEnabled(value);
      AppFeedbackService.showInfo(
        value
            ? 'Modo desarrollador activado.'
            : 'Modo desarrollador desactivado.',
      );
    } catch (error) {
      AppFeedbackService.showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _handleRevokeToken(
    BuildContext context,
    DeveloperTokenViewModel viewModel,
  ) async {
    final shouldRevoke = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Revocar token'),
            content: const Text(
              'El token dejara de funcionar inmediatamente dentro de esta app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Revocar'),
              ),
            ],
          ),
        ) ==
        true;

    if (!shouldRevoke) return;

    try {
      await viewModel.revokeToken();
      AppFeedbackService.showInfo('Token revocado.');
    } catch (error) {
      AppFeedbackService.showError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _handleExportContactsJson(
    BuildContext context,
    DeveloperTokenViewModel viewModel,
  ) async {
    try {
      final json = await viewModel.exportContactsJson();
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Exportacion JSON'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kIsWeb
                      ? 'En web no hay servidor local. Este es el JSON exportado desde la propia app.'
                      : 'Este es el JSON exportado manualmente desde la propia app.',
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      json,
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (dialogContext.mounted) {
                  AppFeedbackService.showInfo('JSON copiado.');
                }
              },
              child: const Text('Copiar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (error) {
      AppFeedbackService.showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _showGeneratedTokenDialog(
    BuildContext context,
    GeneratedDeveloperToken generatedToken,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Token generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copialo ahora. No volvera a mostrarse completo.',
            ),
            const SizedBox(height: 14),
            SelectableText(
              generatedToken.token,
              style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: generatedToken.token),
              );
              if (dialogContext.mounted) {
                AppFeedbackService.showInfo('Token copiado.');
              }
            },
            child: const Text('Copiar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
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
              const SizedBox(width: 14),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
