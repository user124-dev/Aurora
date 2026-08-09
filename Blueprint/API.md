# API de Aurora

Aurora separa la API de estado de la implementación de los Providers. Los componentes visuales no deben importar Providers ni servicios del host.

## `Core/AuroraState.qml`

Fuente única del estado de runtime:

- `connected`
- `playerName`
- `players`
- `playbackState`
- `title`, `artist`, `album`
- `coverArt`
- `duration`, `position`, `progress`
- `canSeek`
- `spectrumLevel`, `spectrumLevels`
- `widgetMode`
- `equalizerAvailable`, `equalizerPresets`, `currentPreset`

Las acciones públicas son señales:

```qml
AuroraState.togglePlaying()
AuroraState.next()
AuroraState.previous()
AuroraState.seek(fraction)
AuroraState.toggleShuffle()
AuroraState.cycleRepeat()
AuroraState.selectPlayer(identity)
AuroraState.setPreset(name)
```

Los componentes llaman estas acciones. `AuroraPlayerProvider` las escucha mediante `Connections`.

## `Core/AuroraConfig.qml`

Configuración estática de Aurora: tamaños, espaciados, animaciones, espectro, deduplicación y fuentes.

Propiedades de fuentes:

| Propiedad | Default | Función |
|---|---:|---|
| `mergeDuplicatePlayers` | `true` | Deduplica entradas MPRIS que representan el mismo audio. |
| `sourcePriority` | `[]` | Prioridad opcional para selección automática. |
| `autoSwitchEnabled` | `false` | Activa selección automática por prioridad. |
| `rememberLastSource` | `false` | Persiste la última fuente seleccionada. |

El modo de tema predeterminado es `themeAurora`, porque el runtime standalone no depende de ningún tema externo.

## `Providers/AuroraMprisController.qml`

Adaptador oficial de MPRIS.

Utiliza:

```qml
import Quickshell.Services.Mpris
```

y expone a Aurora una interfaz pequeña y estable:

- `players`
- `activePlayer`
- `trackChanged()`
- `activePlayerChanged()`

La selección automática toma un reproductor que esté reproduciendo cuando existe; si no, usa el primer reproductor disponible. Esta política puede evolucionar sin cambiar los componentes.

## `Providers/AuroraPlayerProvider.qml`

Único punto de contacto de Aurora con `AuroraMprisController`.

Responsabilidades:

- sincronizar metadata y timeline;
- seleccionar y deduplicar reproductores;
- ejecutar controles MPRIS;
- mantener `AuroraState`.

No debe importar módulos específicos del host ni servicios externos a la API pública de Aurora.

## `Providers/AuroraAudioProvider.qml`

Usa `cava` como fuente opcional del espectro. Si Cava no está instalado o no puede ejecutarse, Aurora conserva el widget multimedia y deja el espectro en su fallback visual.

## `Providers/AuroraThemeProvider.qml`

El runtime standalone usa `Themes/Default/Theme.qml`. Los adaptadores de temas de hosts externos podrán añadirse posteriormente sin modificar Core ni Components.

## `Providers/AuroraEqualizerProvider.qml`

Nivel A: descubre y carga presets de EasyEffects (`easyeffects -l <preset>`).
Si EasyEffects no está instalado, `AuroraState.equalizerAvailable` queda en
`false` y Aurora conserva el resto de sus funciones sin cambios - misma
degradación opcional que Cava.

## Convención de componentes

```qml
text: AuroraState.title || "Untitled"

onClicked: AuroraState.togglePlaying()
```

Los componentes no deben hacer esto:

```qml
AuroraPlayerProvider.togglePlaying()
```

ni importar directamente MPRIS, Cava o APIs de un compositor.
