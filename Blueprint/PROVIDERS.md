# Providers

Los Providers son la única capa de Aurora con permiso para hablar con servicios externos o procesos del sistema. Ningún componente visual debe importar servicios externos directamente.

## AuroraMprisController

Adaptador de infraestructura sobre la API oficial:

```qml
import Quickshell.Services.Mpris
```

Expone a Aurora `players`, `activePlayer`, `trackChanged()` y `activePlayerChanged()`. Su objetivo es mantener estable el contrato de Aurora aunque cambie la estrategia de selección de reproductor.

## AuroraPlayerProvider

Responsabilidad: leer metadata y estado de reproducción mediante `AuroraMprisController`, actualizar `AuroraState` y ejecutar comandos sobre el reproductor seleccionado.

- Deduplica entradas que describen el mismo audio.
- Expone datos planos en `AuroraState.players`.
- Sincroniza al iniciar y cuando cambia el conjunto de reproductores.
- Hace polling de posición según `AuroraConfig.positionUpdateInterval`.
- Ejecuta `togglePlaying`, `next`, `previous`, `seek`, `toggleShuffle`, `cycleRepeat` y `selectPlayer`.
- No expone objetos MPRIS a Components.

## AuroraAudioProvider

Responsabilidad: alimentar `AuroraState.spectrumLevels` con datos de Cava.

- Cava es una dependencia opcional.
- Se ejecuta mientras hay reproducción.
- Normaliza la salida a 0–1 mediante `AuroraConfig.spectrumMaxRange`.
- Si Cava no está disponible, `spectrumLevels` queda vacío y `AuroraSpectrum` usa su fallback visual.

## AuroraThemeProvider

En standalone utiliza `Themes/Default/Theme.qml`. Los adapters de temas de hosts externos deben vivir fuera de Core y Components.

## AuroraEqualizerProvider (Nivel A)

Responsabilidad: descubrir y cargar presets de EasyEffects.

- EasyEffects es una dependencia opcional, detectada antes de usarse
  (`command -v easyeffects`).
- Descubre presets leyendo directamente `~/.config/easyeffects/output/*.json`
  - la CLI de EasyEffects no expone un comando para listarlos.
- Solo presets de salida (reproducción), nunca de entrada (micrófono).
- Carga un preset con `easyeffects -l <preset>`.
- Si EasyEffects no está disponible, `AuroraState.equalizerAvailable`
  queda en `false` y el resto del widget no se ve afectado.
- No expone control de banda en vivo - eso es Nivel B, exploratorio,
  pendiente de una ruta de GSettings estable entre versiones de
  EasyEffects.

## Reglas para nuevos Providers

1. Vive en `Providers/` y usa `pragma Singleton` cuando sea un servicio global.
2. No importa APIs de End-4/ii.
3. No expone directamente el objeto externo a Components.
4. Actualiza `AuroraState` mediante un contrato explícito.
5. Documenta polling, fallback y decisiones no obvias.
6. Las dependencias opcionales deben degradar funcionalidad, no romper el widget completo.
