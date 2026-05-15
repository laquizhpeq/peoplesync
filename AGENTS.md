# AGENTS.md

## Objetivo
Este archivo define la arquitectura y organización real de `peoplesync` para que cualquier cambio futuro respete una estructura coherente, mantenible y escalable.

La app es un proyecto **Flutter multiplataforma** con:

- `Firebase Auth` para autenticación
- `Cloud Firestore` para datos de aplicación
- `Supabase Storage` para almacenamiento de imágenes
- `Provider` para estado de UI
- `get_it` para inyección de dependencias
- `go_router` para navegación

## Principio general
La estructura sigue una separación por responsabilidades:

- `core`: infraestructura transversal, utilidades globales, constantes y configuración
- `features`: lógica funcional y de negocio agrupada por dominio
- `pages`: pantallas completas
- `shared`: tema, diseño y widgets reutilizables
- `routes`: definición central de navegación

No mezclar responsabilidades por comodidad. Si algo “funciona” pero rompe esta separación, es deuda técnica.

## Estructura del proyecto

### `lib/main.dart`
Punto de entrada.

Responsabilidades:

- inicializar Flutter
- cargar `.env`
- inicializar Firebase
- inicializar Supabase si hay configuración
- arrancar el service locator
- lanzar la app

No meter aquí lógica de negocio ni navegación.

### `lib/app.dart`
Composición raíz de la app.

Responsabilidades:

- registrar `Provider`s globales
- aplicar tema
- montar `MaterialApp.router`
- conectar con `AppRoutes`

No meter lógica de dominio aquí.

## Carpetas y qué va en cada una

### `lib/core`
Infraestructura compartida de bajo nivel.

#### `core/config`
Configuración global derivada de entorno o setup.

Ejemplo:

- `env_config.dart`: lectura tipada de variables `.env`

Aquí va:

- acceso a variables de entorno
- configuración técnica compartida

Aquí no va:

- lógica de UI
- reglas de negocio de una feature concreta

#### `core/constants`
Constantes globales de app.

Ejemplos:

- rutas
- nombres de assets
- strings comunes

Usar para evitar hardcodes repetidos. No usar como cajón desastre.

#### `core/di`
Inyección de dependencias.

Ejemplo:

- `service_locator.dart`

Aquí se registran:

- servicios
- providers globales
- viewmodels

Regla:

- si una dependencia necesita ser resuelta globalmente, se registra aquí
- evitar crear instancias manuales dispersas por páginas o widgets

#### `core/utils`
Utilidades transversales pequeñas.

Ejemplo:

- helpers de rutas

Aquí no va:

- lógica de dominio
- helpers gigantes con múltiples responsabilidades

#### `core/errors`
Reservado para errores compartidos.

Ahora mismo está infrautilizado. Si aparecen excepciones reutilizables entre módulos, deben vivir aquí en vez de duplicarse.

#### `core/services`
Reservado para servicios realmente transversales.

No meter aquí servicios de dominio como contactos, perfil o auth. Esos pertenecen a `features`.

### `lib/features`
Núcleo funcional de la app. Cada subcarpeta representa un dominio o capacidad.

Regla principal:

- si el código implementa comportamiento de una funcionalidad concreta, debe vivir en `features/<feature>`

#### Patrón interno por feature
Cada feature debería agrupar, cuando aplique:

- `*_service.dart`: acceso a datos, backend, persistencia y reglas de aplicación cercanas al dominio
- `*_viewmodel.dart`: estado de UI, coordinación de casos de uso y validaciones de pantalla
- `*_state.dart`: estado explícito si hace falta separarlo
- `models/`: entidades, enums, mapeos y contratos de datos
- `widgets/`: widgets específicos de esa feature si no son reutilizables globalmente

#### `features/auth`
Responsable de autenticación.

Incluye:

- login
- registro
- logout
- stream del usuario autenticado
- mapeo de errores de auth

Aquí va:

- `AuthService`
- `AuthViewModel`
- estado de autenticación

No debe contener:

- widgets visuales genéricos reutilizables
- lógica de contactos o navegación de menús

#### `features/navigation`
Responsable del menú dinámico y autorización visual por rutas.

Incluye:

- carga de rol del usuario
- resolución de menús desde Firestore
- estado de carga/autorización del menú

Aquí va:

- `NavigationService`
- `NavigationProvider`
- modelo `MenuOption`

Nota:

- esto controla autorización de navegación en cliente
- no sustituye reglas de seguridad reales en Firestore

#### `features/contacts`
Dominio principal de agenda y conexiones.

Incluye:

