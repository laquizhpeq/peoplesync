import 'package:flutter/foundation.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'package:peoplesync/features/ai/ai_service.dart';
import 'package:peoplesync/features/ai/models/contact_ai_message_suggestion.dart';
import 'package:peoplesync/features/ai/models/contact_ai_suggested_topic.dart';
import 'package:peoplesync/features/contacts/models/contact_ai_summary.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

enum ContactAiFeatureType { summary, suggestedTopic, message }

class ContactAiViewModel extends ChangeNotifier {
  final AiService aiService;

  bool _isGenerating = false;
  String? _errorMessage;
  ContactAiSummary? _latestSummary;
  ContactAiSuggestedTopic? _latestSuggestedTopic;
  ContactAiMessageSuggestion? _latestMessageSuggestion;
  ContactAiFeatureType? _activeFeature;
  String? _latestModel;
  DateTime? _latestGeneratedAt;

  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  ContactAiSummary? get latestSummary => _latestSummary;
  ContactAiSuggestedTopic? get latestSuggestedTopic => _latestSuggestedTopic;
  ContactAiMessageSuggestion? get latestMessageSuggestion =>
      _latestMessageSuggestion;
  ContactAiFeatureType? get activeFeature => _activeFeature;
  String? get latestModel => _latestModel;
  DateTime? get latestGeneratedAt => _latestGeneratedAt;

  ContactAiViewModel({required this.aiService});

  bool hasEnoughContext(ContactRecord contact) {
    return aiService.hasEnoughContext(contact);
  }

  Future<ContactAiSummary?> generateRelationshipSummary(
    ContactRecord contact,
  ) async {
    try {
      _beginGeneration();
      final result = await aiService.generateRelationshipSummary(contact);
      _clearResults();
      _latestSummary = result.summary;
      _activeFeature = ContactAiFeatureType.summary;
      _latestModel = result.model;
      _latestGeneratedAt = DateTime.now();
      AppLogger.info(
        'Resumen IA generado para el contacto ${contact.id}',
        scope: 'ai',
      );
      return result.summary;
    } catch (error, stackTrace) {
      _errorMessage = error is AiServiceException ? error.message : '$error';
      AppLogger.error(
        'No se pudo generar el resumen IA',
        scope: 'ai',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    } finally {
      _endGeneration();
    }
  }

  Future<ContactAiSuggestedTopic?> generateSuggestedTopic(
    ContactRecord contact,
  ) async {
    try {
      _beginGeneration();
      final result = await aiService.generateSuggestedTopic(contact);
      _clearResults();
      _latestSuggestedTopic = result.suggestion;
      _activeFeature = ContactAiFeatureType.suggestedTopic;
      _latestModel = result.model;
      _latestGeneratedAt = DateTime.now();
      AppLogger.info(
        'Tema sugerido IA generado para el contacto ${contact.id}',
        scope: 'ai',
      );
      return result.suggestion;
    } catch (error, stackTrace) {
      _errorMessage = error is AiServiceException ? error.message : '$error';
      AppLogger.error(
        'No se pudo generar el tema sugerido IA',
        scope: 'ai',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    } finally {
      _endGeneration();
    }
  }

  Future<ContactAiMessageSuggestion?> generateMessageSuggestion(
    ContactRecord contact,
  ) async {
    try {
      _beginGeneration();
      final result = await aiService.generateMessageSuggestion(contact);
      _clearResults();
      _latestMessageSuggestion = result.suggestion;
      _activeFeature = ContactAiFeatureType.message;
      _latestModel = result.model;
      _latestGeneratedAt = DateTime.now();
      AppLogger.info(
        'Mensaje IA generado para el contacto ${contact.id}',
        scope: 'ai',
      );
      return result.suggestion;
    } catch (error, stackTrace) {
      _errorMessage = error is AiServiceException ? error.message : '$error';
      AppLogger.error(
        'No se pudo generar el mensaje IA',
        scope: 'ai',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    } finally {
      _endGeneration();
    }
  }

  void clearTransientState() {
    _clearResults();
    notifyListeners();
  }

  void _beginGeneration() {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _endGeneration() {
    _isGenerating = false;
    notifyListeners();
  }

  void _clearResults() {
    _latestSummary = null;
    _latestSuggestedTopic = null;
    _latestMessageSuggestion = null;
    _activeFeature = null;
    _latestModel = null;
    _latestGeneratedAt = null;
  }
}
