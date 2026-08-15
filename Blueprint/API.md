# API de Aurora

Aurora separa la API de estado de la implementación de los Providers. Los componentes visuales no deben importar servicios del host ni hablar directamente con MPRIS, PipeWire, Cava o EasyEffects.

## `Core/AuroraState.qml`

Fuente única del estado de runtime:

- `connected`, `playerName`, `players`, `playbackState`
- `canGoNext`, `canGoPrevious`, `canSeek`
- `title`, `artist`, `album`, `coverArt`
- `duration`, `position`, `progress`
- `spectrumLevel`, `spectrumLevels`, `audioAvailable`
- estado PipeWire del sistema de audio
- estado de EasyEffects
- estado de sesión: `sessionQueue`, `sessionHistory`, `sessionSource`, `sessionPlaybackStatus`
- estado de letras: `lyricsAvailable`, `lyricsLoading`, `lyricsStatus`, `lyricsPlain`, `lyricsLines`, `lyricsCurrentLine`
- `widgetMode`, `plugins`

`duration` y `position` son valores reales para conservar precisión temporal. `progress` es de solo lectura y queda limitado al rango `0..1`.

Las acciones públicas de reproducción siguen siendo señales:

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

Configuración estática de tamaños, animaciones, espectro, deduplicación, fuentes y superficies opcionales.

La capa de sesión y letras está habilitada como funcionalidad opcional, pero la cola permanece en memoria durante la sesión. La persistencia de sesiones se puede añadir sin cambiar el contrato de la cola.

## `Providers/AuroraMprisController.qml`

Adaptador oficial de MPRIS mediante:

```qml
import Quickshell.Services.Mpris
```

Expone `players`, `activePlayer`, `auroraTrackChanged()` y `auroraActivePlayerChanged()`.

MPRIS es la abstracción principal para Spotify, MPV, VLC, navegadores y otros reproductores que publiquen el estándar. Aurora no crea un Provider obligatorio por aplicación.

## `Providers/AuroraPlayerProvider.qml`

Único punto de contacto con `AuroraMprisController`.

Responsabilidades:

- sincronizar metadata y timeline;
- seleccionar y deduplicar reproductores;
- ejecutar controles MPRIS respetando capacidades `canXyz`/`xyzSupported`;
- exponer `canGoNext` y `canGoPrevious` a `AuroraState`;
- mantener `AuroraState` y el cache estable de carátulas.

Aurora no promete que todos los reproductores puedan seleccionar arbitrariamente una pista externa. El contrato genérico solo permite solicitar `next()`/`previous()` cuando MPRIS lo expone.

## `Session/AuroraSessionQueue.qml`

Capa propia de Aurora para cola e historial por fuente seleccionada.

Cada entrada es un snapshot de metadata:

```text
source, title, artist, album, coverArt, duration, addedAt, id
```

La cola no intenta reemplazar la playlist interna del reproductor. Esto es deliberado: muchos navegadores y reproductores no ofrecen una operación MPRIS estándar para seleccionar cualquier elemento de una playlist.

La reproducción asistida funciona así:

```text
Aurora Queue
    ↓
¿el siguiente elemento es el objetivo?
    ↓ sí
AuroraState.next()
    ↓
MPRIS source
    ↓
Aurora verifica metadata resultante
```

Si la fuente no confirma el elemento solicitado, Aurora lo marca como controlado por la fuente en vez de fingir que reprodujo la entrada correcta.

## `Providers/AuroraLyricsProvider.qml`

Adaptador opcional de letras.

La implementación inicial utiliza **LRCLIB** como backend externo sin API key y solicita la pista por título, artista, álbum y duración. LRCLIB puede devolver letra plana y letra sincronizada; Aurora transforma la segunda a líneas temporizadas y actualiza `AuroraState.lyricsCurrentLine` conforme avanza `position`.

El backend está aislado detrás del Provider para poder sustituirlo o añadir otros servicios sin modificar la UI.

Las letras no son una dependencia del reproductor: si el backend no responde, la pista sigue funcionando normalmente.

## `Providers/AuroraAudioProvider.qml`

Usa Cava como fuente opcional del espectro. Cava entrega muestras mediante raw output; Aurora las normaliza a `0..1` antes de escribir `AuroraState.spectrumLevels`.

PipeWire sigue siendo la integración principal para estado de audio del sistema, mientras Cava permanece como fuente de muestras para el visualizador en la versión actual de Quickshell.

## `Providers/AuroraPipewireProvider.qml`

Usa `Quickshell.Services.Pipewire` para observar salida predeterminada, mute, volumen y streams. No modifica todavía el grafo de PipeWire.

## `Providers/AuroraEqualizerProvider.qml`

Nivel A: descubre y carga presets de EasyEffects (`easyeffects -l <preset>`). Si EasyEffects no está instalado, `AuroraState.equalizerAvailable` queda en `false` y Aurora conserva el resto de sus funciones.

El snapshot/restore global de EasyEffects no se activa todavía; cualquier futura escritura del grafo deberá tener ownership y restore seguro.

## Convención de componentes

```qml
text: AuroraState.title || "Untitled"
onTapped: AuroraState.togglePlaying()
```

Los componentes no deben hacer esto:

```qml
AuroraPlayerProvider.togglePlaying()
```

ni importar directamente MPRIS, Cava, PipeWire, EasyEffects o APIs de un compositor.
