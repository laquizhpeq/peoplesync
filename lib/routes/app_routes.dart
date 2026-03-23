import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/pages/home/home_page.dart';
import 'package:peoplesync/pages/auth/auth_page.dart';
import 'package:peoplesync/pages/profile/profile_page.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/core/di/service_locator.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomePage()),
      GoRoute(
        path: login,
        builder: (context, state) => ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
          child: const AuthPage(),
        ),
      ),
      GoRoute(path: profile, builder: (context, state) => const ProfilePage()),
    ],
  );
}
