import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/assistant/models/assistant_chat_models.dart';
import 'package:peoplesync/features/contacts/models/relationship_type_preset.dart';

class AssistantServiceException implements Exception {
  final String message;
  final Object? cause;

  const AssistantServiceException(this.message, {this.cause});

  @override
  String toString() =>
      'AssistantServiceException: $message${cause != null ? ' (causa: $cause)' : ''}';
}

class AssistantService {
  static final Uri _groqUri = Uri.parse(
    'https://api.groq.com/openai/v1/chat/completions',
  );

  Future<AssistantTurnResult> sendMessage(
    List<AssistantChatMessage> messages,
    AssistantConversationMode currentMode,
  ) async {
    if (kIsWeb) {
      throw const AssistantServiceException(
        'El asistente no esta disponible en web sin backend intermedio.',
      );
    }

    final apiKey = EnvConfig.groqApiKey;
    if (apiKey.isEmpty) {
      throw const AssistantServiceException('Falta GROQ_API_KEY en .env.');
    }

    final response = await _performRequest(
      apiKey: apiKey,
      body: jsonEncode({
        'model': EnvConfig.groqModel,
        'temperature': 0.35,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'system',
            'content':
                'Estado interno actual de la conversacion: ${_conversationModeValue(currentMode)}.',
          },
          ...messages.map(_mapMessage),
        ],
      }),
    );

    return _parseResponse(response);
  }

  AssistantCreateContactDraft buildCreateContactDraft(
    Map<String, dynamic> arguments,
  ) {
    final displayName = (arguments['display_name'] as String? ?? '').trim();
    if (displayName.isEmpty) {
      throw const AssistantServiceException(
        'La accion de crear contacto llego sin nombre visible.',
      );
    }

    return AssistantCreateContactDraft(
      displayName: displayName,
      phone: _readNullableString(arguments, 'phone'),
      email: _readNullableString(arguments, 'email'),
      city: _readNullableString(arguments, 'city'),
      company: _readNullableString(arguments, 'company'),
      jobTitle: _readNullableString(arguments, 'job_title'),
      bio: _readNullableString(arguments, 'bio'),
      about: _readNullableString(arguments, 'about'),
      relationshipType: _normalizeRelationshipType(
        _readNullableString(arguments, 'relationship_type'),
      ),
      interests: _readStringList(arguments, 'interests'),
      lookingFor: _readStringList(arguments, 'looking_for'),
      personalityTags: _readStringList(arguments, 'personality_tags'),
      contextNote: _readNullableString(arguments, 'context_note'),
      lastInteractionNote: _readNullableString(
        arguments,
        'last_interaction_note',
      ),
    );
  }

  Future<http.Response> _performRequest({
    required String apiKey,
    required String body,
  }) async {
    AppLogger.info('Enviando turno al asistente', scope: 'assistant');

    try {
      return await http
          .post(
            _groqUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 25));
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo conectar con Groq para el asistente',
        scope: 'assistant',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AssistantServiceException(
        'No se pudo conectar con Groq. Revisa red o API key.',
      );
    }
  }

  AssistantTurnResult _parseResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLogger.error(
        'Groq devolvio error en el asistente',
        scope: 'assistant',
        error: response.body,
      );
      throw AssistantServiceException(
        'Groq no pudo responder ahora mismo (${response.statusCode}).',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) {
        throw const AssistantServiceException(
          'La respuesta del asistente llego vacia.',
        );
      }

      final message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>? ??
          const {};
      final content = (message['content'] as String? ?? '').trim();
      final cleaned = _cleanJsonPayload(content);
      final resultMap = jsonDecode(cleaned);
      if (resultMap is! Map<String, dynamic>) {
        throw const AssistantServiceException(
          'La respuesta del asistente no tiene el formato esperado.',
        );
      }

      final reply = (resultMap['reply'] as String? ?? '').trim();
      final conversationMode = _conversationModeFromValue(
        resultMap['conversation_mode'] as String?,
      );
      final toolCallMap = resultMap['tool_call'];
      AssistantToolCall? toolCall;

      if (toolCallMap is Map<String, dynamic>) {
        final name = (toolCallMap['name'] as String? ?? '').trim();
        final arguments = toolCallMap['arguments'];
        if (name.isNotEmpty && arguments is Map<String, dynamic>) {
          toolCall = AssistantToolCall(name: name, arguments: arguments);
        } else if (name.isNotEmpty && arguments is Map) {
          toolCall = AssistantToolCall(
            name: name,
            arguments: Map<String, dynamic>.from(arguments),
          );
        }
      } else if (toolCallMap is Map) {
        final rawMap = Map<String, dynamic>.from(toolCallMap);
        final name = (rawMap['name'] as String? ?? '').trim();
        final arguments = rawMap['arguments'];
        if (name.isNotEmpty && arguments is Map) {
          toolCall = AssistantToolCall(
            name: name,
            arguments: Map<String, dynamic>.from(arguments),
          );
        }
      }

      return AssistantTurnResult(
        reply: reply.isEmpty
            ? 'He procesado tu mensaje.'
            : reply,
        toolCall: toolCall,
        model: EnvConfig.groqModel,
        conversationMode: conversationMode,
      );
    } on AssistantServiceException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo interpretar la respuesta del asistente',
        scope: 'assistant',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AssistantServiceException(
        'La respuesta del asistente llego mal formada.',
      );
    }
  }

  Map<String, String> _mapMessage(AssistantChatMessage message) {
    return {
      'role': switch (message.role) {
        AssistantChatRole.user => 'user',
        AssistantChatRole.assistant => 'assistant',
        AssistantChatRole.system => 'assistant',
      },
      'content': message.text,
    };
  }

  AssistantConversationMode _conversationModeFromValue(String? value) {
    return switch ((value ?? '').trim()) {
      'awaiting_create_confirmation' =>
        AssistantConversationMode.awaitingCreateConfirmation,
      'collecting_contact_data' =>
        AssistantConversationMode.collectingContactData,
      'ready_to_create' => AssistantConversationMode.readyToCreate,
      _ => AssistantConversationMode.normal,
    };
  }

  String _conversationModeValue(AssistantConversationMode mode) {
    return switch (mode) {
      AssistantConversationMode.normal => 'normal',
      AssistantConversationMode.awaitingCreateConfirmation =>
        'awaiting_create_confirmation',
      AssistantConversationMode.collectingContactData =>
        'collecting_contact_data',
      AssistantConversationMode.readyToCreate => 'ready_to_create',
    };
  }

  String? _readNullableString(Map<String, dynamic> map, String key) {
    final value = map[key] as String?;
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _readStringList(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String? _normalizeRelationshipType(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;
    final preset = relationshipPresetFromText(rawValue);
    return preset?.key;
  }

  String _cleanJsonPayload(String rawContent) {
    var content = rawContent.trim();
    if (content.startsWith('```json')) {
      content = content.substring(7).trim();
    } else if (content.startsWith('```')) {
      content = content.substring(3).trim();
    }

    if (content.endsWith('```')) {
      content = content.substring(0, content.length - 3).trim();
    }

    return content;
  }

  static const String _systemPrompt = '''
Eres Chispa, el asistente conversacional de PeopleSync.

Tu trabajo es ayudar al usuario a gestionar, mejorar y hacer crecer sus relaciones personales y profesionales.
Hablas de forma natural, clara y humana, como alguien experto en relaciones.

Debes responder siempre con JSON valido con esta forma:
{
  "reply": "texto breve y util para el usuario",
  "conversation_mode": "normal | awaiting_create_confirmation | collecting_contact_data | ready_to_create",
  "tool_call": null
}

O, si tienes datos suficientes para crear un contacto:
{
  "reply": "texto breve explicando lo que has entendido",
  "conversation_mode": "ready_to_create",
  "tool_call": {
    "name": "create_contact",
    "arguments": {
      "display_name": "Nombre visible obligatorio",
      "phone": "opcional",
      "email": "opcional",
      "city": "opcional",
      "company": "opcional",
      "job_title": "opcional",
      "bio": "opcional",
      "about": "opcional",
      "relationship_type": "networking | amistad | clientes | colaboradores | familia | seguir cultivando",
      "interests": ["opcional"],
      "looking_for": ["opcional"],
      "personality_tags": ["opcional"],
      "context_note": "opcional",
      "last_interaction_note": "opcional"
    }
  }
}

Reglas:
- No inventes datos.
- No propongas crear contacto si el usuario no lo ha pedido de forma explicita.
- Si el usuario pide crear o anadir un contacto, primero confirma si quiere hacerlo ahora. En ese caso usa conversation_mode = awaiting_create_confirmation.
- Solo cuando el usuario confirme claramente que si, pasa a pedir los datos que faltan en texto plano comprensible. En ese caso usa conversation_mode = collecting_contact_data.
- Antes de emitir tool_call deben cumplirse estas condiciones: el usuario pidio crear contacto, luego confirmo que quiere hacerlo, y ya diste o pediste los datos necesarios.
- Si falta el nombre visible, no propongas tool_call.
- Cuando pidas datos, dilo en lenguaje natural. No listes claves tecnicas ni hables de JSON.
- Si el usuario no esta pidiendo crear un contacto, limita la respuesta a texto.
- Se breve, natural, concreta y util.
- No devuelvas markdown ni explicaciones fuera del JSON.
''';
}