- CRUD de contactos
- importación desde dispositivo
- sincronización
- contactos vinculados
- persistencia del modelo `identity/relationship`

Modelos clave:

- `ContactRecord`
- `ContactIdentity`
- `ContactRelationship`
- `ContactSocialProfile`

Regla importante:

- `identity` contiene datos base de la persona
- `relationship` contiene datos privados del usuario sobre esa persona
- no mezclar ambos bloques ni sobrescribir `relationship` en procesos de sync de identidad

#### `features/profile`
Responsable del perfil del usuario autenticado.

Incluye:

- lectura y guardado del perfil propio
- onboarding de perfil
- subida de foto
- edición de redes sociales

Aquí va:

- `ProfileService`
- `ProfileViewModel`
- `ProfileEditorViewModel`
- `UserProfile`

#### `features/qr_code`
Responsable del intercambio por QR.

Incluye:

- generación de QR
- lectura de QR
- estandarización del payload

No debe absorber lógica general de contactos. Si escanear QR termina creando contactos, la persistencia final debe seguir viviendo en `contacts`.

#### `features/settings`
Responsable de preferencias del usuario relacionadas con la app.

Actualmente:

- gestión de tema

Si crece, aquí deberían ir preferencias visuales o de comportamiento, no reglas de negocio de otros módulos.

### `lib/pages`
Pantallas completas orientadas a navegación.

Regla:

- una `page` compone layout, consume viewmodels y ensambla widgets
- no debería contener lógica pesada de negocio ni acceso directo a Firestore/Supabase

Ejemplos actuales:

- `pages/auth/*`
- `pages/contacts/*`
- `pages/profile/*`
- `pages/settings/*`
- `pages/scanner/*`
- `pages/home/*`

Qué sí puede tener una page:

- composición visual
- wiring con `Provider`
- navegación
- estados simples de interacción

Qué no debe tener:

- queries a backend
- reglas de persistencia
- mapeos de documentos

### `lib/shared`
Todo lo reutilizable entre múltiples features.

Regla principal:

- si un widget o estilo puede reutilizarse en distintas partes de la app sin depender de un dominio concreto, pertenece a `shared`

#### `shared/themes`
Sistema visual global.

Incluye:

- color schemes
- text themes
- button themes
- `AppTheme`

Aquí deben vivir las decisiones de diseño global, no colores hardcodeados repartidos por páginas.

#### `shared/widgets`
Componentes reutilizables.

Subgrupos actuales:

- `auth`: piezas reutilizables del flujo de autenticación
- `base`: primitives genéricas como botones, inputs y cards
- `common`: estados vacíos, loaders y piezas genéricas
- `contacts`: widgets reutilizables del dominio de contactos
- `design`: sistema de diseño visual y layout
- `profile`: widgets reutilizables del perfil

Regla de uso:

- si un widget es específico de una sola feature, primero evaluar si debe vivir dentro de esa feature
- si ya se reutiliza o está claro que será transversal, entonces va a `shared/widgets`

#### Diferencia entre `shared/widgets/base` y `shared/widgets/design`
Usar esta distinción:

- `base`: primitivas mínimas y neutras
- `design`: componentes ya estilizados según el lenguaje visual de PeopleSync

Ejemplo:

- un input genérico: `base`
- un input con look and feel oficial de la app: `design`

### `lib/routes`
Definición central del router.

Ejemplo:

- `app_routes.dart`

Aquí va:

- árbol de rutas
- `redirects`
- guards de sesión y onboarding
- shell layout principal

No meter aquí lógica de acceso a datos más allá de lo imprescindible para decidir redirecciones.

## Reglas de organización

### 1. No duplicar lógica entre pages y features
Si una pantalla necesita leer, guardar, validar o sincronizar datos, esa lógica debe bajar a `viewmodel` o `service`.

### 2. No meter widgets reutilizables dentro de pages
Si un bloque visual se repite o puede repetirse, extraerlo a `shared/widgets` o a `features/<feature>/widgets`.

### 3. No usar `shared` como vertedero
`shared` no significa “cualquier cosa que no sé dónde poner”. Solo va ahí lo reutilizable y transversal.

### 4. No acoplar UI directamente a Firestore o Supabase
Las páginas y widgets no deberían conocer detalles de persistencia.

### 5. Los modelos mandan sobre los mapas sueltos
Evitar pasar `Map<String, dynamic>` por toda la app cuando existe un modelo claro como `ContactRecord` o `UserProfile`.

### 6. Mantener separación entre dominio público y privado en contactos
No mezclar:

- datos públicos de la persona
- notas privadas o contexto del usuario

