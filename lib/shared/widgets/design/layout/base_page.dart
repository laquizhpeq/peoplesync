import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? footer;
  final bool centerBody;

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.centerBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthLikePage = title.trim().isEmpty;

    return Scaffold(
      appBar: isAuthLikePage ? null : AppBar(title: Text(title)),
      body: Container(
        decoration: BoxDecoration(
          gradient: isAuthLikePage
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.95),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.9),
                  ],
                )
              : null,
        ),
        child: Stack(
          children: [
            if (isAuthLikePage) ...[
              Positioned(
                top: -80,
                right: -40,
                child: _GlowOrb(
                  size: 220,
                  color: theme.colorScheme.primary.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                left: -30,
                bottom: 60,
                child: _GlowOrb(
                  size: 180,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: centerBody ? Center(child: body) : body,
            ),
          ],
        ),
      ),
      bottomNavigationBar: footer,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
