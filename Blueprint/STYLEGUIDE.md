# Guía de estilo — Aurora

Convenciones de código QML usadas en el proyecto. El objetivo es que cualquier colaborador pueda modificar Aurora sin pelear contra estilos inconsistentes.

## Nombres

- Prefijo `Aurora` en singletons globales: `AuroraState`, `AuroraConfig`, `AuroraPlayerProvider`.
- Componentes visuales también llevan el prefijo `Aurora`: `AuroraSpectrum.qml`, `AuroraControls.qml`, `AuroraCover.qml`, `AuroraInfo.qml`.
- Propiedades en `camelCase`. Los identificadores de configuración usan `camelCase`, incluidos los modos (`compact`, `hover`, `expanded`) y temas (`themeAurora`, `themeSystem`).

## Organización de archivos

- Un componente = un archivo. Nada de archivos con múltiples componentes de alto nivel salvo componentes inline privados y pequeños.
- Máximo recomendado: ~150 líneas por archivo. Si se acerca a 300, evaluar una división por responsabilidad real en vez de dividir artificialmente.

## Estado, configuración y acciones

- **Nunca** hardcodear números mágicos en componentes visuales. Todo valor ajustable va a `Core/AuroraConfig.qml`.
- **Nunca** duplicar estado. Si un dato ya vive en `AuroraState`, los componentes lo leen de ahí y no mantienen copias del mismo estado.
- Los componentes visuales no escriben directamente en `AuroraState`.
- Las acciones públicas se invocan mediante señales de `AuroraState`, por ejemplo `AuroraState.togglePlaying()` o `AuroraState.seek(fraction)`. `AuroraPlayerProvider` escucha esas señales y ejecuta la operación sobre la fuente MPRIS seleccionada.
- El root `Components/Layout/AuroraPlayer.qml` es una excepción controlada: puede importar Providers únicamente para inicializarlos una vez como bootstrap del widget. No debe convertirse en una segunda capa de lógica de negocio.

## Comentarios

- Cabecera de módulo con formato de bloque para archivos de `Core`, `Providers` y `Components/Layout`.
- Comentarios de "por qué", no de "qué". El código ya dice qué hace; el comentario explica la decisión detrás.

## Bindings y optional chaining

- Usar `?.` y `??` al leer de fuentes externas que pueden ser null, siguiendo el patrón usado en `AuroraPlayerProvider`.

## Animaciones

- Duraciones siempre desde `AuroraConfig` (`fastAnimation`, `normalAnimation`, `slowAnimation`), nunca valores sueltos.

## QML y aislamiento del host

- `pragma Singleton` para todo lo que viva en `Core/` y `Providers/` cuando sea un servicio global; `Components/` contiene instancias visuales normales.
- Imports relativos (`"../Core"`) para módulos internos de Aurora.
- Los Providers pueden importar APIs de infraestructura de Quickshell y otros servicios externos cuando corresponda.
- `Core/` y los componentes visuales no importan módulos específicos de un host ni singletons externos.
- La API oficial de Quickshell (`Quickshell`, `Quickshell.Services.Mpris`, `Quickshell.Io`, etc.) no se considera un `qs.*` host-specific import. La regla es evitar módulos privados de configuraciones externas como End-4/ii, no evitar la API pública de Quickshell que Aurora necesita para ejecutarse.
