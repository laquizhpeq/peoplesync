import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/ai/models/contact_ai_message_suggestion.dart';
import 'package:peoplesync/features/ai/models/contact_ai_suggested_topic.dart';
import 'package:peoplesync/features/contacts/models/contact_ai_summary.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class AiServiceException implements Exception {
  final String message;
  final Object? cause;

  const AiServiceException(this.message, {this.cause});

  @override
  String toString() =>
      'AiServiceException: $message${cause != null ? ' (causa: $cause)' : ''}';
}

class AiSummaryResult {
  final ContactAiSummary summary;
  final String model;

  const AiSummaryResult({required this.summary, required this.model});
}

class AiSuggestedTopicResult {
  final ContactAiSuggestedTopic suggestion;
  final String model;

  const AiSuggestedTopicResult({
    required this.suggestion,
    required this.model,
  });
}

class AiMessageSuggestionResult {
  final ContactAiMessageSuggestion suggestion;
  final String model;

  const AiMessageSuggestionResult({
    required this.suggestion,
    required this.model,
  });
}

class AiService {
  static final Uri _groqUri = Uri.parse(
    'https://api.groq.com/openai/v1/chat/completions',
  );

  bool hasEnoughContext(ContactRecord contact) {
    return _buildContactContext(contact).isNotEmpty;
  }

  Future<AiSummaryResult> generateRelationshipSummary(
    ContactRecord contact,
  ) async {
    final contactContext = _buildContactContext(contact);
    final resultMap = await _performJsonRequest(
      contactId: contact.id,
      scopeLabel: 'resumen IA',
      systemPrompt:
          'Eres un asistente que resume relaciones personales de forma breve, concreta y util. '
          'Devuelves solo JSON valido con estas claves exactas: '
          'who_is, what_connects_you, what_to_remember, next_step. '
          'Cada valor debe ser una frase corta o dos como maximo. '
          'No inventes datos ni rellenes huecos con fantasia.',
      userPrompt: _buildSummaryPrompt(contactContext),
    );

    final summary = ContactAiSummary.fromMap(resultMap);
    if (!summary.hasContent) {
      throw const AiServiceException(
        'La respuesta del proveedor no contiene informacion util.',
      );
    }

    return AiSummaryResult(summary: summary, model: EnvConfig.groqModel);
  }

  Future<AiSuggestedTopicResult> generateSuggestedTopic(
    ContactRecord contact,
  ) async {
    final contactContext = _buildContactContext(contact);
    final resultMap = await _performJsonRequest(
      contactId: contact.id,
      scopeLabel: 'tema sugerido',
      systemPrompt:
          'Eres un asistente que propone temas de conversacion para retomar relaciones personales. '
          'Debes devolver solo JSON valido con estas claves exactas: '
          'opening_angle, ice_breaker, conversation_topics. '
          'conversation_topics debe ser un array de 3 a 5 temas cortos. '
          'No inventes datos ni fuerces confianza artificial.',
      userPrompt: _buildSuggestedTopicPrompt(contactContext),
    );

    final suggestion = ContactAiSuggestedTopic.fromMap(resultMap);
    if (!suggestion.hasContent) {
      throw const AiServiceException(
        'La respuesta IA no devolvio un tema de conversacion util.',
      );
    }

    return AiSuggestedTopicResult(
      suggestion: suggestion,
      model: EnvConfig.groqModel,
    );
  }

  Future<AiMessageSuggestionResult> generateMessageSuggestion(
    ContactRecord contact,
  ) async {
    final contactContext = _buildContactContext(contact);
    final resultMap = await _performJsonRequest(
      contactId: contact.id,
      scopeLabel: 'mensaje IA',
      systemPrompt:
          'Eres un asistente que redacta mensajes breves y naturales para retomar relaciones. '
          'Debes devolver solo JSON valido con estas claves exactas: '
          'intent, message. '
          'message debe sonar humano, breve, concreto y listo para enviar por WhatsApp o mensaje directo. '
          'No inventes hechos no presentes en el contexto.',
      userPrompt: _buildMessagePrompt(contactContext),
    );

    final suggestion = ContactAiMessageSuggestion.fromMap(resultMap);
    if (!suggestion.hasContent) {
      throw const AiServiceException(
        'La respuesta IA no devolvio un mensaje util.',
      );
    }

    return AiMessageSuggestionResult(
      suggestion: suggestion,
      model: EnvConfig.groqModel,
    );
  }

