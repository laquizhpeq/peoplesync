# Serguiales

## Estado actual

En esta fase se ha consolidado el modulo de contactos alrededor del modelo nuevo `identity/relationship`.

Lo importante que ya queda hecho:

1. Se ha renovado la estetica compartida de la app.
   - Login y registro usan una identidad visual mas calida.
   - Home, layout general, app bar y navegacion inferior siguen el mismo lenguaje visual.
   - Se han reforzado widgets reutilizables en `lib/shared`.

2. Se ha corregido la navegacion principal.
   - Se anadio normalizacion de rutas para evitar problemas entre `/` y `/home`.
   - Se anadio soporte interno para rutas no presentes en el menu, como `/contacts/new`.

3. Se ha construido el modulo de contactos y conexiones.
   - Alta manual de contactos con formulario propio.
   - Pestana `Conexiones` con tarjetas visuales.
   - Fallback visual cuando el contacto no tiene foto.

4. Se ha separado el modelo de contacto en dos capas.
   - `identity`: datos base del contacto.
   - `relationship`: datos privados que solo conoce o mantiene el usuario.

5. Se ha preparado el flujo de perfil propio del usuario.
   - Onboarding obligatorio tras registro o cuando falta informacion basica.
   - Pantalla reutilizable para editar perfil desde la pestana `Perfil`.
   - El documento `users/{uid}` ya soporta identidad publica y redes sociales.

## Estructura aplicada

### Pages

- `lib/pages/contacts/contact_form_page.dart`
- `lib/pages/contacts/connections_page.dart`
- `lib/pages/profile/profile_page.dart`
- `lib/pages/profile/profile_editor_page.dart`

### Features

- `lib/features/contacts/contact_service.dart`
- `lib/features/contacts/contact_form_viewmodel.dart`
- `lib/features/contacts/connections_viewmodel.dart`
- `lib/features/contacts/models/contact_record.dart`
- `lib/features/profile/profile_service.dart`
- `lib/features/profile/profile_viewmodel.dart`
- `lib/features/profile/profile_editor_viewmodel.dart`
- `lib/features/profile/models/user_profile.dart`

### Shared

- `lib/shared/widgets/contacts/contact_manual_form.dart`
- `lib/shared/widgets/contacts/contact_form_header.dart`
- `lib/shared/widgets/contacts/contact_form_section_card.dart`
- `lib/shared/widgets/contacts/contact_multiline_field.dart`
- `lib/shared/widgets/contacts/contact_social_profile_card.dart`
- `lib/shared/widgets/contacts/connection_contact_card.dart`
- `lib/shared/widgets/profile/profile_form.dart`
- `lib/shared/widgets/profile/profile_social_profile_card.dart`

## Modelo de datos actual del contacto

Los contactos se guardan en:

`users/{uid}/contacts/{contactId}`

Cada usuario tiene su propia agenda privada.

### Estructura actual

```json
{
  "owner_uid": "uid_del_usuario",
  "source": "manual",
  "linked_user_uid": null,
  "device_contact_id": null,
  "imported_from_qr_id": null,
  "identity": {
    "display_name": "Ana Ruiz",
    "photo_url": null,
    "age": 29,
    "birthday": null,
    "city": "Madrid",
    "company": "PeopleSync Studio",
    "job_title": "Disenadora de producto",
    "bio": "Le gusta descubrir cafeterias y viajar.",
    "about": "Muy sociable en eventos pequenos.",
    "favorite_song": "Dreams - Fleetwood Mac",
    "email": "ana@email.com",
    "phone": "+34600111222",
    "social_profiles": [
      {
        "platform": "instagram",
        "value": "@anaruiz",
        "label": "Personal",
        "url": "https://instagram.com/anaruiz"
      }
    ]
  },
  "relationship": {
    "relationship_type": null,
    "context_note": "La conoci en un meetup de diseno.",
    "private_notes": null,
    "interests": ["cine", "viajes", "cafe"],
    "looking_for": ["amistad", "networking"],
    "personality_tags": ["creativa", "cercana", "curiosa"],
    "last_interaction_note": "Le interesa retomar contacto para un evento.",
    "last_interaction_at": null,
    "is_favorite": false,
    "is_archived": false,
    "custom_display_name": null
  },
  "created_at": "serverTimestamp",
  "updated_at": "serverTimestamp"
}
```

## Sentido de cada bloque

### Identity

Contiene la informacion base de la persona:

