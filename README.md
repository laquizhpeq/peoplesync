# PeopleSync

PeopleSync es una aplicación Flutter multiplataforma centrada en relaciones, no en contactos sueltos.

La idea base del producto es simple: una agenda tradicional guarda nombres y teléfonos; PeopleSync guarda contexto. No solo quién es una persona, sino qué relación tienes con ella, cómo la conociste, qué te importa recordar y cuándo conviene retomar el vínculo.

Descarga de APK: https://drive.google.com/file/d/1767RlHSKkAyFPzOcQFxSVMVg8UdPYspL/view?usp=sharing

## Qué es hoy

PeopleSync ya no es una demo vacía ni un CRUD plano de contactos. A día de hoy el proyecto incluye:

- autenticación con Firebase Auth
- perfil de usuario con onboarding
- agenda privada por usuario en Firestore
- separación entre datos públicos del contacto y contexto privado de la relación
- menús dinámicos por rol
- panel de administración basado en perfiles de Firestore
- escaneo y generación de QR para compartir perfil
- caché local de contactos en SQLite
- endpoint HTTP local en Dart dentro de la app para exportación de contactos
- exportación JSON desde la propia interfaz en web
- funciones IA sobre contactos
- asistente conversacional de home llamado `Chispa`

No es un mensajero. No es un CRM empresarial. No es una agenda del móvil con maquillaje. El hueco del producto está entre agenda personal, networking y seguimiento relacional.

## Principio de producto

El modelo central diferencia dos capas:

- `identity`: datos base de la persona
- `relationship`: datos privados del usuario sobre esa persona

Eso evita mezclar:

- información objetiva de la persona
- interpretación, memoria y contexto privado del dueño de la agenda

Esa decisión es una de las partes más acertadas del proyecto. Si la rompes, vuelves a una agenda mediocre y difícil de escalar.

## Funcionalidades principales

### 1. Autenticación y sesión

- login por email y contraseña
- registro de usuarios
- creación automática de perfil inicial
- cierre de sesión
- control de usuarios desactivados
- bootstrap de sesión al arrancar la app

El proyecto llegó a tener integración tentativa con Google Sign-In, pero se retiró del login principal porque no estaba lista ni estabilizada. Ahora mismo el acceso real soportado es email/contraseña.

### 2. Perfil de usuario

Cada usuario tiene su perfil propio en `users/{uid}`.

Incluye:

- nombre visible
- ciudad
- bio
- foto de perfil
- redes sociales visibles
- rol
- estado de onboarding
- estado activo/inactivo
- timestamps de creación, actualización y último acceso

También incluye:

- edición completa de perfil
- QR propio para ser añadido por otros usuarios
- pantalla de configuración separada del perfil

### 3. Contactos

Cada usuario mantiene su propia agenda en:

`users/{uid}/contacts/{contactId}`

Un contacto puede incluir:

- nombre visible
- foto
- ciudad
- empresa
- cargo
- bio
- descripción extendida
- canción favorita
- email
- teléfono
- redes sociales
- tipo de relación
- intereses
- qué representa la relación
- tags de personalidad
- cómo os conocisteis
- última nota
- notas privadas
- favorito
- marcado para fortalecer la relación

Flujos soportados:

- creación manual
- edición
- borrado
- importación desde contactos del dispositivo
- sincronización de identidad
- marcado como favorito
- marcado como relación a cuidar

### 4. Clasificación visual de relaciones

Se añadió una taxonomía explícita de relación para que la agenda no sea una lista amorfa.

Tipos soportados:

- `networking`
- `amistad`
- `clientes`
- `colaboradores`
- `familia`
- `seguir cultivando`

Ese dato:

- se selecciona en formularios
- aparece como badge/icono en las tarjetas de conexiones
- alimenta el mapa de relaciones del Home

### 5. Home

El Home dejó de ser una pantalla pasiva y hoy incluye varias capas:

- acceso rápido `Acciones`
- `Mapa de relaciones` como bloque principal
- módulos de seguimiento relacional
- entrada al asistente `Chispa`

#### Mapa de relaciones

El mapa de relaciones es un bloque visual centrado en:

- total de conexiones
- distribución por tipo de relación
- nodos e iconografía por categoría

Comportamiento actual:

- si hay categorías, muestra el reparto visual
- si no hay categorías pero sí contactos, sigue mostrando el total
- si no hay contactos, muestra `0`

### 6. Conexiones

La pantalla de conexiones fue optimizada para dejar de congelarse al abrir.

Cambios importantes:

- ya no monta toda la lista de golpe
- usa render perezoso para contactos visibles
- las tarjetas tienen más presencia visual
- se añadió un bloque `Filtros`

#### Filtros disponibles

- favoritos
- a cuidar
- vinculados
- recientes
- tipo de relación

#### Diseño de las tarjetas

Se reforzó el estilo visual de cada contacto:

- foto más dominante
- gradiente por tipo de relación
- badge visible
- contexto resumido

### 7. Ficha de contacto

La pantalla de detalle de un contacto incluye:

- hero card visual
- acceso a edición
- favorito
- notas
- fortalecimiento de relación
- selector rápido de tipo de relación desde la propia ficha
- bloques de identidad, contexto, afinidades, contacto directo y memoria privada

También se añadieron mejoras visuales pedidas durante el desarrollo:

- botón de editar en la hero card
- botón de mejorar relación
- icono de favorito simplificado

### 8. IA sobre contactos

La app incluye funciones IA puntuales sobre contactos, no un chatbot genérico incrustado en cada pantalla.

Actualmente existen funciones como:

- `Resumen IA`
- `Sugerir tema`
- `Mensaje IA`

#### Cómo funcionan

- toman como contexto el modelo completo del contacto
- usan datos estructurados del contacto
- usan notas y contexto disponible
- el resultado es temporal en la vista, no persistido automáticamente

#### Sugerir tema

Propone:

- forma de retomar contacto
- rompehielos
- líneas de conversación
- temas naturales para escribir o llamar

#### Mensaje IA

Genera un mensaje breve y contextual y permite:

- copiarlo
- abrir WhatsApp si hay teléfono válido

### 9. Asistente `Chispa`

En Home existe un asistente conversacional llamado `Chispa`.

No es un bot genérico tipo “pregúntame lo que sea” sin propósito. Está orientado a relaciones.

Estado actual:

- botón flotante en Home
- pantalla propia de chat
- conversación temporal por sesión
- tono más natural y orientado a mejorar relaciones
- no usa todavía contexto automático de todos tus contactos

#### Acción soportada hoy

`create_contact`

Pero con un flujo controlado:

- no crea contactos porque sí
- solo entra en ese flujo si el usuario lo pide
- primero confirma intención
- después pide datos en lenguaje natural
- finalmente prepara la creación

### 10. QR y escaneo

PeopleSync soporta:

- generación de QR de perfil
- lectura de QR
- alta rápida de contactos desde QR

El QR usa un payload del tipo:

`peoplesync://profile/{uid}`

### 11. Panel de administración

Existe una primera versión funcional del panel `Admin`.

Su alcance actual es:

- lista de perfiles de usuario de Firestore
- búsqueda
- filtros
- activación/desactivación lógica
- edición de perfil
- cambio de rol
- reinicio de onboarding

Importante:

- no administra usuarios de Firebase Auth a nivel Admin SDK
- no hay backend privilegiado
- el panel gestiona perfiles de la app, no cuentas de Auth al nivel de servidor

### 12. Configuración y modo desarrollador

`Configuración` ya no vive como una tarjeta rara dentro del perfil. Tiene pantalla propia.

Incluye:

- apariencia
- cierre de sesión
- sección `Para desarrolladores`

#### Para desarrolladores

Desde esa sección se puede:

- activar modo desarrollador
- generar token local
- revocar token
- ver estado del servidor local
- exportar contactos en JSON

## Exportación local y endpoint HTTP en la app

Una de las decisiones del proyecto fue eliminar backend Node/Cloud Functions para la exportación y resolverlo dentro de Flutter.

Eso llevó a dos caminos distintos:

### Android / iOS / desktop

La app puede levantar un servidor HTTP local en Dart si el usuario activa `Modo desarrollador`.

Ese servidor:

- vive dentro de la app
- usa token local
- lee desde SQLite
- expone exportación de contactos

Endpoints actuales:

- `GET /v1/health`
- `GET /v1/contacts/export`

### Web

En web no existe servidor local HTTP serio dentro del navegador.

Por eso la solución actual es distinta:

- no levanta endpoint local
- exporta directamente el JSON desde la propia interfaz

## Caché local

Los contactos se almacenan también en SQLite para mejorar experiencia y velocidad.

Objetivo:

- abrir conexiones más rápido
- tener exportación local
- reducir sensación de espera al cargar agenda

Flujo general:

1. la app lee caché local
2. muestra lo disponible
3. sincroniza contra Firebase al entrar

## Stack técnico real

- Flutter
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Supabase Storage
- Provider
- get_it
- go_router
- image_picker
- file_picker
- mobile_scanner
- pretty_qr_code
- flutter_contacts
- permission_handler
- shared_preferences
- sqflite
- path
- http
- flutter_dotenv

## Arquitectura

La organización principal del proyecto es:

- `lib/core`
- `lib/features`
- `lib/pages`
- `lib/shared`
- `lib/routes`

### `core`

Infraestructura transversal:

- configuración
- constantes
- DI
- servicios globales
- logging
- feedback
- traducción de errores

### `features`

Dominios funcionales:

- `admin`
- `ai`
- `assistant`
- `auth`
- `contacts`
- `navigation`
- `profile`
- `qr_code`
- `settings`

### `pages`

Pantallas completas:

- auth
- home
- profile
- contacts
- settings
- admin
- scanner
- assistant

### `shared`

Widgets reutilizables, sistema visual y componentes comunes.

La guía interna más detallada de arquitectura está en [AGENTS.md](./AGENTS.md).

## Estado actual del producto

El proyecto ya tiene bastante más superficie de producto que al inicio de esta conversación, pero eso no significa que esté “cerrado”.

### Lo que ya está bien encaminado

