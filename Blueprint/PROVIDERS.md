# Providers

Los Providers son la capa de Aurora con permiso para hablar con servicios externos, procesos del sistema o fuentes de infraestructura. Ningún componente visual debe importar servicios externos directamente.

## AuroraMprisController

Adaptador de infraestructura sobre la API oficial:

```qml
import Quickshell.Services.Mpris
```

Expone a Aurora `players` y `activePlayer` y genera las señales propias `auroraTrackChanged()` y `auroraActivePlayerChanged()` para evitar depender de nombres de señales automáticas de propiedades QML.

Su objetivo es mantener estable el contrato de Aurora aunque cambie la estrategia de selección de reproductor.

## AuroraPlayerProvider

Responsabilidad: leer metadata y estado de reproducción mediante `AuroraMprisController`, actualizar `AuroraState` y ejecutar comandos sobre el reproductor seleccionado.

- Deduplica entradas que describen el mismo audio.
- Expone datos planos en `AuroraState.players`.
- Resuelve la fuente seleccionada y puede aplicar prioridad automática si está configurada.
- Sincroniza al iniciar y cuando `AuroraMprisController` informa cambios.
- Hace polling de posición según `AuroraConfig.positionUpdateInterval`.
- Ejecuta `togglePlaying`, `next`, `previous`, `seek`, `toggleShuffle`, `cycleRepeat` y `selectPlayer`.
- No expone objetos MPRIS a Components.

## AuroraAudioProvider

Responsabilidad: alimentar `AuroraState.spectrumLevels` con datos de Cava.

- Cava es una dependencia opcional.
- Se ejecuta mientras Aurora está en reproducción y la fuente está disponible.
- Cava entrega el espectro mediante salida `raw` ASCII, actualmente con 48 barras a 60 FPS.
- El provider normaliza y transforma las muestras mediante `AuroraConfig.spectrumMaxRange`, `spectrumNoiseFloor`, `spectrumGamma` y `spectrumGain`, con resultado final limitado a `0..1`.
- `AuroraState.audioAvailable` refleja la disponibilidad de la fuente de audio.
- Si Cava no está disponible o no hay muestras válidas, `spectrumLevels` puede quedar vacío y `AuroraSpectrum` usa su fallback visual.
- El número de barras esperado debe coincidir con `AuroraConfig.bars` y `Assets/cava/raw_output_config.txt`.

La cadena conceptual es:

```text
Cava → parseo → normalización → noise floor → gamma/gain → clamp 0..1 → AuroraState.spectrumLevels
```

## AuroraThemeProvider

En standalone utiliza `Themes/Default/Theme.qml` y escribe el contrato `AuroraTheme`. No importa singletons de apariencia de End-4/ii ni otros hosts.

`AuroraConfig.themeSystem` está reservado para un futuro adapter de tema. En el runtime actual, el modo system mantiene la paleta Aurora para conservar el aislamiento standalone.

## AuroraEqualizerProvider (Nivel A)

Responsabilidad: descubrir y cargar presets de EasyEffects.

- EasyEffects es una dependencia opcional, detectada antes de usarse.
- Descubre presets de salida leyendo `~/.config/easyeffects/output/*.json`.
- Solo presets de salida, nunca de entrada (micrófono).
- Carga un preset con la interfaz disponible de EasyEffects.
- Si EasyEffects no está disponible, `AuroraState.equalizerAvailable` queda en `false` y el resto del widget no se ve afectado.
- No expone control de banda en vivo; eso sigue siendo Nivel B y depende de una ruta estable entre versiones de EasyEffects.

## Reglas para nuevos Providers

1. Vive en `Providers/` y usa `pragma Singleton` cuando sea un servicio global con estado propio.
2. No importa APIs privadas de End-4/ii ni otro host concreto como dependencia del runtime base.
3. No expone directamente el objeto externo a Components.
4. Actualiza `AuroraState` mediante un contrato explícito.
5. Documenta polling, fallback y decisiones no obvias.
6. Las dependencias opcionales deben degradar funcionalidad, no romper el widget completo.
7. Si necesita acciones desde Components, deben pasar por el contrato de `AuroraState`, no crear una dependencia directa Component → Provider.
