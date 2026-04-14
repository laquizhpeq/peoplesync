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

## Subida de fotos a Supabase Storage

La app ya sube fotos tanto de contactos como de perfil a Supabase Storage.

### Configuracion en `.env`

```
SUPABASE_URL=https://eipfkavrbfdiczzmzfiw.supabase.co
SUPABASE_ANON_KEY=sb_publishable_...
SUPABASE_CONTACT_PHOTOS_BUCKET=contacts_images
SUPABASE_CONTACT_PHOTOS_FOLDER=contacts
SUPABASE_PROFILE_PHOTOS_FOLDER=profiles
```

### Fotos de contactos

- `ContactService.uploadContactPhoto()` sube a `contacts_images/contacts/{uid}/{contactId}/{timestamp}.jpg`
- `ContactFormViewModel` tiene image picker con `ImagePicker` (movil) + `FilePicker` (desktop)
- Al guardar un contacto, si hay foto seleccionada se sube antes de persistir en Firestore

### Fotos de perfil

- `ProfileService.uploadProfilePhoto()` sube a `contacts_images/profiles/{uid}/{timestamp}.jpg`
- `ProfileEditorViewModel` tiene la misma logica de image picker
- El campo de texto de URL manual se ha reemplazado por un avatar circular con picker
- En `ProfileForm` se muestra el avatar con preview (de bytes o URL de red), boton "Cambiar foto" y "Eliminar"

### Supabase Storage — Policies necesarias

El bucket `contacts_images` debe tener estas policies en Supabase:

```sql
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT TO anon
WITH CHECK (bucket_id = 'contacts_images');

CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT TO anon
USING (bucket_id = 'contacts_images');

CREATE POLICY "Allow public updates"
ON storage.objects FOR UPDATE TO anon
USING (bucket_id = 'contacts_images');
```

El bucket debe estar marcado como **publico** en el dashboard de Supabase.

### Archivos clave

- `lib/core/config/env_config.dart` — getters para bucket, carpetas de contactos y perfil
- `lib/features/contacts/contact_service.dart` — `uploadContactPhoto()`
- `lib/features/contacts/contact_form_viewmodel.dart` — image picker + upload para contactos
- `lib/features/profile/profile_service.dart` — `uploadProfilePhoto()`
- `lib/features/profile/profile_editor_viewmodel.dart` — image picker + upload para perfil
- `lib/shared/widgets/profile/profile_form.dart` — avatar picker UI

## Paleta de colores Sunset

Se ha aplicado la paleta **Sunset** a toda la app. Transmite energia juvenil, optimismo y conexion humana.

### Colores principales

| Rol | Light | Dark |
|---|---|---|
| Primary | `#E83E6C` (hot pink) | `#FFB0C4` |
| Secondary | `#F2994A` (golden coral) | `#FFCB8E` |
| Tertiary | `#FF8A65` (peach glow) | `#FFAB91` |
| Surface | `#FFFAF8` | `#1A1215` |
| Scaffold BG | `#FFF5F0` | `#140E10` |

### Gradiente hero

```
#E83E6C → #F2994A → #FFD36E (rosa → dorado → amarillo sol)
```

### Archivos modificados

- `lib/shared/themes/color_scheme.dart`
- `lib/shared/themes/text_theme.dart`
- `lib/shared/themes/app_theme.dart`
- Gradientes hardcodeados actualizados en: `profile_summary_card.dart`, `profile_avatar.dart`, `profile_page.dart`

## Pagina de configuracion y tema

Se ha creado una pagina de configuracion accesible desde la pestana de Perfil.

### Funcionalidad

- Icono de ruedita (⚙️) en la esquina superior derecha del perfil
- Navega a `/settings`
- Tres opciones de tema: Automatico, Modo claro, Modo oscuro
- Cambio reactivo e instantaneo mediante `ThemeProvider`

### Archivos nuevos

- `lib/features/settings/theme_provider.dart` — `ChangeNotifier` con `ThemeMode`
- `lib/pages/settings/settings_page.dart` — UI con 3 opciones animadas

### Archivos modificados

- `lib/app.dart` — `Consumer<ThemeProvider>` para tema reactivo
- `lib/core/di/service_locator.dart` — registro de `ThemeProvider`
- `lib/core/constants/routes.dart` — ruta `/settings`
- `lib/routes/app_routes.dart` — `GoRoute` para `SettingsPage`
- `lib/pages/profile/profile_page.dart` — icono ⚙️ + `onEditPhoto` navega a editor

## Estructura actualizada

### Pages

- `lib/pages/contacts/contact_form_page.dart`
- `lib/pages/contacts/connections_page.dart`
- `lib/pages/contacts/contact_detail_page.dart`
- `lib/pages/profile/profile_page.dart`
- `lib/pages/profile/profile_editor_page.dart`
- `lib/pages/settings/settings_page.dart`

### Features

- `lib/features/contacts/contact_service.dart`
- `lib/features/contacts/contact_form_viewmodel.dart`
- `lib/features/contacts/connections_viewmodel.dart`
- `lib/features/contacts/models/contact_record.dart`
- `lib/features/profile/profile_service.dart`
- `lib/features/profile/profile_viewmodel.dart`
- `lib/features/profile/profile_editor_viewmodel.dart`
- `lib/features/profile/models/user_profile.dart`
- `lib/features/settings/theme_provider.dart`

### Rutas

| Ruta | Pagina |
|---|---|
| `/` | Home |
| `/login` | Login |
| `/register` | Registro |
| `/onboarding/profile` | Onboarding perfil |
| `/connections` | Conexiones |
| `/connections/contact/:contactId` | Detalle contacto |
| `/contacts/new` | Nuevo contacto |
| `/contacts/:contactId/edit` | Editar contacto |
| `/profile` | Perfil |
| `/profile/edit` | Editar perfil |
| `/settings` | Configuracion |
| `/scanner` | Escaner QR |

## Siguiente paso recomendado

1. Persistir la preferencia de tema (SharedPreferences) para que sobreviva al reinicio de la app.
2. Preparar el flujo de importacion por QR reutilizando `identity` y manteniendo `relationship` intacto.

