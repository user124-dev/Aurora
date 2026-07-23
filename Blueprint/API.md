# API interna de Aurora

Referencia de las propiedades y funciones públicas que los componentes usan para interactuar con el estado y los providers.

## `Core/AuroraState.qml` (singleton, solo lectura para componentes)

| Propiedad | Tipo | Descripción |
|---|---|---|
| `connected` | bool | Si hay un player MPRIS activo |
| `playerName` | string | Identidad del player activo |
| `playbackState` | string | `"Playing"` \| `"Paused"` \| `"Stopped"` |
| `title`, `artist`, `album` | string | Metadata de la pista actual |
| `coverArt` | url | URL de la portada |
| `duration`, `position` | int | Timeline en segundos |
| `progress` | real (readonly) | `position / duration`, calculado automáticamente |
| `canSeek` | bool | Si el player permite buscar posición |
| `spectrumLevel` | real | Nivel promedio del espectro actual |
| `spectrumLevels` | list\<real\> | Niveles por barra (alimentado por `AuroraAudioProvider`) |
| `widgetMode` | int | `AuroraConfig.Compact/Hover/Expanded` |

## `Core/AuroraConfig.qml` (singleton, configuración estática)

Valores clave: `bars`, `barSpacing`, tamaños por modo (`compactWidth/Height`, `hoverWidth/Height`, `expandedWidth/Height`), duraciones de animación (`fastAnimation`, `normalAnimation`, `slowAnimation`), `positionUpdateInterval`, delays de hover (`hoverDelay`, `hideDelay`).

## `Providers/AuroraPlayerProvider.qml`

| Función | Descripción |
|---|---|
| `initialize()` | Sincroniza el estado inicial. Llamar una vez en `Component.onCompleted`. |
| `syncPlayer()` | Relee el player activo de MPRIS y actualiza `AuroraState`. |
| `togglePlaying()` | Play/pause del player activo. |
| `next()` / `previous()` | Cambia de pista. |
| `seek(fraction)` | `fraction` entre 0.0–1.0; mueve la posición en el timeline. |

Escucha automáticamente `MprisController.onTrackChanged` y `onActivePlayerChanged` para re-sincronizar sin intervención del componente.

## `Providers/AuroraAudioProvider.qml`

| Función | Descripción |
|---|---|
| `initialize()` | Log de arranque. El proceso `cava` se activa solo mientras `AuroraState.playbackState === "Playing"`. |

Escribe automáticamente en `AuroraState.spectrumLevels` y `AuroraState.spectrumLevel`. No expone funciones para que los componentes las llamen — es unidireccional (provider → estado → UI).

## Convención de uso desde componentes

```qml
// Lectura
text: AuroraState.title || "Untitled"

// Comando (nunca tocar MprisController directamente)
downAction: () => AuroraPlayerProvider.togglePlaying()
```

> Nota: este documento cubre la API interna actual (v0.1-dev). Se actualizará conforme se implemente `AuroraThemeProvider` y el resto de la fuente de datos del espectro (ver `DECISIONS.md`).
