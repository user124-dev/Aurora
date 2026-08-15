# Providers

Los Providers son la capa de Aurora con permiso para hablar con servicios externos, procesos del sistema o fuentes de infraestructura. Ningún componente visual debe importar servicios externos directamente.

## Principio de integración

Aurora prioriza las APIs oficiales de **Quickshell** cuando cubren una necesidad. MPRIS y PipeWire se integran mediante `Quickshell.Services.Mpris` y `Quickshell.Services.Pipewire`. Herramientas externas como Cava y EasyEffects solo se usan donde Quickshell no proporciona todavía el dato o la capacidad necesaria.

## AuroraMprisController

Adaptador sobre la API oficial de MPRIS. Expone `players` y `activePlayer` y genera `auroraTrackChanged()` / `auroraActivePlayerChanged()`.

MPRIS es la abstracción principal para Spotify, MPV, VLC, navegadores y otros reproductores que publiquen el estándar. Aurora no crea un Provider obligatorio por aplicación.

## AuroraPlayerProvider

Responsabilidad: leer metadata y estado de reproducción mediante `AuroraMprisController`, actualizar `AuroraState` y ejecutar comandos sobre el reproductor seleccionado.

- Deduplica entradas que describen el mismo audio.
- Resuelve la fuente seleccionada y puede aplicar prioridad automática.
- Sincroniza metadata, timeline y capacidades MPRIS.
- Expone `canGoNext` y `canGoPrevious` sin exponer el objeto MPRIS a Components.
- Mantiene cache estable de carátulas para fuentes que cambian archivos temporales.
- Respeta `canXyz`/`xyzSupported` en lugar de asumir capacidades.

## AuroraPipewireProvider

Adaptador sobre `Quickshell.Services.Pipewire`. Observa disponibilidad, salida predeterminada, volumen/mute y streams. En esta fase no modifica routing ni volumen.

Antes de permitir escritura sobre el grafo se debe definir ownership, permisos y snapshot/restore.

## AuroraAudioProvider

Alimenta `AuroraState.spectrumLevels` con Cava.

- Cava es opcional.
- Entrega muestras raw ASCII y Aurora las normaliza a `0..1`.
- PipeWire continúa siendo la capa de infraestructura del sistema; Cava sigue siendo la fuente de muestras del visualizador en la versión actual.
- Si Cava no está disponible, el visualizador usa fallback.

## AuroraEqualizerProvider

Responsabilidad actual: descubrir y cargar presets de EasyEffects.

- EasyEffects es opcional.
- Solo se consideran presets de salida.
- Aurora muestra una advertencia cuando realmente carga un preset.
- El snapshot/restore global permanece preparado pero desactivado hasta disponer de una estrategia segura.

## AuroraLyricsProvider

Adaptador opcional para letras. La primera implementación usa LRCLIB como backend sin API key.

Solicita la firma de la pista mediante título, artista, álbum y duración. Puede devolver letra plana o sincronizada. El Provider convierte la letra sincronizada en líneas temporizadas y mantiene el índice de línea activa en `AuroraState`.

La dependencia es blanda: un fallo del backend nunca debe impedir la reproducción ni el funcionamiento del widget.

El backend permanece aislado para permitir futuras fuentes de letras sin modificar Components.

## Session/AuroraSessionQueue

No es un Provider externo: es una capa propia de sesión de Aurora.

Mantiene:

- cola por fuente seleccionada;
- historial por fuente;
- metadata snapshot de cada entrada;
- estado de una solicitud de reproducción asistida.

No intenta implementar `org.mpris.MediaPlayer2.Playlists` como requisito. La reproducción arbitraria de un elemento solo se realizará cuando la fuente exponga una operación compatible; de lo contrario Aurora informa que la fuente controla la selección.

## Plugins de reproductores

Spotify, MPV, VLC y navegadores deben entrar primero por MPRIS. Un plugin específico solo se justifica cuando una aplicación ofrece una capacidad que MPRIS no expone.

```text
Aplicación → MPRIS → AuroraPlayerProvider
                     ↓
              AuroraState → UI
```

## Reglas para nuevos Providers

1. Vive en `Providers/` y usa `pragma Singleton` cuando sea un servicio global con estado propio.
2. Prioriza APIs oficiales de Quickshell antes de herramientas externas.
3. No importa APIs privadas de End-4/ii como dependencia del runtime.
4. No expone directamente el objeto externo a Components.
5. Actualiza `AuroraState` mediante un contrato explícito.
6. Documenta polling, fallback y decisiones no obvias.
7. Las dependencias opcionales deben degradar funcionalidad.
8. Las operaciones que escriban en el sistema requieren ownership explícito y, cuando corresponda, snapshot/restore.
9. Las acciones desde Components pasan por `AuroraState`.
