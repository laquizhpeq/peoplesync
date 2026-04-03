# Serguiales

## Estado actual

En esta sesión se ha avanzado en cuatro bloques principales:                                                                                                              

1. Se ha renovado la estética compartida de la app.
   - Login y registro usan ya una identidad visual más cálida.
   - Home, layout general, app bar y navegación inferior siguen el mismo lenguaje visual.
   - Se han reforzado widgets reutilizables en `lib/shared`.

2. Se ha corregido la navegación principal.
   - Se añadió normalización de rutas para evitar problemas entre `/` y `/home`.
   - Se añadió soporte interno para rutas no presentes en el menú, como `contacts/new`.

3. Se ha construido el nuevo módulo de contactos.
   - Alta manual de contactos con formulario completo.
   - Separación clara entre:
     - `pages`
     - `features`
     - `shared`
   - El formulario ya no está embebido en la página, sino dividido en widgets reutilizables y un `ViewModel`.

4. Se ha creado la pestaña `Conexiones`.
   - Nueva ruta `/connections`.
   - Listado de contactos como tarjetas visuales.
   - Se da protagonismo a la foto del contacto.
   - Si no hay foto, se muestra un fallback visual.

## Estructura aplicada

### Pages

- `lib/pages/contacts/contact_form_page.dart`
- `lib/pages/contacts/connections_page.dart`

### Features

- `lib/features/contacts/contact_service.dart`
- `lib/features/contacts/contact_form_viewmodel.dart`
- `lib/features/contacts/connections_viewmodel.dart`
- `lib/features/contacts/models/contact_record.dart`

### Shared

- `lib/shared/widgets/contacts/contact_manual_form.dart`
- `lib/shared/widgets/contacts/contact_form_header.dart`
- `lib/shared/widgets/contacts/contact_form_section_card.dart`
- `lib/shared/widgets/contacts/contact_multiline_field.dart`
- `lib/shared/widgets/contacts/contact_social_profile_card.dart`
- `lib/shared/widgets/contacts/connection_contact_card.dart`

## Modelo de datos actual del contacto

Los contactos se guardan en:

`users/{uid}/contacts/{contactId}`

Esto significa que cada usuario tiene su propia agenda privada.

### Campos principales

```json
{
  "owner_uid": "uid_del_usuario",
  "source": "manual",
  "display_name": "Ana Ruiz",
  "linked_user_uid": null,
  "photo_url": null,
  "age": 29,
  "birthday": null,
  "city": "Madrid",
  "company": "PeopleSync Studio",
  "job_title": "Diseñadora de producto",
  "bio": "Le gusta descubrir cafeterías y viajar.",
  "about": "Muy sociable en eventos pequeños.",
  "favorite_song": "Dreams - Fleetwood Mac",
  "email": "ana@email.com",
  "phone": "+34600111222",
  "interests": ["cine", "viajes", "cafe"],
  "looking_for": ["amistad", "networking"],
  "personality_tags": ["creativa", "cercana", "curiosa"],
  "relationship_context": "La conocí en un meetup de diseño.",
  "last_interaction_note": "Le interesa retomar contacto para un evento.",
  "social_profiles": [
    {
      "platform": "instagram",
      "value": "@anaruiz",
      "label": "Personal",
      "url": "https://instagram.com/anaruiz"
    },
    {
      "platform": "linkedin",
      "value": "Ana Ruiz",
      "label": "Trabajo",
      "url": "https://linkedin.com/in/anaruiz"
    }
  ],
  "imported_from_qr_id": null,
  "created_at": "serverTimestamp",
  "updated_at": "serverTimestamp",
  "last_interaction_at": null
}
```

## Tipos de origen soportados

El modelo ya contempla estos orígenes:

- `manual`
- `linked_user`
- `qr_import`

Esto se añadió para que el modelo no haya que rehacerlo cuando entre el flujo QR.

## Redes sociales

Las redes sociales se guardan como una lista estructurada en `social_profiles`.

Cada elemento tiene:

```json
{
  "platform": "instagram",
  "value": "@usuario",
  "label": "Personal",
  "url": "https://..."
}
```

Plataformas contempladas ahora mismo:

- Instagram
- X
- TikTok
- LinkedIn
- Facebook
- Telegram
- WhatsApp
- YouTube
- Twitch
- Snapchat
- Web personal
- Otra

## Firestore y menús

### Contactos

No hace falta crear una colección global de contactos.

Los contactos aparecen automáticamente al crear documentos en:

`users/{uid}/contacts/{contactId}`

### Menú de conexiones

Para que la pestaña salga en la navegación, se ha preparado la ruta:

`/connections`

Documento recomendado en `menus/connections`:

```json
{
  "title": "Conexiones",
  "route": "/connections",
  "icon": "groups_rounded",
  "order": 2
}
```

Y el rol debe incluir:

```json
{
  "menus": ["home", "connections", "profile"]
}
```

En `users/{uid}` no hace falta guardar `connections` como menú. Solo hace falta que el usuario tenga su `rol_id`.

## Reglas Firestore

Se ajustaron reglas para permitir que cada usuario cree y gestione sus propios contactos.

La idea aplicada es:

- el usuario solo puede leer/escribir su propio documento `users/{uid}`
- el usuario solo puede leer/escribir `users/{uid}/contacts/{contactId}`
- se valida `owner_uid` en la creación y actualización

## Cosas a revisar

1. Publicar las reglas Firestore en remoto.
   - Si no se publican, seguirán apareciendo errores de permisos aunque el archivo local esté correcto.

2. Verificar visualmente `Conexiones` en web.
   - Hubo un ajuste en la tarjeta de contacto para evitar errores de layout e hit testing.
   - Si vuelve a fallar, revisar el primer stack trace completo en consola.

3. Confirmar que los documentos existentes tienen campos mínimos.
   - `display_name`
   - `owner_uid`
   - opcionalmente `updated_at` y `created_at`

4. Revisar si el siguiente paso será:
   - detalle de conexión
   - edición de conexión
   - importación por QR

## Decisiones de producto ya tomadas

- La app no tendrá mensajería interna.
- La entidad importante no es el chat, sino la ficha relacional.
- El contacto es una ficha rica, privada y editable por usuario.
- La agenda privada de cada usuario vive en subcolecciones, no en una colección global.

## Recomendación para continuar

El siguiente trabajo lógico sería uno de estos dos:

1. Crear vista detalle/edición de conexión.
2. Diseñar el flujo de importación por QR reutilizando el modelo actual.
