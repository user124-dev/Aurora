# Active architectural decisions

Este documento es la versión normativa y actual de las decisiones de Aurora. `DECISIONS.md` conserva el historial detallado de decisiones anteriores; cuando exista una diferencia, este documento representa el contrato vigente.

## 1. Providers y aislamiento

Los Providers globales que necesitan hijos QML usan `pragma Singleton` con `Singleton` de Quickshell. `Core` permanece libre de dependencias hacia `Providers`.

Los componentes visuales no importan APIs privadas de hosts. `Components/Layout/AuroraPlayer.qml` es la excepción controlada que inicializa los servicios como bootstrap del widget.

La API pública de Quickshell es válida; dependencias privadas de configuraciones externas no forman parte del runtime de Aurora.

## 2. MPRIS

`AuroraMprisController` usa `Quickshell.Services.Mpris`. `AuroraPlayerProvider` es la única capa que convierte objetos MPRIS en estado plano para Components.

## 3. AuroraState

`AuroraState` es la única fuente de verdad del estado de runtime. Las acciones públicas siguen siendo señales escuchadas por Providers.

## 4. Multi-player

Las fuentes se deduplican, se seleccionan mediante identidad humana y pueden usar prioridad automática. Spotify, MPV, VLC y navegadores se consideran primero fuentes MPRIS, no Providers centrales separados.

## 5. PipeWire

`AuroraPipewireProvider` usa `Quickshell.Services.Pipewire` como integración primaria con el audio del sistema. Es observacional hasta definir ownership, permisos y recuperación segura para operaciones de escritura.

## 6. Espectro

Cava es la fuente actual del espectro y sus muestras terminan en `AuroraState.spectrumLevels`. La sensibilidad se controla con configuración y la ausencia de Cava no rompe el widget.

## 7. Tema

`AuroraThemeProvider` usa `Themes/Default/Theme.qml` en standalone. No se declara soporte de adapters de compositor hasta contar con implementación y prueba verificable.

## 8. Plugins

Los plugins externos viven fuera del payload de Aurora y solo escriben dentro de `AuroraState.plugins[<id>]`.

## 9. EqualizerProvider y ownership de efectos

`AuroraEqualizerProvider` integra EasyEffects de forma opcional y actualmente se limita a presets de salida. La UI muestra una advertencia cuando Aurora carga activamente un preset.

El snapshot/restore automático y el control de bandas permanecen fuera del contrato hasta disponer de una estrategia segura que detecte cambios externos y no resetee ciegamente el estado del usuario.

## 10. Views

`AuroraPlayer.qml` selecciona `AuroraCompactView`, `AuroraHoverView` o `AuroraExpandedView`. El root no debe recuperar la lógica visual monolítica anterior.

## 11. Compatibilidad futura

La compatibilidad con otros compositores, shells o ecosistemas es una meta arquitectónica. Los adapters futuros permanecen en la frontera de infraestructura.

## 12. Documentación

`Blueprint/` es exclusivamente técnico. `Project/` contiene identidad, filosofía y backlog conceptual. Cuando una idea de `Project/IDEAS.md` se implementa, su contrato pasa a documentación técnica.

## 13. Cola e historial propios de Aurora

Aurora no depende de `org.mpris.MediaPlayer2.Playlists` para tener una cola usable.

`Session/AuroraSessionQueue.qml` mantiene una cola y un historial de sesión separados por fuente. Las entradas son snapshots de metadata y no representan una propiedad de la playlist interna del reproductor.

La cola puede solicitar el siguiente elemento mediante MPRIS cuando `canGoNext` está disponible y después verifica el metadata resultante. Si la fuente no confirma el elemento solicitado, Aurora informa que la fuente controla la selección. No se simula reproducción arbitraria.

La persistencia de la sesión es futura y no forma parte del contrato actual.

## 14. Letras

`Providers/AuroraLyricsProvider.qml` es un adapter opcional de letras. Su backend inicial es LRCLIB, consultado mediante la firma de título, artista, álbum y duración.

El Provider puede exponer letra plana y sincronizada. Las líneas sincronizadas se convierten a timestamps internos y `AuroraState.lyricsCurrentLine` sigue la posición de reproducción.

La UI nunca debe depender directamente del backend de letras. El backend puede cambiar o desaparecer sin romper reproducción, MPRIS, PipeWire o Cava.
