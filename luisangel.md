# Documentación de Avances - Proyecto PeopleSync

**Fecha:** 1 de abril de 2026  
**Autor:** Luis Angel  
**Objetivo:** Creación y refactorización de componentes de interfaz reutilizables para el Dashboard principal.

## Introducción
En la sesión de hoy se ha trabajado en la capa de presentación (UI) del proyecto, siguiendo principios de diseño atómico y reutilización de componentes. Se han extraído patrones comunes de la interfaz para crear widgets personalizados que facilitan el mantenimiento y la escalabilidad del proyecto PeopleSync, fundamentales para la memoria del TFG.

## Componentes Reutilizables Creados

### 1. WelcomeWidget
- **Ubicación:** `lib/shared/widgets/design/header/welcome.dart`
- **Por qué:** Permite estandarizar la cabecera de las diferentes pantallas, proporcionando una estructura consistente para títulos y mensajes de bienvenida.
- **Cómo:** Utiliza `Text.rich` para combinar diferentes estilos de texto (normal y negrita) en una sola línea, permitiendo personalizar el título superior y el saludo.

### 2. TimeReconectCard
- **Ubicación:** `lib/shared/widgets/design/card/time_reconect.dart`
- **Por qué:** Una tarjeta de "Call to Action" (llamada a la acción) diseñada para sugerir interacciones al usuario (ej: reconectar con contactos).
- **Cómo:** Implementa una estructura con icono leading, título, descripción y dos botones de acción (primario y secundario). Utiliza `StadiumBorder` para los botones, siguiendo una estética moderna y amigable.

### 3. QuickActionsCard
- **Ubicación:** `lib/shared/widgets/design/actions/quick_actions.dart`
- **Por qué:** Botones de acción rápida en formato de rejilla. Mejora la experiencia de usuario (UX) al permitir el acceso directo a funcionalidades clave como escanear QR o añadir contactos.
- **Cómo:** Basado en un `Card` con `InkWell` para efectos visuales de pulsación. Incluye un contenedor circular para el icono y un estilo de texto optimizado para etiquetas cortas.

### 4. ContactItem
- **Ubicación:** `lib/shared/widgets/design/listtile/contact_item.dart`
- **Por qué:** Reemplaza el `ListTile` estándar de Flutter por uno con un diseño más personalizado y adaptado a la identidad visual de PeopleSync.
- **Cómo:** Utiliza un `Container` con `BoxDecoration` para crear un diseño "en cápsula" con bordes muy redondeados (radius 40). Integra un `CircleAvatar` para la imagen del contacto.

## Refactorización del HomePage
Se ha transformado la pantalla de inicio (`lib/pages/home/home_page.dart`) para que sea puramente declarativa mediante el uso de los componentes anteriores.
- **Scroll Infinito:** Se ha implementado `SingleChildScrollView` para permitir que el contenido fluya verticalmente.
- **Consumo de Constantes:** Se han movido todos los literales de texto a `lib/core/constants/app_strings.dart` para facilitar la futura internacionalización (i18n).

## Metodología de Desarrollo
Se ha integrado el uso de la anotación `@Preview` en los widgets (ej: `ProfileCard`).
- **Ventaja:** Permite visualizar y probar los componentes de forma aislada sin necesidad de navegar por toda la aplicación, acelerando el ciclo de diseño y desarrollo.

## Avances - 6 de abril de 2026: Sistema de Intercambio por QR

**Objetivo:** Implementación de la funcionalidad de generación y lectura de códigos QR para la conexión rápida entre usuarios.

### 1. Generación de QR (User Identity)
- **Librería:** `pretty_qr_code`
- **Ubicación:** `lib/pages/profile/profile_page.dart` y `lib/features/qr_code/qr_service.dart`
- **Implementación:** Se ha integrado un componente visual (`_QrIdentityCard`) directamente en el perfil del usuario. Esto permite que el QR sea "siempre visible", facilitando el proceso de compartir el perfil sin pasos adicionales.
- **Estandarización:** Se definió un esquema de datos propio (`peoplesync://profile/{uid}`) gestionado por el `QrService`, lo que asegura que cualquier lector compatible con la app pueda interpretar la identidad del usuario de forma unívoca.