- el modelo `identity/relationship`
- la navegación por roles
- el panel admin de perfiles
- la clasificación visual de relaciones
- el mapa de relaciones
- el asistente `Chispa`
- la exportación local
- la caché SQLite

### Lo que sigue siendo sensible

- la IA sigue integrada desde cliente y no es una solución robusta para producción real
- hay deuda de validación técnica porque `flutter analyze` se ha mostrado inestable en este entorno
- siguen existiendo mensajes, flows y capas que necesitan endurecimiento adicional
- hay decisiones del proyecto tomadas por conveniencia local que no equivalen a arquitectura de backend seria

Si vas a llevar esto a producción pública, no te engañes: el producto ha avanzado mucho, pero todavía no está blindado.

## Flujo funcional de alto nivel

### Arranque

1. se carga `.env`
2. se inicializa Firebase
3. se inicializa Supabase si está configurado
4. se monta el service locator
5. se arranca la app
6. se asegura sesión, perfil, menús y estado global

### Perfil

1. el usuario entra autenticado
2. se asegura `users/{uid}`
3. si falta onboarding, se redirige
4. puede editar perfil, foto, ciudad, bio y redes

### Contactos

1. el usuario gestiona su agenda en `users/{uid}/contacts`
2. los contactos combinan identidad y relación
3. la UI usa ese modelo para lista, detalle, filtros, mapa e IA

### IA

1. el usuario ejecuta una acción IA
2. se pasa el contexto del contacto
3. la IA genera sugerencia, resumen o mensaje
4. la app decide cómo presentarlo
5. no se persiste automáticamente

### Chispa

1. el usuario abre el botón flotante del Home
2. conversa con el asistente
3. si quiere crear contacto, `Chispa` guía el flujo
4. la creación no ocurre sin intención expresa del usuario

## Desarrollo local

### Flutter

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar la app:

```bash
flutter run
```

Analizar:

```bash
flutter analyze
```

Tests:

```bash
flutter test
```

### Docker

Build imagen web:

```bash
docker build -t peoplesync-web .
```

Producción con compose:

```bash
docker-compose up --build -d
```

Desarrollo con compose:

```bash
docker-compose -f docker-compose-dev.yml up --build -d
```

Entrar al contenedor de desarrollo:

```bash
docker-compose -f docker-compose-dev.yml attach peoplesync-dev
```

## Configuración de entorno

El proyecto usa `.env` y también varias configuraciones Firebase pasadas por build o assets según plataforma.

Variables relevantes según el estado actual del repo:

- Firebase
- Supabase
- buckets/rutas de imágenes
- cualquier configuración local adicional que consuma `EnvConfig`

No confundas “la app arranca con `.env`” con “está lista para producción”. Son cosas distintas.

## Limitaciones conocidas

- el panel admin no lista usuarios de Firebase Auth con privilegios de servidor
- la exportación HTTP local no sustituye una API externa real
- web y móvil no pueden compartir exactamente la misma estrategia de exportación local
- la validación automática del proyecto no ha sido fiable en este entorno de trabajo
- parte de la app ha requerido endurecimiento progresivo de errores, reentradas y mensajes al usuario

## Qué ha cambiado de verdad en esta etapa del proyecto

Durante esta fase de trabajo se han introducido cambios importantes, entre ellos:

- mejora del rendimiento de `Conexiones`
- refuerzo visual de tarjetas de contacto
- filtros en conexiones
- tipificación explícita de relaciones
- mapa de relaciones en Home
- menú `Acciones` y `Ajustes`
- selector rápido de tipo de relación en ficha
- primeras funciones IA por contacto
- asistente `Chispa`
- panel admin de perfiles
- configuración con sección de desarrollador
- token local y exportación local
- caché SQLite
- servidor HTTP local en Dart
- mejora de mensajes de error para usuarios
- bloqueo de reentrada del selector de imágenes

No son retoques cosméticos. La app ha cambiado bastante de forma y de ambición.

## Dirección del producto

PeopleSync tiene más potencial si se construye como sistema de seguimiento relacional que como “agenda bonita”.

La parte fuerte del producto no es:

- parecerse a WhatsApp
- parecerse a Telegram
- parecerse a un CRM tradicional

La parte fuerte es:

- contexto
- memoria relacional
- seguimiento
- clasificación
- reactivación de vínculos

Si se pierde ese foco, el producto se diluye.

## Resumen honesto

PeopleSync ya tiene una base funcional amplia:

- autenticación
- perfil
- contactos
- QR
- admin
- IA
- asistente
- caché
- exportación

Pero amplitud no equivale a madurez.

El repo ya no es una plantilla vacía. Tampoco es todavía un producto completamente endurecido para producción seria. Está en una fase intermedia potente, con decisiones interesantes y bastante funcionalidad real, pero con varias capas que todavía exigen disciplina técnica para no convertirse en deuda.

Si vas a seguir desarrollándolo, la prioridad no debería ser meter features al peso. Debería ser consolidar:

- fiabilidad
- claridad del modelo
- experiencia del usuario
- endurecimiento de errores
- arquitectura coherente

Lo demás, si lo fuerzas antes de tiempo, solo infla el proyecto.
