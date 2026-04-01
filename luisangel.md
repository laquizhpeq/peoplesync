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

## Conclusión para el TFG
Esta arquitectura de componentes promueve la **consistencia visual** en toda la aplicación. Al separar la lógica de negocio de la presentación y parametrizar los widgets, se reduce la duplicación de código y se facilita la realización de pruebas unitarias sobre los componentes de UI.
