# Arquitectura de Aurora

Este documento describe cómo están organizados los módulos de Aurora y cómo fluyen los datos entre ellos.

## Estructura de carpetas

```
Aurora/
├── Assets/       # Recursos estáticos (config de cava, iconos)
├── Blueprint/    # Documentación de decisiones, filosofía, ideas
├── Components/   # Componentes visuales (AuroraSpectrum, AuroraControls, AuroraCover, AuroraInfo)
├── Core/         # Estado global y configuración (AuroraState, AuroraConfig)
├── Providers/    # Puentes hacia servicios externos (MPRIS, audio)
├── Research/     # Notas y referencias de estudio (End-4, ii)
└── Themes/       # Temas visuales intercambiables
```
## Principios de arquitectura

Aurora sigue cinco principios fundamentales:

1. Single Source of Truth.
2. Separación entre UI y lógica.
3. Componentes desacoplados.
4. Configuración centralizada.
5. Independencia del host.

## Principio: Single Source of Truth

Todo el estado en tiempo real vive en **`Core/AuroraState.qml`** (singleton). Ningún componente visual mantiene su propia copia de datos como `playbackState`, `title` o `spectrumLevels` — todos leen directamente de `AuroraState`.

Toda configuración estática (tamaños, delays, número de barras) vive en **`Core/AuroraConfig.qml`**. Filosofía: "no magic numbers" — cualquier valor ajustable debe salir de aquí.

## Flujo de datos

```
MPRIS (sistema)               cava (proceso externo)
     │                              │
     ▼                              ▼
AuroraPlayerProvider          AuroraAudioProvider
     │                              │
     └──────────────┬───────────────┘
                     ▼
              AuroraState (singleton)
                     │
     ┌───────────────┼───────────────┐
     ▼               ▼               ▼
  Cover.qml       Info.qml      Spectrum.qml      Controls.qml
```

- **`AuroraPlayerProvider`**: único punto de contacto con MPRIS. Lee metadata/estado y expone comandos (`togglePlaying`, `next`, `previous`, `seek`). Los componentes nunca llaman a MPRIS directamente.
- **`AuroraAudioProvider`**: ejecuta `cava` como proceso externo y traduce su salida a `AuroraState.spectrumLevels`. Si `cava` no está instalado, el proceso falla silenciosamente y el espectro cae en una animación idle (ver `Spectrum.qml`).

## Capa visual

`Layout/AuroraPlayer.qml` es el contenedor raíz. Controla el modo del widget (`Compact` / `Hover` / `Expanded`) según hover y tap, y organiza los subcomponentes en un `RowLayout`. Cada subcomponente (`Cover`, `Info`, `Spectrum`, `Controls`) es independiente y solo depende de `AuroraState` y `AuroraConfig` — nunca entre sí directamente.

## Providers vs Components

- **Providers** = lógica, sin UI. Hablan con el sistema (MPRIS, procesos) y escriben en `AuroraState`.
- **Components** = UI pura. Leen de `AuroraState`/`AuroraConfig`, nunca escriben en ellos directamente (excepto interacción de usuario, que pasa por funciones del Provider).

## Temas

Ver [`THEMES.md`](./THEMES.md) para cómo se resuelven los colores y cómo agregar un tema nuevo.

## Referencias de estudio

La carpeta `Research/` contiene versiones de referencia de End-4 (`PlayerControl.Reference.qml`, `MediaControls.Reference.qml`) usadas para entender patrones (no para copiar) antes de escribir el código propio de Aurora.
