import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/contacts/models/relationship_type_preset.dart';
import 'package:peoplesync/shared/widgets/common/empty_state.dart';
import 'package:peoplesync/shared/widgets/common/loading_widget.dart';
import 'package:peoplesync/shared/widgets/contacts/connection_contact_card.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ConnectionsView();
  }
}

enum _ConnectionFilter { all, favorites, care, recent, linked }

class _ConnectionsView extends StatefulWidget {
  const _ConnectionsView();

  @override
  State<_ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<_ConnectionsView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _ConnectionFilter _filter = _ConnectionFilter.all;
  final Set<String> _selectedRelationshipTypes = <String>{};
  bool _onlyFavorites = false;
  bool _onlyCare = false;
  bool _onlyLinked = false;
  bool _onlyRecent = false;

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
        final listItems = _buildListItems(contacts);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              sliver: SliverToBoxAdapter(
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
                      activeFilterCount: _activeFilterCount,
                      hasQuery: _query.isNotEmpty,
                      onOpenFilters: () => _openFilters(context),
                      onClearSearch: () {
                        _searchController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.contacts.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverToBoxAdapter(
                  child: AppEmptyState(
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
                  ),
                ),
              )
            else if (contacts.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverToBoxAdapter(
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No hay resultados con esos filtros',
                    description:
                        'La interfaz mejora cuando puedes recortar ruido. Ajusta la busqueda o cambia el filtro.',
                  ),
                ),
              )
            else ...[
              if (_query.isNotEmpty || _filter != _ConnectionFilter.all)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: _ResultsSummary(
                      visible: contacts.length,
                      total: viewModel.contacts.length,
                      activeFilter: _resultsSummaryLabel,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList.builder(
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    return switch (item) {
                      _ConnectionsListSpacer() => const SizedBox(height: 14),
                      _ConnectionsListSectionHeader(:final title) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _GroupHeader(title: title),
                      ),
                      _ConnectionsListContact(:final contact) =>
                        ConnectionContactCard(contact: contact),
                    };
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<ContactRecord> _applyFilters(List<ContactRecord> contacts) {
    final filtered = contacts.where((contact) {
      if (_query.isNotEmpty && !_matchesQuery(contact, _query)) {
        return false;
      }

      if (_onlyFavorites && !contact.relationship.isFavorite) return false;
      if (_onlyCare && !contact.relationship.wantsToStrengthenRelationship) {
        return false;
      }
      if (_onlyLinked && contact.linkedUserUid == null) return false;
      if (_onlyRecent && !_isRecent(contact)) return false;

      if (_selectedRelationshipTypes.isNotEmpty) {
        final preset = resolveRelationshipPreset(contact);
        if (preset == null || !_selectedRelationshipTypes.contains(preset.key)) {
          return false;
        }
      }

      return true;
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

  int get _activeFilterCount {
    var count = 0;
    if (_onlyFavorites) count++;
    if (_onlyCare) count++;
    if (_onlyLinked) count++;
    if (_onlyRecent) count++;
    count += _selectedRelationshipTypes.length;
    return count;
  }

  String get _resultsSummaryLabel {
    if (_activeFilterCount == 0) return 'Vista general';
    if (_selectedRelationshipTypes.length == 1) {
      final preset = relationshipTypePresets.firstWhere(
        (item) => item.key == _selectedRelationshipTypes.first,
        orElse: () => relationshipTypePresets.first,
      );
      return preset.label;
    }
    return 'Filtros activos';
  }

  Future<void> _openFilters(BuildContext context) async {
    final selectedTypes = Set<String>.from(_selectedRelationshipTypes);
    var onlyFavorites = _onlyFavorites;
    var onlyCare = _onlyCare;
    var onlyLinked = _onlyLinked;
    var onlyRecent = _onlyRecent;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Combina estados y tipos de relacion para recortar ruido de verdad.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Estado',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Favoritos'),
                          selected: onlyFavorites,
                          onSelected: (value) {
                            setModalState(() => onlyFavorites = value);
                          },
                        ),
                        FilterChip(
                          label: const Text('A cuidar'),
                          selected: onlyCare,
                          onSelected: (value) {
                            setModalState(() => onlyCare = value);
                          },
                        ),
                        FilterChip(
                          label: const Text('Vinculados'),
                          selected: onlyLinked,
                          onSelected: (value) {
                            setModalState(() => onlyLinked = value);
                          },
                        ),
                        FilterChip(
                          label: const Text('Recientes'),
                          selected: onlyRecent,
                          onSelected: (value) {
                            setModalState(() => onlyRecent = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipo de relacion',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: relationshipTypePresets.map((preset) {
                        return FilterChip(
                          avatar: Icon(
                            preset.icon,
                            size: 16,
                            color: preset.color,
                          ),
                          label: Text(preset.label),
                          selected: selectedTypes.contains(preset.key),
                          onSelected: (value) {
                            setModalState(() {
                              if (value) {
                                selectedTypes.add(preset.key);
                              } else {
                                selectedTypes.remove(preset.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                selectedTypes.clear();
                                onlyFavorites = false;
                                onlyCare = false;
                                onlyLinked = false;
                                onlyRecent = false;
                              });
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedRelationshipTypes
                                  ..clear()
                                  ..addAll(selectedTypes);
                                _onlyFavorites = onlyFavorites;
                                _onlyCare = onlyCare;
                                _onlyLinked = onlyLinked;
                                _onlyRecent = onlyRecent;
                                _filter = _activeFilterCount == 0
                                    ? _ConnectionFilter.all
                                    : _ConnectionFilter.favorites;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  List<_ConnectionsListItem> _buildListItems(List<ContactRecord> contacts) {
    if (_query.isNotEmpty || _filter != _ConnectionFilter.all) {
      return contacts
          .map<_ConnectionsListItem>(
            (contact) => _ConnectionsListContact(contact),
          )
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

    final sections = <_ConnectionsListItem>[];

    void addSection(String title, List<ContactRecord> items) {
      if (items.isEmpty) return;
      if (sections.isNotEmpty) {
        sections.add(const _ConnectionsListSpacer());
      }
      sections.add(_ConnectionsListSectionHeader(title));
      sections.addAll(
        items.map<_ConnectionsListItem>(
          (contact) => _ConnectionsListContact(contact),
        ),
      );
    }

    addSection('Favoritos', favoriteContacts);
    addSection('Recientes', recentContacts);
    addSection('Resto', otherContacts);

    return sections;
  }
}

sealed class _ConnectionsListItem {
  const _ConnectionsListItem();
}

class _ConnectionsListContact extends _ConnectionsListItem {
  final ContactRecord contact;

  const _ConnectionsListContact(this.contact);
}

class _ConnectionsListSectionHeader extends _ConnectionsListItem {
  final String title;

  const _ConnectionsListSectionHeader(this.title);
}

class _ConnectionsListSpacer extends _ConnectionsListItem {
  const _ConnectionsListSpacer();
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
  final int activeFilterCount;
  final bool hasQuery;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearSearch;

  const _ConnectionsToolbar({
    required this.controller,
    required this.activeFilterCount,
    required this.hasQuery,
    required this.onOpenFilters,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
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
            ),
            const SizedBox(width: 10),
            _FiltersMiniCard(
              activeFilterCount: activeFilterCount,
              onTap: onOpenFilters,
            ),
          ],
        ),
      ],
    );
  }
}

class _FiltersMiniCard extends StatelessWidget {
  final int activeFilterCount;
  final VoidCallback onTap;

  const _FiltersMiniCard({
    required this.activeFilterCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: activeFilterCount > 0
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
            ),
            color: activeFilterCount > 0
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
                : theme.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: activeFilterCount > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: activeFilterCount > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (activeFilterCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '$activeFilterCount activos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
  final String activeFilter;

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
          activeFilter,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
