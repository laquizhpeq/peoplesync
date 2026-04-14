import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/shared/widgets/common/empty_state.dart';
import 'package:peoplesync/shared/widgets/common/loading_widget.dart';
import 'package:peoplesync/shared/widgets/contacts/connection_contact_card.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConnectionsViewModel>(
      create: (_) => getIt<ConnectionsViewModel>(),
      child: const _ConnectionsView(),
    );
  }
}

enum _ConnectionFilter { all, favorites, recent, linked }

class _ConnectionsView extends StatefulWidget {
  const _ConnectionsView();

  @override
  State<_ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<_ConnectionsView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _ConnectionFilter _filter = _ConnectionFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChange);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChange)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChange() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const AppLoadingWidget();
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'No se pudieron cargar tus conexiones',
                description: viewModel.errorMessage!,
              ),
            ),
          );
        }

        final contacts = _applyFilters(viewModel.contacts);
        final groupedContacts = _buildGroups(contacts);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConnectionsHeader(
                total: viewModel.contacts.length,
                onAddManual: () => context.go(Routes.contactNew),
              ),
              const SizedBox(height: 16),
              _ConnectionsToolbar(
                controller: _searchController,
                activeFilter: _filter,
                hasQuery: _query.isNotEmpty,
                onFilterChanged: (filter) {
                  setState(() {
                    _filter = filter;
                  });
                },
                onClearSearch: () {
                  _searchController.clear();
                },
              ),
              const SizedBox(height: 14),
              if (viewModel.contacts.isEmpty)
                AppEmptyState(
                  icon: Icons.groups_rounded,
                  title: 'Todavia no tienes conexiones guardadas',
                  description:
                      'Anade tu primer contacto manualmente y aparecera aqui como una ficha visual.',
                  action: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(Routes.contactNew),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Crear primera conexion'),
                    ),
                  ),
                )
              else if (contacts.isEmpty)
                AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No hay resultados con esos filtros',
                  description:
                      'La interfaz mejora cuando puedes recortar ruido. Ajusta la busqueda o cambia el filtro.',
                )
              else ...[
                if (_query.isNotEmpty || _filter != _ConnectionFilter.all)
                  _ResultsSummary(
                    visible: contacts.length,
                    total: viewModel.contacts.length,
                    activeFilter: _filter,
                  ),
                if (_query.isNotEmpty || _filter != _ConnectionFilter.all)
                  const SizedBox(height: 10),
                ...groupedContacts,
              ],
            ],
          ),
        );
      },
    );
  }

  List<ContactRecord> _applyFilters(List<ContactRecord> contacts) {
    final filtered = contacts.where((contact) {
      if (_query.isNotEmpty && !_matchesQuery(contact, _query)) {
        return false;
      }

      return switch (_filter) {
        _ConnectionFilter.all => true,
        _ConnectionFilter.favorites => contact.relationship.isFavorite,
        _ConnectionFilter.linked => contact.linkedUserUid != null,
        _ConnectionFilter.recent => _isRecent(contact),
      };
    }).toList();

    filtered.sort((a, b) {
      final aDate =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  bool _matchesQuery(ContactRecord contact, String query) {
    final haystack = [
      contact.displayName,
      contact.identity.city,
      contact.identity.company,
      contact.identity.jobTitle,
      contact.relationship.contextNote,
      contact.relationship.relationshipType,
      ...contact.relationship.interests,
      ...contact.relationship.personalityTags,
    ].whereType<String>().join(' ').toLowerCase();

    return haystack.contains(query);
  }

  bool _isRecent(ContactRecord contact) {
    final reference = contact.updatedAt ?? contact.createdAt;
    if (reference == null) return false;
    return DateTime.now().difference(reference).inDays <= 30;
  }

  List<Widget> _buildGroups(List<ContactRecord> contacts) {
    if (_query.isNotEmpty || _filter != _ConnectionFilter.all) {
      return contacts
          .map((contact) => ConnectionContactCard(contact: contact))
          .toList();
    }

    final favoriteContacts = contacts
        .where((contact) => contact.relationship.isFavorite)
        .toList();
    final recentContacts = contacts
        .where(
          (contact) => !contact.relationship.isFavorite && _isRecent(contact),
        )
        .toList();
    final otherContacts = contacts
        .where(
          (contact) => !contact.relationship.isFavorite && !_isRecent(contact),
        )
        .toList();

    final sections = <Widget>[];

    void addSection(String title, List<ContactRecord> items) {
      if (items.isEmpty) return;
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 14));
      }
      sections.add(_GroupHeader(title: title));
      sections.add(const SizedBox(height: 8));
      sections.addAll(
        items.map((contact) => ConnectionContactCard(contact: contact)),
      );
    }

    addSection('Favoritos', favoriteContacts);
    addSection('Recientes', recentContacts);
    addSection('Resto', otherContacts);

    return sections;
  }
}

class _ConnectionsHeader extends StatelessWidget {
  final int total;
  final VoidCallback onAddManual;

  const _ConnectionsHeader({required this.total, required this.onAddManual});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conexiones',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total == 1
                      ? '1 contacto guardado'
                      : '$total contactos guardados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.primary,
            ),
            onPressed: onAddManual,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Nuevo'),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsToolbar extends StatelessWidget {
  final TextEditingController controller;
  final _ConnectionFilter activeFilter;
  final bool hasQuery;
  final ValueChanged<_ConnectionFilter> onFilterChanged;
  final VoidCallback onClearSearch;

  const _ConnectionsToolbar({
    required this.controller,
    required this.activeFilter,
    required this.hasQuery,
    required this.onFilterChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, ciudad, empresa o contexto',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasQuery
                ? IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChipButton(
                label: 'Todos',
                icon: Icons.apps_rounded,
                selected: activeFilter == _ConnectionFilter.all,
                onTap: () => onFilterChanged(_ConnectionFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChipButton(
                label: 'Favoritos',
                icon: Icons.favorite_rounded,
                selected: activeFilter == _ConnectionFilter.favorites,
                onTap: () => onFilterChanged(_ConnectionFilter.favorites),
              ),
              const SizedBox(width: 8),
              _FilterChipButton(
                label: 'Recientes',
                icon: Icons.schedule_rounded,
                selected: activeFilter == _ConnectionFilter.recent,
                onTap: () => onFilterChanged(_ConnectionFilter.recent),
              ),
              const SizedBox(width: 8),
              _FilterChipButton(
                label: 'Vinculados',
                icon: Icons.link_rounded,
                selected: activeFilter == _ConnectionFilter.linked,
                onTap: () => onFilterChanged(_ConnectionFilter.linked),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  final int visible;
  final int total;
  final _ConnectionFilter activeFilter;

  const _ResultsSummary({
    required this.visible,
    required this.total,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            visible == total
                ? '$total conexiones visibles'
                : '$visible de $total conexiones visibles',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _filterLabel(activeFilter),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _filterLabel(_ConnectionFilter filter) {
    return switch (filter) {
      _ConnectionFilter.all => 'Vista general',
      _ConnectionFilter.favorites => 'Favoritos',
      _ConnectionFilter.recent => 'Recientes',
      _ConnectionFilter.linked => 'Vinculados',
    };
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;

  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