### 2. Lectura e Importación (Scanner Dialog)
- **Librería:** `mobile_scanner`
- **Ubicación:** `lib/features/qr_code/widgets/scanner_dialog.dart` y `lib/pages/scanner/scanner_viewmodel.dart`
- **Diseño UX:** Siguiendo requerimientos de agilidad, se implementó el escáner dentro de un `AlertDialog`. Esto permite invocar la cámara desde el Dashboard principal sin perder el contexto de la navegación.
- **Lógica de Enlace:** Al detectar un código válido, el `ScannerViewModel` recupera el perfil público desde Firestore (`users/{uid}`) y crea automáticamente un `ContactRecord` de tipo `linkedUser` en la agenda del usuario que escanea.

### 3. Configuración Nativa y Permisos
Para un proyecto de **DAM**, es vital documentar el manejo de recursos hardware:
- **Android:** Inserción del permiso `android.permission.CAMERA` en el `AndroidManifest.xml`.
- **iOS:** Configuración de la llave `NSCameraUsageDescription` en el `Info.plist` con un mensaje descriptivo para el usuario, cumpliendo con las políticas de privacidad de Apple.

### 4. Arquitectura y Patrones
- **MVVM:** Se ha mantenido la separación entre la lógica de procesamiento de la imagen (ViewModel) y la visualización de la cámara (View).
- **Inyección de Dependencias:** El `QrService` y el `ScannerViewModel` han sido registrados en el `Service Locator` (`get_it`), permitiendo un acoplamiento débil entre componentes.

## Conclusión para el TFG (DAM)
La implementación del sistema QR demuestra la capacidad de integrar **APIs nativas** (Cámara) y **librerías externas** de alto nivel. El uso de un esquema de URL personalizado (`peoplesync://`) sienta las bases para futuras implementaciones de **Deep Linking**, permitiendo que la aplicación reaccione a escaneos incluso desde fuera de la propia interfaz de cámara de la app.

---

## Avances - 7 de abril de 2026: Capa de Servicio para la Funcionalidad de Networking

**Objetivo:** Diseño e implementación de los métodos de negocio que gestionan el ciclo de vida de los contactos vinculados por QR, dentro de la arquitectura de datos de Firebase ya establecida.

### Contexto Arquitectónico

La funcionalidad de Networking se apoya en una estructura de datos en Firestore con dos niveles diferenciados:

- **Colección maestra `users`:** Almacena el perfil público de cada usuario registrado (fuente de verdad de `ContactIdentity`).
- **Subcolección `contacts`:** Cada usuario posee su propia subcolección en la ruta `/users/{uid}/contacts/{contactoUid}`. Aquí se almacena el `ContactRecord` completo, que combina los datos públicos del contacto (`identity`) con las anotaciones privadas del propietario (`relationship`).

Esta separación es una decisión de arquitectura deliberada: **los datos públicos y los privados nunca viajan juntos**, lo que simplifica las reglas de seguridad de Firestore y protege la privacidad del usuario.

### Modelo de Datos (Recap)

El modelo `ContactRecord` encapsula tres capas de información:

| Clase | Rol | Persistencia en Firestore |
|---|---|---|
| `ContactIdentity` | Datos públicos (nombre, foto, redes sociales) | Sub-mapa `identity` en el documento |
| `ContactRelationship` | Datos privados del propietario (notas, contexto) | Sub-mapa `relationship` en el documento |
| `ContactRecord` | Raíz: une identidad + relación + metadatos | Documento raíz en la subcolección |

El propio `ContactRecord.toMap()` se encarga de inyectar `FieldValue.serverTimestamp()` en `created_at` y `updated_at`, por lo que el servicio no gestiona las fechas manualmente — esa lógica está centralizada en el modelo.

### Excepción Tipada: `ContactServiceException`

Antes de implementar los métodos, se definió una excepción tipada específica para el servicio:

```dart
class ContactServiceException implements Exception {
  final String message;
  final Object? cause;
}
```

**Por qué:** Lanzar `Exception` genérica obliga a los consumidores (ViewModels, UI) a tratar cualquier error como un `Object` opaco. Con una excepción tipada, el ViewModel puede distinguir entre un error de negocio conocido (ej: "perfil no encontrado") y un error inesperado de red, y reaccionar de forma diferenciada. La excepción vive en el mismo archivo que el servicio porque es una excepción de dominio de ese servicio, no un componente de infraestructura global.

### Métodos Implementados

#### 1. `saveScannedContact`

```dart
Future<void> saveScannedContact({
  required String miUid,
  required String contactoUid,
  String? notaContexto,
}) async { ... }
```

