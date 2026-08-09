# Active architectural decisions

Este documento es la versión normativa y actual de las decisiones de Aurora. `DECISIONS.md` conserva el historial detallado de decisiones anteriores; cuando exista una diferencia, este documento representa el contrato vigente.

## 1. Providers y aislamiento

Los Providers globales que necesitan hijos QML usan `pragma Singleton` con `Singleton` de Quickshell. `Core` permanece libre de dependencias hacia `Providers`.

Los componentes visuales no importan Providers ni APIs privadas de hosts. `Components/Layout/AuroraPlayer.qml` es la única excepción controlada: inicializa los Providers como bootstrap del widget.

La API pública de Quickshell (`Quickshell`, `Quickshell.Services.Mpris`, `Quickshell.Services.Pipewire`, `Quickshell.Io`, etc.) es válida. Las dependencias privadas de configuraciones externas como `qs.services` o `qs.modules.common` no forman parte del runtime de Aurora.

## 2. MPRIS

`AuroraMprisController` usa `Quickshell.Services.Mpris` y expone:

- `players`
- `activePlayer`
- `auroraTrackChanged()`
- `auroraActivePlayerChanged()`

La detección de cambios puede usar identidad D-Bus e identificadores de pista disponibles en `MprisPlayer`. `AuroraPlayerProvider` es la única capa que convierte esos objetos en estado plano para los componentes.

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
- La selección visible utiliza actualmente la identidad humana MPRIS; la identidad D-Bus se usa internamente para mejorar detección de cambios.
- `sourcePriority`, `autoSwitchEnabled` y `rememberLastSource` son opcionales y están desactivados por defecto.
- Spotify, MPV, VLC y navegadores se consideran primero fuentes MPRIS, no Providers centrales separados.

## 5. PipeWire

`AuroraPipewireProvider` usa `Quickshell.Services.Pipewire` como integración primaria con el audio del sistema.

Publica en `AuroraState`:

- `pipewireAvailable`
- `pipewireReady`
- salida predeterminada
- volumen y mute de la salida predeterminada
- streams conectados a la salida

`PwObjectTracker` se utiliza cuando una propiedad de un objeto PipeWire requiere binding. `PwNodeLinkTracker` se utiliza para observar conexiones del sink.

El provider es observacional en esta fase. Aurora no cambia routing ni volumen hasta definir ownership, permisos y recuperación segura.

## 6. Espectro

Cava es la fuente actual del espectro.

```text
Cava → parseo → normalización → noise floor → gamma → gain → clamp 0..1 → AuroraState.spectrumLevels
```

`AuroraState.spectrumLevels` es un arreglo, no un escalar. `AuroraConfig.bars` y `Assets/cava/raw_output_config.txt` deben permanecer sincronizados.

La sensibilidad está controlada por configuración (`spectrumMaxRange`, `spectrumNoiseFloor`, `spectrumGamma`, `spectrumGain`). La ausencia de Cava no rompe el widget.

Quickshell 0.3.0 añade detección de picos de audio en PipeWire, pero Aurora mantiene Cava como fuente mínima del espectro mientras su baseline sea Quickshell 0.2.x.

## 7. Tema

`AuroraThemeProvider` usa actualmente `Themes/Default/Theme.qml` en standalone.

`themeSystem` es una extensión futura. Actualmente mantiene la paleta Aurora y no importa un singleton de apariencia externo.

No se declara soporte de un adapter de compositor o shell hasta que exista implementación y prueba verificable.

## 8. Plugins

Los plugins externos viven fuera del payload de Aurora y se descubren mediante `AuroraPluginRegistry`.

Un plugin solo escribe dentro de `AuroraState.plugins[<id>]` y recibe las superficies de Aurora mediante propiedades inyectadas. No debe depender de rutas relativas hacia la instalación.

## 9. EqualizerProvider y ownership de efectos

`AuroraEqualizerProvider` integra EasyEffects de forma opcional y actualmente se limita a presets de salida.

Cuando Aurora carga activamente un preset, `AuroraState.effectsManaged` y `AuroraState.effectsWarning` indican que Aurora está interviniendo en el procesamiento del sistema. La UI debe mostrar una advertencia no bloqueante.

La edición de bandas en vivo y el snapshot/restore automático permanecen fuera del contrato hasta disponer de una interfaz estable para identificar el estado original y detectar cambios externos. Aurora nunca debe resetear ciegamente EasyEffects al cerrar.

## 10. Views

`AuroraPlayer.qml` selecciona una de tres Views:

- `AuroraCompactView`
- `AuroraHoverView`
- `AuroraExpandedView`

El root no debe recuperar la lógica visual monolítica anterior.

## 11. Compatibilidad futura

La compatibilidad con otros compositores, shells o ecosistemas es una meta arquitectónica, no una lista de integraciones existentes.

Los adapters futuros deben permanecer en la frontera de infraestructura y no introducir dependencias del host en `Core` ni en los componentes visuales.

## 12. Documentación

`Blueprint/` es exclusivamente técnico.

`Project/` contiene identidad, filosofía y backlog conceptual.

Cuando una idea de `Project/IDEAS.md` se implementa, su contrato técnico debe pasar a `Blueprint/API.md`, `Blueprint/PROVIDERS.md`, este documento u otro documento técnico apropiado.
