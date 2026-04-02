import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/utils/route_utils.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  int _calculateSelectedIndex(BuildContext context, List<String> routes) {
    try {
      final location = normalizeAppRoute(GoRouterState.of(context).uri.path);
      final index = routes.indexWhere(
        (route) => isSameAppRoute(route, location),
      );
      return index >= 0 ? index : 0;
    } catch (e) {
      return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index, List<String> routes) {
    if (index < routes.length) {
      context.go(normalizeAppRoute(routes[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final theme = Theme.of(context);

    // BottomNavigationBar requires at least 2 items to render.
    // If we have 0 or 1, we hide it to avoid the "items.length >= 2" assertion error.
    if (navProvider.menus.length < 2) {
      if (navProvider.menus.isNotEmpty) {
        // ignore: avoid_print
        print(
          'BottomNavBar: Hiding because only 1 menu was found. Firestore needs at least 2 for BottomNavigationBar.',
        );
      }
      return const SizedBox.shrink();
    }

    final routes = navProvider.menus.map((m) => m.route).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context, routes),
          onTap: (index) => _onItemTapped(context, index, routes),
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: theme.textTheme.bodySmall,
          items: navProvider.menus
              .map(
                (menu) => BottomNavigationBarItem(
                  icon: Icon(menu.iconData),
                  label: menu.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
