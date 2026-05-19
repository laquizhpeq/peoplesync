import 'package:flutter/services.dart';

class AppErrorMapper {
  static String toUserMessage(
    Object error, {
    String fallback =
        'Ha ocurrido un problema. Vuelve a intentarlo en unos segundos.',
  }) {
    final raw = _normalized(error);
    final lower = raw.toLowerCase();

    if (error is MissingPluginException ||
        lower.contains('missingpluginexception')) {
      return 'Esta funcion no esta disponible ahora mismo. Cierra y vuelve a abrir la app.';
    }

    if (error is PlatformException) {
      if (error.code == 'already_active' || lower.contains('already_active')) {
        return 'La accion ya se esta abriendo. Espera un momento y vuelve a intentarlo.';
      }
      if (lower.contains('channel-error')) {
        return 'Esta funcion no se pudo iniciar correctamente. Reinicia la app e intentalo de nuevo.';
      }
    }

    if (lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('timed out') ||
        lower.contains('timeout')) {
      return 'No se pudo conectar. Revisa tu conexion y vuelve a intentarlo.';
    }

    if (lower.contains('permission-denied') ||
        lower.contains('permission denied') ||
        lower.contains('insufficient permissions')) {
      return 'No tienes permiso para hacer eso con esta cuenta.';
    }

    if (lower.contains('user-not-found') ||
        lower.contains('wrong-password') ||
        lower.contains('invalid-credential') ||
        lower.contains('invalid login credentials')) {
      return 'El email o la contrasena no son correctos.';
    }

    if (lower.contains('email-already-in-use')) {
      return 'Ese email ya esta en uso. Prueba con otro o inicia sesion.';
    }

    if (lower.contains('too-many-requests')) {
      return 'Has hecho demasiados intentos. Espera un momento antes de volver a probar.';
    }

    if (lower.contains('no hay un usuario autenticado')) {
      return 'Tu sesion ya no esta disponible. Cierra y vuelve a entrar.';
    }

    if (lower.contains('supabase no esta configurado')) {
      return 'La subida de imagenes no esta disponible ahora mismo.';
    }

    if (lower.contains('lateinitializationerror')) {
      return 'Esta funcion no se pudo preparar correctamente. Reinicia la app y vuelve a intentarlo.';
    }

    if (lower.startsWith('exception: ')) {
      final cleaned = raw.substring(11).trim();
      return cleaned.isEmpty ? fallback : cleaned;
    }

    return raw.trim().isEmpty ? fallback : raw.trim();
  }

  static String toShortReason(
    Object error, {
    String fallback = 'Vuelve a intentarlo o reinicia la app.',
  }) {
    final message = toUserMessage(error, fallback: fallback).trim();
    if (message.length <= 120) return message;
    return '${message.substring(0, 117).trim()}...';
  }

  static String _normalized(Object error) {
    final raw = error.toString().replaceAll('\n', ' ').replaceAll('\r', ' ');
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