  Map<String, dynamic> _buildContactContext(ContactRecord contact) {
    return {
      'id': contact.id,
      'owner_uid': contact.ownerUid,
      'source': contact.source.name,
      'linked_user_uid': contact.linkedUserUid,
      'device_contact_id': contact.deviceContactId,
      'imported_from_qr_id': contact.importedFromQrId,
      'created_at': contact.createdAt?.toIso8601String(),
      'updated_at': contact.updatedAt?.toIso8601String(),
      'identity': {
        'display_name': contact.identity.displayName,
        'photo_url': contact.identity.photoUrl,
        'age': contact.identity.age,
        'birthday': contact.identity.birthday?.toIso8601String(),
        'city': contact.identity.city,
        'company': contact.identity.company,
        'job_title': contact.identity.jobTitle,
        'bio': contact.identity.bio,
        'about': contact.identity.about,
        'favorite_song': contact.identity.favoriteSong,
        'email': contact.identity.email,
        'phone': contact.identity.phone,
        'social_profiles': contact.identity.socialProfiles
            .map(
              (profile) => {
                'platform': socialPlatformValue(profile.platform),
                'value': profile.value,
                'label': profile.label,
                'url': profile.url,
              },
            )
            .toList(),
      },
      'relationship': {
        'relationship_type': contact.relationship.relationshipType,
        'context_note': contact.relationship.contextNote,
        'private_notes': contact.relationship.privateNotes,
        'interests': contact.relationship.interests,
        'looking_for': contact.relationship.lookingFor,
        'personality_tags': contact.relationship.personalityTags,
        'last_interaction_note': contact.relationship.lastInteractionNote,
        'last_interaction_at': contact.relationship.lastInteractionAt
            ?.toIso8601String(),
        'is_favorite': contact.relationship.isFavorite,
        'wants_to_strengthen_relationship': contact
            .relationship
            .wantsToStrengthenRelationship,
        'is_archived': contact.relationship.isArchived,
        'custom_display_name': contact.relationship.customDisplayName,
        'ai_summary': contact.relationship.aiSummary?.toMap(),
        'ai_summary_updated_at': contact.relationship.aiSummaryUpdatedAt
            ?.toIso8601String(),
        'ai_summary_model': contact.relationship.aiSummaryModel,
      },
    };
  }

  Future<Map<String, dynamic>> _performJsonRequest({
    required String contactId,
    required String scopeLabel,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (kIsWeb) {
      throw const AiServiceException(
        'Funciones IA directas desde web no son fiables sin backend intermedio. Usa app movil/escritorio o monta un proxy.',
      );
    }

    final apiKey = EnvConfig.groqApiKey;
    if (apiKey.isEmpty) {
      throw const AiServiceException('Falta GROQ_API_KEY en el archivo .env.');
    }

    final model = EnvConfig.groqModel;
    AppLogger.info(
      'Generando $scopeLabel para el contacto $contactId',
      scope: 'ai',
    );

    http.Response response;
    try {
      response = await http
          .post(
            _groqUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'temperature': 0.45,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
            }),
          )
          .timeout(const Duration(seconds: 25));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Fallo la llamada HTTP a Groq',
        scope: 'ai',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AiServiceException(
        'No se pudo conectar con Groq. Revisa red, API key o usa un backend intermedio.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLogger.error(
        'Groq devolvio un error al generar una funcion IA',
        scope: 'ai',
        error: response.body,
      );
      throw AiServiceException(
        'Groq no pudo generar la respuesta ahora mismo (${response.statusCode}).',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) {
        throw const AiServiceException(
          'La respuesta del proveedor llego vacia.',
        );
      }

      final message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>? ??
          const {};
      final content = (message['content'] as String? ?? '').trim();
      final resultMap = jsonDecode(_cleanJsonPayload(content));
      if (resultMap is! Map<String, dynamic>) {
        throw const AiServiceException(
          'La respuesta del proveedor no tiene el formato esperado.',
        );
      }
      return resultMap;
    } on AiServiceException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo interpretar la respuesta de Groq',
        scope: 'ai',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AiServiceException(
        'La respuesta IA llego mal formada. Intentalo otra vez.',
      );
    }
  }

  String _buildSummaryPrompt(Map<String, dynamic> contactContext) {
    final jsonContext = const JsonEncoder.withIndent('  ').convert(
      contactContext,
    );

    return '''
Genera un resumen de mi relacion con este contacto.

Debes usar siempre el modelo completo del contacto que te paso, no solo algunos campos.
Debes resumir solo con el contexto disponible, sin inventar.
Si algo no esta claro, se breve y conservador.

Modelo completo del contacto (JSON):
$jsonContext

Devuelve solo JSON valido con estas claves:
{
  "who_is": "...",
  "what_connects_you": "...",
  "what_to_remember": "...",
  "next_step": "..."
}
''';
  }

  String _buildSuggestedTopicPrompt(Map<String, dynamic> contactContext) {
    final jsonContext = const JsonEncoder.withIndent('  ').convert(
      contactContext,
    );

    return '''
Sugiere una conversacion o enfoque para llamar o escribir a este contacto.

Debes usar siempre el modelo completo del contacto que te paso.
Tu objetivo es ayudar a retomar la relacion con naturalidad, sin sonar forzado.

Modelo completo del contacto (JSON):
$jsonContext

Devuelve solo JSON valido con estas claves:
{
  "opening_angle": "...",
  "ice_breaker": "...",
  "conversation_topics": ["...", "...", "..."]
}
''';
  }

  String _buildMessagePrompt(Map<String, dynamic> contactContext) {
    final jsonContext = const JsonEncoder.withIndent('  ').convert(
      contactContext,
    );

    return '''
Redacta un mensaje breve para escribir a este contacto.

Debes usar siempre el modelo completo del contacto que te paso.
El mensaje debe servir para WhatsApp o mensaje directo.
Debe sonar natural, cercano y util segun el contexto disponible.

Modelo completo del contacto (JSON):
$jsonContext

Devuelve solo JSON valido con estas claves:
{
  "intent": "...",
  "message": "..."
}
''';
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

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
