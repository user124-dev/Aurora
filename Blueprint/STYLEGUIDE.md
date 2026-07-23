# Guía de estilo — Aurora

Convenciones de código QML usadas en el proyecto. El objetivo es que cualquier colaborador pueda modificar Aurora sin pelear contra estilos inconsistentes.

## Nombres

- Prefijo `Aurora` en singletons globales: `AuroraState`, `AuroraConfig`, `AuroraPlayerProvider`.
- Componentes visuales sin prefijo, en `Components/`: `Spectrum.qml`, `Controls.qml`, `Cover.qml`, `Info.qml`.
- Propiedades en `camelCase`. Constantes/modos en `PascalCase` cuando representan un tipo (ej. `Compact`, `Hover`, `Expanded`).

## Organización de archivos

- Un componente = un archivo. Nada de archivos con múltiples componentes de alto nivel salvo `component X: ...` inline cuando es un sub-elemento privado y pequeño (ver ejemplo en `PlayerControl.Reference.qml`).
- Máximo recomendado: ~150 líneas por archivo. Si se acerca a 300, dividir.

## Estado y configuración

- **Nunca** hardcodear números mágicos en componentes visuales. Todo valor ajustable va a `Core/AuroraConfig.qml`.
- **Nunca** duplicar estado. Si un dato ya vive en `AuroraState`, los componentes lo leen de ahí — no mantienen copias locales.
- Los componentes no escriben directamente en `AuroraState`; lo hacen a través de funciones expuestas por un Provider (ej. `AuroraPlayerProvider.togglePlaying()`).

## Comentarios

- Cabecera de módulo con formato de bloque (ver `AuroraConfig.qml`, `AuroraState.qml`) para archivos "Core" o "Providers":
  ```qml
  /*
   * File        : NombreArchivo.qml
   * Module      : Core | Providers | Components
   * Component   : Descripción corta
   * Version     : 0.1.0-dev
   */
  ```
- Comentarios de "por qué", no de "qué". El código ya dice qué hace; el comentario explica la decisión detrás (ver ejemplos en `AuroraAudioProvider.qml`).

## Bindings y optional chaining

- Usar `?.` y `??` al leer de fuentes externas que pueden ser null (ej. `player?.trackTitle`), siguiendo el patrón ya usado en `AuroraPlayerProvider`.

## Animaciones

- Duraciones siempre desde `AuroraConfig` (`fastAnimation`, `normalAnimation`, `slowAnimation`), nunca valores sueltos.

## QML general

- `pragma Singleton` para todo lo que viva en `Core/` y `Providers/`.
- Imports relativos (`"../Core"`) para módulos internos de Aurora; imports de `qs.*` para el host (Quickshell/end-4 modules).