- nombre
- foto
- edad
- ciudad
- empresa
- cargo
- bio
- email
- telefono
- redes sociales

Este bloque esta pensado para ser compatible con:

- alta manual
- importacion desde contactos del movil
- importacion por QR
- contacto enlazado a usuario real

### Relationship

Contiene la informacion privada del usuario sobre esa persona:

- contexto de como os conocisteis
- intereses
- tags personales
- lo que representa esa relacion
- ultima nota o recuerdo
- favoritos o archivado

Este bloque no debe pisarse en futuras importaciones de identidad.

## Tipos de origen soportados

El modelo ya contempla estos origenes:

- `manual`
- `device_import`
- `linked_user`
- `qr_import`

## Redes sociales

Las redes sociales se guardan como una lista estructurada en `identity.social_profiles`.

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

## UI y capa de aplicacion

Ya no solo se guarda con el modelo nuevo. Tambien se ha alineado la capa de aplicacion:

- `ContactFormViewModel` construye ya un `ContactIdentity` y un `ContactRelationship`.
- `ContactService.createManualContact` recibe esos dos objetos, no una lista plana de parametros.
- `ConnectionContactCard` lee directamente de `contact.identity` y `contact.relationship`.
- El formulario manual separa visualmente:
  - `Identidad`
  - `Identidad extendida`
  - `Relacion privada`
  - `Contacto directo`
  - `Redes sociales`

## Firestore y menus

### Perfil del usuario

No hace falta crear una coleccion nueva para el perfil.

Se sigue usando:

`users/{uid}`

La app ya rellena y actualiza estos campos dentro del mismo documento:

```json
{
  "full_name": "Ana Ruiz",
  "email": "ana@email.com",
  "rol_id": "usuario",
  "photo_url": null,
  "city": "Madrid",
  "bio": "Diseno producto y me encantan los eventos pequenos.",
  "social_profiles": [
    {
      "platform": "instagram",
      "value": "@anaruiz",
      "label": "Personal",
      "url": "https://instagram.com/anaruiz"
    }
  ],
  "onboarding_completed": true,
  "created_at": "serverTimestamp",
  "updated_at": "serverTimestamp",
  "last_login": "serverTimestamp"
}
```

### Contactos

No hace falta crear una coleccion global de contactos.

Los contactos aparecen automaticamente al crear documentos en:

`users/{uid}/contacts/{contactId}`

### Menu de conexiones

Para que la pestana salga en la navegacion, se ha preparado la ruta:

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

En `users/{uid}` no hace falta guardar `connections` como menu. Solo hace falta que el usuario tenga su `rol_id`.

## Reglas Firestore

La idea aplicada es:

- el usuario solo puede leer y escribir su propio documento `users/{uid}`
- el usuario solo puede leer y escribir `users/{uid}/contacts/{contactId}`
- se valida `owner_uid` en la creacion y actualizacion

## Compatibilidad

`ContactRecord.fromMap` soporta dos formatos:

- el nuevo formato anidado con `identity` y `relationship`
- el formato plano antiguo

Esto permite leer contactos viejos sin romper la app mientras se termina la migracion.

## Onboarding y edicion de perfil

El flujo nuevo funciona asi:

1. El usuario se registra o hace login.
2. La app comprueba `users/{uid}`.
3. Si falta el documento o `onboarding_completed != true`, redirige a `/onboarding/profile`.
4. El usuario rellena:
   - nombre visible
   - ciudad
   - bio
   - foto por URL
   - redes sociales
5. Al guardar, se marca `onboarding_completed = true`.
6. Desde la pestana `Perfil`, el usuario puede volver a entrar en `Editar perfil` y cambiar esos datos cuando quiera.

Rutas nuevas relevantes:

- `/onboarding/profile`
- `/profile/edit`

Archivos principales de este flujo:

- `lib/routes/app_routes.dart`
- `lib/features/profile/profile_service.dart`
- `lib/features/profile/profile_editor_viewmodel.dart`
- `lib/pages/profile/profile_editor_page.dart`
- `lib/shared/widgets/profile/profile_form.dart`

## Siguiente paso recomendado

El siguiente trabajo logico seria uno de estos dos:

1. Crear vista detalle y edicion de conexion usando ya el modelo anidado.
2. Preparar el flujo de importacion desde el movil o por QR reutilizando `identity` y manteniendo `relationship` intacto.
3. Si el onboarding queda estable, refinar subida real de foto en vez de URL manual.