Esa separación es una decisión correcta del modelo y debe mantenerse.

### 7. Documentar decisiones estructurales
Si una nueva feature introduce una convención, flujo o subestructura nueva, actualizar este archivo.

## Flujo actual de alto nivel

### Autenticación y arranque
1. `main.dart` carga entorno e inicializa servicios
2. `MyApp` monta providers globales y router
3. `AppRoutes` decide si el usuario va a:
   - login
   - onboarding
   - home
4. si el usuario está autenticado, se asegura perfil y se cargan menús dinámicos

### Menú dinámico
1. se lee `users/{uid}.rol_id`
2. se consulta `rol/{rolId}`
3. se recuperan los `menus` permitidos
4. la UI renderiza navegación según esos menús

### Contactos
1. cada usuario tiene su agenda en `users/{uid}/contacts/{contactId}`
2. los contactos se modelan con `identity` + `relationship`
3. importaciones y sincronizaciones deben respetar esa separación

### Perfil
1. el perfil del usuario vive en `users/{uid}`
2. tras registro puede requerirse onboarding
3. la edición del perfil usa `ProfileService` y `ProfileEditorViewModel`

## Comandos de trabajo del repositorio
Estos comandos viven aquí y no en el `README`, porque son operativos y de mantenimiento.

### Docker
Build manual de imagen web:

```bash
docker build -t peoplesync-web .
```

Ejecutar contenedor web:

```bash
docker run -d -p 8080:80 --name peoplesync-app peoplesync-web
```

Producción:

```bash
docker-compose up --build -d
```

Desarrollo, build y arranque:

```bash
docker-compose -f docker-compose-dev.yml up --build -d
```

Entrar al contenedor de desarrollo:

```bash
docker-compose -f docker-compose-dev.yml attach peoplesync-dev
```

Eliminar contenedores huérfanos:

```bash
docker compose -f docker-compose-dev.yml down --remove-orphans
```

### Calidad de código
Analizar el proyecto:

```bash
flutter analyze
```

Formatear `lib/`:

```bash
dart format lib/
```

Aplicar sugerencias automáticas en seco:

```bash
dart fix --dry-run
```

### Testing
Ejecutar tests:

```bash
flutter test
```

### Utilidades
Vista previa de widgets:

```bash
flutter widget-preview start
```

Generar archivos de soporte si el proyecto incorpora generación de código:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Nota
No todos los comandos reflejan una necesidad actual del proyecto en su estado real.

- `build_runner` solo tiene sentido si se introduce generación de código efectiva
- `widget-preview` solo aporta valor si el flujo del equipo lo usa de verdad

No acumular comandos por inercia.

## Qué poner en cada sitio

### Si vas a crear una nueva feature
Crear en `lib/features/<nombre>/`:

- servicio si hay acceso a datos
- viewmodel si hay estado de UI
- modelos si hay entidades propias
- widgets propios si no son compartidos globalmente

Y luego:

- crear la `page` correspondiente en `lib/pages/<nombre>/`
- registrar dependencias en `core/di/service_locator.dart` si aplica
- añadir rutas en `lib/routes/app_routes.dart`

### Si vas a crear un widget reutilizable
Elegir entre:

- `shared/widgets/base` si es primitiva neutra
- `shared/widgets/design` si forma parte del sistema visual
- `shared/widgets/<dominio>` si es reusable pero con semántica funcional concreta

### Si vas a tocar configuración o constantes globales
Usar:

- `core/config`
- `core/constants`
- `shared/themes`

### Si vas a tocar acceso a backend
Hacerlo en el `service` de la feature correspondiente.

No abrir clientes de Firestore, Auth o Supabase desde `pages`.

## Antipatrones a evitar

- meter lógica de negocio dentro de widgets
- llamar a Firestore directamente desde una página
- copiar y pegar formularios similares en vez de extraer componentes
- usar `shared` como carpeta “misc”
- introducir modelos alternativos para la misma entidad
- saltarse `service_locator` creando dependencias a mano sin criterio
- mezclar reglas de navegación, permisos y UI en el mismo widget si se puede separar

## Estado actual de madurez
La base es válida, pero todavía hay deuda técnica:

- documentación oficial débil
- tests escasos
- varios `print/debugPrint` en producción
- mezcla parcial entre convención y oportunidad

Eso significa que cualquier cambio futuro debe reforzar la estructura, no erosionarla.

## Regla final
Si una implementación rápida rompe modularidad, reutilización o separación de responsabilidades, no es una solución buena. Es solo una deuda que todavía no ha explotado.
