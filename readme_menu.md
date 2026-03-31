# Sistema de Navegación Dinámica con Firebase (DAM TFG)

Este documento detalla la implementación del sistema de navegación dinámica basado en roles para la aplicación PeopleSync, utilizando Flutter y Cloud Firestore.

## 1. Arquitectura del Sistema

El sistema sigue un patrón de diseño desacoplado en tres capas:

1.  **Capa de Datos (`NavigationService`)**: Gestiona las consultas directas a Firestore.
2.  **Capa de Estado (`NavigationProvider`)**: Gestiona el ciclo de vida de los menús cargados y notifica a la UI.
3.  **Capa de Presentación (`BottomNavBar` & `AppLayout`)**: Renderiza los componentes visuales basándose en el estado dinámico.

---

## 2. Modelo de Datos (Firestore)

El sistema utiliza tres colecciones principales en Firestore:

### Colección: `users`
Contiene la información de perfil de los usuarios.
- **Document ID**: UID del usuario (Firebase Auth).
- **Campos**:
  - `rol_id` (string): Indica el rol asignado al usuario (ej: `admin`, `user`).

### Colección: `rol`
Define qué menús tiene permitido ver cada rol.
- **Document ID**: ID del rol (ej: `admin`).
- **Campos**:
  - `menus` (array of strings): Lista de IDs de la colección `menus`.

### Colección: `menus`
Define las opciones individuales del menú.
- **Document ID**: Identificador único (ej: `home`, `profile`).
- **Campos**:
  - `title` (string): El texto que se mostrará en el menú.
  - `route` (string): La ruta de navegación (ej: `/`, `/profile`).
  - `icon` (string): Nombre del icono (mapeado en la app).
  - `order` (number): Posición en la que aparecerá (ascendente).

---

## 3. Flujo Lógico de Carga

1.  **Autenticación**: Tras el login o al iniciar la app con sesión activa, se obtiene el `UID` del usuario.
2.  **Obtención de Rol**: Se consulta `users/{uid}` para obtener su `rol_id`.
3.  **Filtrado de Menús**: Se consulta `rol/{rol_id}` para obtener el array de IDs de menús permitidos.
4.  **Carga de Detalles**: Se realiza una consulta `whereIn` en la colección `menus` usando los IDs obtenidos.
5.  **Mapeo y Notificación**: Los datos se convierten en objetos `MenuOption` y el `NavigationProvider` notifica a los widgets para que se reconstruyan.

---

## 4. Archivos Clave

- [**navigation_service.dart**](file:///d:/tfg/peoplesync/lib/features/navigation/navigation_service.dart): Implementa la lógica de consultas asíncronas a Firestore con manejo de errores y permisos.
- [**navigation_provider.dart**](file:///d:/tfg/peoplesync/lib/features/navigation/navigation_provider.dart): Mantiene la lista de menús en memoria y gestiona los estados de "cargando" y "error".
- [**menu_option.dart**](file:///d:/tfg/peoplesync/lib/features/navigation/models/menu_option.dart): El modelo que transforma los documentos de Firestore en objetos Dart, incluyendo el mapeo de iconos de texto a `IconData`.
- [**bottom_nav_bar.dart**](file:///d:/tfg/peoplesync/lib/shared/widgets/design/layout/bottom_nav_bar.dart): Widget dinámico que genera automáticamente los items del `BottomNavigationBar` basándose en el proveedor.
- [**app_layout.dart**](file:///d:/tfg/peoplesync/lib/shared/widgets/design/layout/app_layout.dart): Asegura que los menús se carguen automáticamente si el usuario ya está logueado al iniciar la app.
- [**firestore.rules**](file:///d:/tfg/peoplesync/firestore.rules): Define la seguridad para que solo usuarios autenticados puedan leer sus perfiles y las definiciones de menú.

---

## 5. Reglas de Seguridad (Firestore Rules)

El sistema utiliza reglas de seguridad granulares para proteger los datos y evitar el error `permission-denied`. Estas reglas aseguran que solo el propietario de un perfil pueda leer sus datos, mientras que las definiciones de roles y menús son accesibles para cualquier usuario autenticado de la plataforma.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Perfiles: El usuario solo puede leer/escribir su propio documento
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Roles: Usuarios autenticados pueden leer las definiciones
    match /rol/{roleId} {
      allow read: if request.auth != null;
    }
    
    // Menús: Usuarios autenticados pueden leer los items del sistema
    match /menus/{menuId} {
      allow read: if request.auth != null;
    }
    
    // Por defecto: Denegar cualquier otro acceso (más seguro que las reglas demo)
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 6. Cómo Registrar un Nuevo Menú

Para añadir una nueva opción de menú al sistema:

### En Firebase:
1.  **Colección `menus`**: Crea un nuevo documento (ej: `tasks`).
    - Añade `title`: "Tareas", `route`: "/tasks", `icon`: "settings_outlined", `order`: 5.
2.  **Colección `rol`**: Edita el rol deseado (ej: `admin`) y añade el ID `"tasks"` al array de su campo `menus`.

### En la App:
1.  **Rutas**: Asegúrate de que la ruta (`/tasks`) esté definida en `lib/routes/app_routes.dart`.
2.  **Iconos**: Si usas un icono nuevo, asegúrate de que el string de Firestore esté mapeado en el `switch` de `MenuOption.iconData` en `lib/features/navigation/models/menu_option.dart`.

---

## 7. Dinamismo y Ventajas
- **Sin Hardcoding**: No hay rutas ni textos de menú escritos directamente en el código de la barra de navegación.
- **Control Remoto**: Puedes cambiar el orden, los iconos o añadir secciones enteras a la app sin necesidad de actualizar la aplicación en las tiendas (solo editando Firestore).
- **Seguridad**: El sistema solo carga lo que el rol del usuario permite, evitando accesos no autorizados a nivel de UI.
