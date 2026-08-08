# API interna de Aurora

Referencia de las propiedades y funciones públicas que los componentes usan para interactuar con el estado y los providers.

## `Core/AuroraState.qml` (singleton, solo lectura para componentes)

| Propiedad | Tipo | Descripción |
|---|---|---|
| `connected` | bool | Si hay un player MPRIS activo |
| `playerName` | string | Identidad del player activo |
| `players` | list\<object\> | Fuentes MPRIS deduplicadas, alimentada por `AuroraPlayerProvider` — cada entrada es `{identity, title, selected, status}`. `status` es `"Playing"` \| `"Paused"` (reales, leídos de MPRIS) o `"Offline"` (sintético — ver `DECISIONS.md` → "Fase 4: fuentes múltiples avanzadas") |
| `playbackState` | string | `"Playing"` \| `"Paused"` \| `"Stopped"` |
| `title`, `artist`, `album` | string | Metadata de la pista actual |
| `coverArt` | url | URL de la portada |
| `duration`, `position` | int | Timeline en segundos |
| `progress` | real (readonly) | `position / duration`, calculado automáticamente |
| `canSeek` | bool | Si el player permite buscar posición |
| `spectrumLevel` | real | Nivel promedio del espectro actual |
| `spectrumLevels` | list\<real\> | Niveles por barra (alimentado por `AuroraAudioProvider`) |
| `widgetMode` | int | `AuroraConfig.compact/hover/expanded` |

## `Core/AuroraConfig.qml` (singleton, configuración estática)

Valores clave: `bars`, `barSpacing`, tamaños por modo (`compactWidth/Height`, `hoverWidth/Height`, `expandedWidth/Height`), duraciones de animación (`fastAnimation`, `normalAnimation`, `slowAnimation`), `positionUpdateInterval`, delays de hover (`hoverDelay`, `hideDelay`).

**Fuentes (Fase 4):**

| Propiedad | Tipo | Default | Descripción |
|---|---|---|---|
| `mergeDuplicatePlayers` | bool | `true` | Si `computeMeaningfulPlayers()` colapsa fuentes que describen la misma audio dos veces. En `false`, cada entrada cruda de MPRIS es su propia fuente. |
| `sourcePriority` | list\<string\> | `[]` | Orden de preferencia para el auto-switch (coincidencia por substring, no exacta). También funciona como la lista de "fuentes conocidas" para el estado `Offline` sintético. |
| `autoSwitchEnabled` | bool | `false` | Si `true` y `sourcePriority` no está vacío, sigue automáticamente a la fuente de mayor prioridad que esté reproduciendo — solo cuando no hay una selección manual activa. |
| `rememberLastSource` | bool | `false` | Persiste la última fuente seleccionada manualmente a disco (`Quickshell.statePath()`) y la restaura al iniciar. |

## `Providers/AuroraPlayerProvider.qml`

| Función | Descripción |
|---|---|
| `initialize()` | Restaura la última fuente guardada (si `rememberLastSource` está activo), sincroniza el estado inicial y la lista de players. Llamar una vez en `Component.onCompleted`. |
| `syncPlayer()` | Relee el player que se está mostrando (`resolveActivePlayer()`) y actualiza `AuroraState`. |
| `syncPlayerList()` | Reconstruye `AuroraState.players` a partir de `meaningfulPlayers`, con su `status` real, más entradas sintéticas `Offline` para cualquier nombre en `sourcePriority` que no esté en el bus. Se llama solo cuando cambia el conjunto de players o la selección, no en cada tick de posición. |
| `togglePlaying()` | Play/pause del player que se está mostrando. |
| `next()` / `previous()` | Cambia de pista. |
| `seek(fraction)` | `fraction` entre 0.0–1.0; mueve la posición en el timeline. |
| `toggleShuffle()` / `cycleRepeat()` | No-op si el player activo no expone la propiedad (`shuffle`/`loopStatus` son opcionales en MPRIS). |
| `selectPlayer(identity)` | Fija manualmente cuál fuente MPRIS mostrar y controlar; no-op si `identity` corresponde a una entrada `Offline` (no hay player real detrás). Si la fuente desaparece después, vuelve sola a modo automático — ver `DECISIONS.md` → "Fase 4: multi-player MPRIS". |
| `pickByPriority()` | Interno — primer nombre de `sourcePriority` que esté sonando en ese momento. Usado por `resolveActivePlayer()` cuando `autoSwitchEnabled` está activo y no hay selección manual. |
| `saveLastSource(identity)` / `restoreLastSource()` | Internos — persistencia vía `FileView`/`JsonAdapter` en `Quickshell.statePath("aurora-last-source.json")`. No-op si `rememberLastSource` está apagado. |

## `Providers/AuroraAudioProvider.qml`

| Función | Descripción |
|---|---|
| `initialize()` | Log de arranque. El proceso `cava` se activa solo mientras `AuroraState.playbackState === "Playing"`. |

Escribe automáticamente en `AuroraState.spectrumLevels` y `AuroraState.spectrumLevel`. No expone funciones para que los componentes las llamen — es unidireccional (provider → estado → UI).

## `Providers/AuroraThemeProvider.qml`

| Función | Descripción |
|---|---|
| `initialize()` | Resuelve el tema inicial según `AuroraConfig.themeMode` y llama a `resolve()`. |
| `resolve()` | Copia los valores hacia `AuroraTheme`, desde `Theme.qml` (bundled) o desde `Appearance` (host), según `AuroraConfig.themeMode`. Se llama también automáticamente cuando `themeMode` cambia. |

Escribe automáticamente en `AuroraTheme.*`. No es reactivo en modo `ThemeSystem` si el host cambia de tema en caliente después de resolver — ver `DECISIONS.md` → "Abierto / Pendiente".

## Convención de uso desde componentes

```qml
// Lectura
text: AuroraState.title || "Untitled"

// Comando (nunca tocar MprisController directamente)
downAction: () => AuroraPlayerProvider.togglePlaying()
```

> Nota: este documento cubre la API interna actual (v0.1-dev, con la ampliación de fuentes de Fase 4). El punto todavía abierto es la reactividad de `AuroraThemeProvider` en modo `ThemeSystem` — ver `DECISIONS.md` → "Abierto / Pendiente". La cola/playlist por fuente (`org.mpris.MediaPlayer2.Playlists`) sigue sin implementarse — ver `ROADMAP.md` v0.4 y `Ideas.md`.
