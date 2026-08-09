# Providers

Los Providers son la capa de Aurora con permiso para hablar con servicios externos, procesos del sistema o fuentes de infraestructura. Ningún componente visual debe importar servicios externos directamente.

## Principio de integración

Aurora prioriza las APIs oficiales de **Quickshell** cuando cubren una necesidad. La implementación actual soporta Quickshell 0.2.x, por lo que MPRIS y PipeWire se integran mediante `Quickshell.Services.Mpris` y `Quickshell.Services.Pipewire`. Herramientas externas como Cava y EasyEffects solo se usan donde Quickshell no proporciona todavía el dato o la capacidad necesaria.

## AuroraMprisController

Adaptador de infraestructura sobre la API oficial:

```qml
import Quickshell.Services.Mpris
```

Expone a Aurora `players` y `activePlayer` y genera las señales propias `auroraTrackChanged()` y `auroraActivePlayerChanged()` para evitar depender de nombres de señales automáticas de propiedades QML.

MPRIS es la abstracción principal para Spotify, MPV, VLC, navegadores y otros reproductores que publiquen el estándar. Aurora no crea un Provider obligatorio por aplicación.

## AuroraPlayerProvider

Responsabilidad: leer metadata y estado de reproducción mediante `AuroraMprisController`, actualizar `AuroraState` y ejecutar comandos sobre el reproductor seleccionado.

- Deduplica entradas que describen el mismo audio.
- Expone datos planos en `AuroraState.players`.
- Resuelve la fuente seleccionada y puede aplicar prioridad automática si está configurada.
- Sincroniza al iniciar y cuando `AuroraMprisController` informa cambios.
- Hace polling de posición según `AuroraConfig.positionUpdateInterval`.
- Ejecuta `togglePlaying`, `next`, `previous`, `seek`, `toggleShuffle`, `cycleRepeat` y `selectPlayer`.
- No expone objetos MPRIS a Components.
- Respeta las capacidades `canXyz`/`xyzSupported` del reproductor en vez de asumir que todos cumplen MPRIS por igual.

## AuroraPipewireProvider

Adaptador sobre `Quickshell.Services.Pipewire`.

Quickshell 0.2.x proporciona acceso al grafo de PipeWire mediante `Pipewire.nodes`, `links`, `linkGroups`, `defaultAudioSink`, `defaultAudioSource` y `ready`. Los nodos de audio pueden exponer volumen y mute cuando se enlazan mediante `PwObjectTracker`.

Aurora utiliza esta API como fuente primaria para el estado del sistema de audio:

- disponibilidad y sincronización de PipeWire;
- salida de audio predeterminada;
- volumen y mute de la salida predeterminada;
- streams conectados a la salida predeterminada.

El provider es **observacional en esta fase**: no cambia routing ni volumen. Antes de permitir escritura sobre el grafo se debe definir un contrato de ownership, permisos y snapshot/restore.

No se usan `wpctl`, `pw-cli` ni `pactl` como ruta normal de runtime.

## AuroraAudioProvider

Responsabilidad: alimentar `AuroraState.spectrumLevels` con datos de Cava.

- Cava es una dependencia opcional.
- Se ejecuta mientras Aurora está en reproducción y la fuente está disponible.
- Cava entrega el espectro mediante salida `raw` ASCII, actualmente con 48 barras a 60 FPS.
- El provider normaliza y transforma las muestras mediante `AuroraConfig.spectrumMaxRange`, `spectrumNoiseFloor`, `spectrumGamma` y `spectrumGain`, con resultado final limitado a `0..1`.
- `AuroraState.audioAvailable` refleja la disponibilidad de la fuente de muestras del visualizador.
- PipeWire no sustituye a Cava en Quickshell 0.2.x: la detección de picos de audio fue añadida en Quickshell 0.3.0, por lo que no se toma como dependencia mínima de Aurora.
- Si Cava no está disponible o no hay muestras válidas, `AuroraSpectrum` usa su fallback visual.

La cadena conceptual es:

```text
PipeWire → infraestructura/streams/estado del sistema
Cava → muestras → normalización → noise floor → gamma/gain → clamp 0..1 → AuroraState.spectrumLevels
```

## AuroraEqualizerProvider

Responsabilidad actual: descubrir y cargar presets de EasyEffects.

- EasyEffects es una dependencia opcional, detectada antes de usarse.
- Descubre presets de salida leyendo su directorio de configuración.
- Solo presets de salida, nunca de entrada (micrófono).
- Carga un preset con la interfaz disponible de EasyEffects.
- Si EasyEffects no está disponible, el resto del widget sigue funcionando.
- No se considera todavía que Aurora sea propietaria del estado global de efectos.
- El snapshot/restore de efectos queda preparado como una futura capacidad, pero no se activa hasta disponer de una estrategia segura que evite sobrescribir cambios hechos por el usuario u otras aplicaciones mientras Aurora está activa.

## Plugins de reproductores

Spotify, MPV, VLC y navegadores deben entrar primero por MPRIS. Un plugin específico solo se justifica cuando una aplicación ofrece una capacidad que MPRIS no expone.

La regla es:

```text
Aplicación → MPRIS → AuroraPlayerProvider
                     ↓
              AuroraState → UI
```

No se crean Providers centrales obligatorios para cada reproductor.

## Reglas para nuevos Providers

1. Vive en `Providers/` y usa `pragma Singleton` cuando sea un servicio global con estado propio.
2. Prioriza APIs oficiales de Quickshell antes de invocar herramientas externas.
3. No importa APIs privadas de End-4/ii ni otro host concreto como dependencia del runtime base.
4. No expone directamente el objeto externo a Components.
5. Actualiza `AuroraState` mediante un contrato explícito.
6. Documenta polling, fallback y decisiones no obvias.
7. Las dependencias opcionales deben degradar funcionalidad, no romper el widget completo.
8. Las operaciones que escriban en el sistema requieren ownership explícito y, cuando corresponda, snapshot/restore.
9. Si necesita acciones desde Components, deben pasar por el contrato de `AuroraState`, no crear una dependencia directa Component → Provider.
