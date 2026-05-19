import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/features/assistant/assistant_chat_viewmodel.dart';
import 'package:peoplesync/features/assistant/models/assistant_chat_models.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AssistantChatViewModel>(
      create: (_) => getIt<AssistantChatViewModel>(),
      child: const _AssistantView(),
    );
  }
}

class _AssistantView extends StatelessWidget {
  const _AssistantView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<AssistantChatViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                _AssistantHeader(model: viewModel.latestModel),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    children: [
                      ...viewModel.messages.map(
                        (message) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChatBubble(message: message),
                        ),
                      ),
                      if (viewModel.pendingContactDraft != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _CreateContactPreviewCard(
                            draft: viewModel.pendingContactDraft!,
                          ),
                        ),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _ErrorCard(message: viewModel.errorMessage!),
                        ),
                    ],
                  ),
                ),
                _Composer(viewModel: viewModel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  final String? model;

  const _AssistantHeader({this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chispa',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model == null
                      ? 'Asistente relacional para cuidar y hacer crecer tu red'
                      : 'Modelo $model',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE85D5D).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AssistantChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == AssistantChatRole.user;
    final isSystem = message.role == AssistantChatRole.system;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? theme.colorScheme.primary
        : isSystem
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateContactPreviewCard extends StatelessWidget {
  final AssistantCreateContactDraft draft;

  const _CreateContactPreviewCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E8), Color(0xFFFFE1D6)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Crear contacto',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DraftLine(label: 'Nombre', value: draft.displayName),
          if (_hasText(draft.relationshipType))
            _DraftLine(label: 'Relacion', value: draft.relationshipType!),
          if (_hasText(draft.phone))
            _DraftLine(label: 'Telefono', value: draft.phone!),
          if (_hasText(draft.email))
            _DraftLine(label: 'Email', value: draft.email!),
          if (_hasText(draft.company) || _hasText(draft.jobTitle))
            _DraftLine(
              label: 'Trabajo',
              value: [draft.jobTitle, draft.company]
                  .whereType<String>()
                  .where((value) => value.trim().isNotEmpty)
                  .join(' - '),
            ),
          if (_hasText(draft.city))
            _DraftLine(label: 'Ciudad', value: draft.city!),
          if (_hasText(draft.contextNote))
            _DraftLine(label: 'Contexto', value: draft.contextNote!),
          if (draft.interests.isNotEmpty)
            _DraftLine(label: 'Intereses', value: draft.interests.join(', ')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final error = await context
                        .read<AssistantChatViewModel>()
                        .confirmCreateContact();
                    if (error != null) {
                      AppFeedbackService.showError(error);
                      return;
                    }
                    AppFeedbackService.showInfo('Contacto creado');
                  },
                  child: const Text('Crear contacto'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => context
                    .read<AssistantChatViewModel>()
                    .dismissPendingDraft(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftLine extends StatelessWidget {
  final String label;
  final String value;

  const _DraftLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final AssistantChatViewModel viewModel;

  const _Composer({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.inputController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  enabled: !viewModel.isSending,
                  onSubmitted: (_) => viewModel.sendCurrentMessage(),
                  decoration: const InputDecoration(
                    hintText:
                        'Pide algo como: crea un contacto llamado Marta que trabaja en...',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: viewModel.isSending
                      ? null
                      : viewModel.sendCurrentMessage,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
                      ),
                    ),
                    child: Center(
                      child: viewModel.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
