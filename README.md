# PeopleSync

PeopleSync es una aplicación multiplataforma construida con Flutter para gestionar contactos y relaciones personales de forma más rica que una agenda tradicional.

La idea central no es solo guardar nombres y teléfonos, sino conservar contexto: quién es cada persona, cómo la conociste, qué relación tienes con ella y cuándo conviene retomar el contacto.

## Qué hace

- gestiona una agenda privada por usuario
- separa los datos públicos de una persona de las notas privadas de la relación
- permite crear contactos manuales, importarlos y vincularlos
- soporta intercambio rápido mediante códigos QR
- ofrece perfil de usuario con onboarding inicial
- usa navegación dinámica basada en roles y menús cargados desde Firestore
- permite subir imágenes de perfil y de contactos

## Enfoque del producto

PeopleSync está pensado como una capa de organización personal y networking. El modelo principal distingue entre:

- `identity`: información base del contacto
- `relationship`: información privada y contextual del usuario sobre ese contacto

Esa separación evita mezclar datos públicos con interpretación personal y hace que el sistema sea más mantenible al crecer.

## Stack técnico

- Flutter
- Firebase Auth
- Cloud Firestore
- Supabase Storage
- SQLite local para cache de contactos
- Provider
- get_it
- go_router

## Arquitectura

El proyecto sigue una organización por capas y responsabilidades:

- `core`: configuración, constantes, utilidades e infraestructura compartida
- `features`: lógica funcional agrupada por dominio
- `pages`: pantallas completas
- `shared`: tema y widgets reutilizables
- `routes`: navegación centralizada

La guía interna completa de arquitectura y trabajo del repositorio está en [AGENTS.md](./AGENTS.md).

## Estado actual

La base funcional principal ya existe: autenticación, perfil, contactos, QR, tema y navegación dinámica. Aun así, el proyecto todavía tiene margen claro de mejora en documentación pública, tests y endurecimiento de convenciones arquitectónicas.

## Propósito del repositorio

Este repositorio no debe crecer como una suma desordenada de pantallas. La prioridad es consolidar una app mantenible, modular y preparada para evolucionar sin convertir cada cambio en deuda técnica.