**Flujo de ejecución:**
1. Lee el documento del contacto desde la colección maestra `users/{contactoUid}`.
2. Verifica existencia del perfil; lanza `ContactServiceException` si no existe.
3. Construye un `ContactIdentity` a partir del mapa de datos públicos.
4. Crea un `ContactRecord` con `source: ContactSource.qrImport` y `linkedUserUid: contactoUid`.
5. Persiste usando `.set()` (no `.add()`) para que el ID del documento coincida con el UID del contacto.

**Decisión clave — `.set()` vs `.add()`:** Se usa `.doc(contactoUid).set(...)` para garantizar idempotencia: si el usuario escanea el mismo QR dos veces, el documento se sobreescribe en lugar de crear un duplicado. Es el comportamiento correcto en el dominio de una agenda de contactos.

#### 2. `streamMyContacts`

```dart
Stream<List<ContactRecord>> streamMyContacts(String miUid) { ... }
```

**Por qué un `Stream` y no un `Future`:** Firestore soporta listeners en tiempo real. Al retornar un `Stream`, la UI se actualiza automáticamente cada vez que cambia la subcolección, sin necesidad de polling ni de llamadas manuales al servidor.

**`orderBy` en Firestore vs. ordenación en cliente:** El `orderBy('updated_at', descending: true)` se delega a Firestore en lugar de ordenar la lista en Dart. Esto significa que el backend envía los datos ya ordenados, reduciendo el trabajo del cliente y garantizando consistencia independientemente del tamaño de la colección.

#### 3. `syncContactIdentity`

```dart
Future<void> syncContactIdentity({
  required String miUid,
  required String contactoUid,
}) async { ... }
```

**Problema que resuelve:** Cuando un usuario actualiza su foto de perfil o nombre, todos los `ContactRecord` que apuntan a ese usuario como `linkedUserUid` quedan desactualizados. Este método aborda el problema de la **consistencia eventual** en bases de datos NoSQL distribuidas.

**Implementación quirúrgica:** Se usa `.update({'identity': identityMap, 'updated_at': serverTimestamp()})`. Esto garantiza que el campo `relationship` (las notas privadas del propietario) **no se toca en ningún momento**, ya que el update de Firestore solo modifica los campos que se especifican explícitamente.

#### 4. `updatePrivateNotes`

```dart
Future<void> updatePrivateNotes({
  required String contactId,
  required String? privateNotes,
}) async { ... }
```

**Dot-notation de Firestore:** Se utiliza la notación de punto `'relationship.private_notes'` como clave del mapa de actualización. Esta es la forma idiomática de actualizar un campo anidado en Firestore sin necesidad de leer el documento previamente ni de sobreescribir el sub-mapa `relationship` entero. Es la operación de escritura más eficiente posible para este caso.

### Patrón de Manejo de Errores

Todos los métodos siguen el mismo patrón:

```dart
try {
  // lógica de negocio
} on ContactServiceException {
  rethrow; // preserva el tipo y mensaje original
} catch (e) {
  throw ContactServiceException('Mensaje descriptivo.', cause: e);
}
```

**Por qué el `on ContactServiceException { rethrow }` antes del `catch` general:** Sin él, si el bloque interno lanza una `ContactServiceException` (ej: "perfil no existe"), el `catch (e)` la capturaría y la envolvería en *otra* excepción, perdiendo el mensaje original. El `on E { rethrow }` es la forma correcta de "dejar pasar" excepciones tipadas conocidas en Dart.

### Conclusión para el TFG (DAM)

La implementación de esta capa de servicio ilustra varios conceptos clave del módulo de **Desarrollo de Aplicaciones Multiplataforma**:

- **Separación de responsabilidades (SRP):** El servicio es el único punto de acceso a Firestore para la entidad `ContactRecord`. Los ViewModels no conocen la estructura de la BBDD.
- **Consistencia de datos distribuidos:** El patrón `syncContactIdentity` aborda el problema clásico de la consistencia eventual en sistemas NoSQL, donde un cambio en un nodo (perfil público) debe propagarse a los documentos que dependen de él.
- **Idempotencia:** El uso de `.set()` con el UID como ID de documento hace que `saveScannedContact` sea idempotente, una propiedad deseable en sistemas distribuidos donde las operaciones pueden reintentarse.
- **Streams reactivos:** La integración de Firestore con `StreamBuilder` de Flutter elimina la necesidad de gestionar estado de carga manualmente, simplificando la lógica de la capa de presentación.

