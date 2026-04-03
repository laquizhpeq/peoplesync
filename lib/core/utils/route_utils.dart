String normalizeAppRoute(String? route) {
  if (route == null || route.isEmpty) return '/';

  final normalized = route.trim().toLowerCase();
  if (normalized == '/home') return '/';
  return normalized;
}

bool isSameAppRoute(String? a, String? b) {
  return normalizeAppRoute(a) == normalizeAppRoute(b);
}
