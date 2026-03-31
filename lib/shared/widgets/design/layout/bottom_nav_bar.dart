import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  int _calculateSelectedIndex(BuildContext context, List<String> routes) {
    try {
      final String location = GoRouterState.of(context).uri.toString();
      final index = routes.indexOf(location);
      return index >= 0 ? index : 0;
    } catch (e) {
      return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index, List<String> routes) {
    if (index < routes.length) {
      context.go(routes[index]);
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
        print(
          'BottomNavBar: Hiding because only 1 menu was found. Firestore needs at least 2 for BottomNavigationBar.',
        );
      }
      return const SizedBox.shrink();
    }

    final routes = navProvider.menus.map((m) => m.route).toList();

    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(context, routes),
      onTap: (index) => _onItemTapped(context, index, routes),
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      items: navProvider.menus
          .map(
            (menu) => BottomNavigationBarItem(
              icon: Icon(menu.iconData),
              label: menu.title,
            ),
          )
          .toList(),
    );
  }
}
