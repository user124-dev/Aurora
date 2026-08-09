# Active architectural decisions

Este documento es la versión normativa y actual de las decisiones de Aurora. `DECISIONS.md` conserva el historial detallado de decisiones anteriores; cuando exista una diferencia, este documento representa el contrato vigente.

## 1. Providers y aislamiento

Los Providers globales que necesitan hijos QML usan `pragma Singleton` con `Singleton` de Quickshell. `Core` permanece libre de dependencias hacia `Providers`.

Los componentes visuales no importan Providers ni APIs privadas de hosts. `Components/Layout/AuroraPlayer.qml` es la única excepción controlada: inicializa los Providers como bootstrap del widget.

La API pública de Quickshell (`Quickshell`, `Quickshell.Services.Mpris`, `Quickshell.Io`, etc.) es válida. Las dependencias privadas de configuraciones externas como `qs.services` o `qs.modules.common` no forman parte del runtime de Aurora.

## 2. MPRIS

`AuroraMprisController` usa `Quickshell.Services.Mpris` y expone:

- `players`
- `activePlayer`
- `auroraTrackChanged()`
- `auroraActivePlayerChanged()`

`AuroraPlayerProvider` es la única capa que convierte esos objetos en estado plano para los componentes.

## 3. AuroraState

`AuroraState` es la única fuente de verdad del estado de runtime.

Las acciones públicas son señales y no funciones que importen Providers:

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

Los Providers correspondientes escuchan esas señales mediante `Connections`.

## 4. Multi-player

- `computeMeaningfulPlayers()` deduplica fuentes equivalentes cuando `mergeDuplicatePlayers` está activo.
- `AuroraState.players` expone datos planos.
- `selectPlayer()` fija la fuente seleccionada.
- Los comandos actúan sobre `resolveActivePlayer()`.
- Una fuente desaparecida limpia la selección manual.
- Las entradas `Offline` son sintéticas y no son seleccionables.
- La selección utiliza actualmente `MPRIS identity`, no un supuesto ID único de instancia.
- `sourcePriority`, `autoSwitchEnabled` y `rememberLastSource` son opcionales y están desactivados por defecto.

## 5. Espectro

Cava es la fuente actual del espectro.

```text
Cava → parseo → normalización → noise floor → gamma → gain → clamp 0..1 → AuroraState.spectrumLevels
```

`AuroraState.spectrumLevels` es un arreglo, no un escalar. `AuroraConfig.bars` y `Assets/cava/raw_output_config.txt` deben permanecer sincronizados.

La sensibilidad está controlada por configuración (`spectrumMaxRange`, `spectrumNoiseFloor`, `spectrumGamma`, `spectrumGain`). La ausencia de Cava no rompe el widget.

## 6. Tema

`AuroraThemeProvider` usa actualmente `Themes/Default/Theme.qml` en standalone.

`themeSystem` es una extensión futura. Actualmente mantiene la paleta Aurora y no importa un singleton de apariencia externo.

No se declara soporte de un adapter de compositor o shell hasta que exista implementación y prueba verificable.

## 7. Plugins

Los plugins externos viven fuera del payload de Aurora y se descubren mediante `AuroraPluginRegistry`.

Un plugin solo escribe dentro de `AuroraState.plugins[<id>]` y recibe las superficies de Aurora mediante propiedades inyectadas. No debe depender de rutas relativas hacia la instalación.

## 8. EqualizerProvider

`AuroraEqualizerProvider` integra EasyEffects de forma opcional y actualmente se limita a presets de salida. La edición de bandas en vivo permanece fuera del contrato hasta disponer de una interfaz estable y verificable.

## 9. Views

`AuroraPlayer.qml` selecciona una de tres Views:

- `AuroraCompactView`
- `AuroraHoverView`
- `AuroraExpandedView`

El root no debe recuperar la lógica visual monolítica anterior.

## 10. Compatibilidad futura

La compatibilidad con otros compositores, shells o ecosistemas es una meta arquitectónica, no una lista de integraciones existentes.

Los adapters futuros deben permanecer en la frontera de infraestructura y no introducir dependencias del host en `Core` ni en los componentes visuales.

## 11. Documentación

`Blueprint/` es exclusivamente técnico.

`Project/` contiene identidad, filosofía y backlog conceptual.

Cuando una idea de `Project/IDEAS.md` se implementa, su contrato técnico debe pasar a `Blueprint/API.md`, `Blueprint/PROVIDERS.md`, este documento u otro documento técnico apropiado.
