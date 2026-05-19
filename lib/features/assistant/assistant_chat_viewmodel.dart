import 'package:flutter/material.dart';
import 'package:peoplesync/core/services/app_error_mapper.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/assistant/assistant_service.dart';
import 'package:peoplesync/features/assistant/models/assistant_chat_models.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';

class AssistantChatViewModel extends ChangeNotifier {
  final AssistantService assistantService;
  final ContactService contactService;

  final TextEditingController inputController = TextEditingController();
  final List<AssistantChatMessage> _messages = [];

  bool _isSending = false;
  String? _errorMessage;
  AssistantCreateContactDraft? _pendingContactDraft;
  String? _latestModel;
  AssistantConversationMode _conversationMode =
      AssistantConversationMode.normal;

  List<AssistantChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  AssistantCreateContactDraft? get pendingContactDraft => _pendingContactDraft;
  String? get latestModel => _latestModel;
  AssistantConversationMode get conversationMode => _conversationMode;

  AssistantChatViewModel({
    required this.assistantService,
    required this.contactService,
  }) {
    _messages.add(
      AssistantChatMessage(
        id: _nextId(),
        role: AssistantChatRole.assistant,
        text:
            'Soy Chispa. Estoy aqui para ayudarte a cuidar y hacer crecer tus relaciones. Si quieres, tambien puedo ayudarte a crear un contacto nuevo paso a paso.',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> sendCurrentMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    inputController.clear();
    _pendingContactDraft = null;
    _errorMessage = null;
    _isSending = true;

    _messages.add(
      AssistantChatMessage(
        id: _nextId(),
        role: AssistantChatRole.user,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();

    try {
      final result = await assistantService.sendMessage(
        _messages,
        _conversationMode,
      );
      _latestModel = result.model;
      _conversationMode = result.conversationMode;
      _messages.add(
        AssistantChatMessage(
          id: _nextId(),
          role: AssistantChatRole.assistant,
          text: result.reply,
          createdAt: DateTime.now(),
        ),
      );

      if (result.toolCall != null &&
          _conversationMode == AssistantConversationMode.readyToCreate) {
        _pendingContactDraft = _buildDraftFromToolCall(result.toolCall!);
      }

      AppLogger.info('Turno del asistente completado', scope: 'assistant');
    } catch (error, stackTrace) {
      _errorMessage = error is AssistantServiceException
          ? error.message
          : AppErrorMapper.toUserMessage(
              error,
              fallback:
                  'Chispa no pudo responder ahora mismo. Vuelve a intentarlo.',
            );
      AppLogger.error(
        'Fallo el asistente conversacional',
        scope: 'assistant',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<String?> confirmCreateContact() async {
    final draft = _pendingContactDraft;
    if (draft == null) return 'No hay ninguna accion pendiente.';

    try {
      _isSending = true;
      _errorMessage = null;
      notifyListeners();

      await contactService.createManualContact(
        identity: draft.toIdentity(),
        relationship: draft.toRelationship(),
      );

      _messages.add(
        AssistantChatMessage(
          id: _nextId(),
          role: AssistantChatRole.system,
          text: 'Contacto creado: ${draft.displayName}',
          createdAt: DateTime.now(),
        ),
      );
      _conversationMode = AssistantConversationMode.normal;
      _pendingContactDraft = null;
      return null;
    } catch (error, stackTrace) {
      _errorMessage = AppErrorMapper.toUserMessage(
        error,
        fallback:
            'No se pudo crear el contacto. Revisa los datos y prueba otra vez.',
      );
      AppLogger.error(
        'No se pudo ejecutar create_contact',
        scope: 'assistant',
        error: error,
        stackTrace: stackTrace,
      );
      return _errorMessage;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void dismissPendingDraft() {
    _pendingContactDraft = null;
    _conversationMode = AssistantConversationMode.normal;
    notifyListeners();
  }

  AssistantCreateContactDraft _buildDraftFromToolCall(AssistantToolCall tool) {
    if (tool.name != 'create_contact') {
      throw AssistantServiceException(
        'La herramienta ${tool.name} no esta soportada en esta version.',
      );
    }

    return assistantService.buildCreateContactDraft(tool.arguments);
  }

  String _nextId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
