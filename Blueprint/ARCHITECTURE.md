# Arquitectura de Aurora

Aurora es un widget multimedia para Quickshell con tres modos de UI: Compact, Hover y Expanded. El proyecto se distribuye como configuración standalone y mantiene una arquitectura reutilizable.

## Estructura

```text
Aurora/
├── shell.qml                 # Entry point standalone
├── Assets/                   # Recursos estáticos
├── Blueprint/                # Especificación y decisiones técnicas
├── Project/                  # Contexto no técnico: identidad, filosofía e ideas
├── Components/               # UI
│   ├── Layout/               # Root + Compact / Hover / Expanded
│   └── Media/                # UI especializada
├── Core/                     # Estado, configuración, tema y plugins
├── Providers/                # MPRIS, PipeWire, Cava, EasyEffects, letras
├── Session/                  # Cola e historial propios de Aurora
├── Research/                 # Material de estudio; no es runtime
├── Examples/                 # Ejemplos; no se cargan automáticamente
├── Themes/                   # Temas incluidos
└── install.sh                # Instalador / actualizador
```

## Runtime standalone

```text
qs -c Aurora
      │
      ▼
shell.qml → PanelWindow → AuroraPlayer
                            │
                ┌───────────┼───────────┐
                ▼           ▼           ▼
             Compact      Hover      Expanded
```

El entrypoint solo crea la ventana y carga el widget. No contiene lógica multimedia.

## Dirección de dependencias

```text
                 Quickshell / estándares
                          │
             ┌────────────┼─────────────┐
             │            │             │
            MPRIS      PipeWire      Theme
             │            │             │
             ▼            ▼             ▼
      AuroraMpris    AuroraPipewire  AuroraTheme
       Controller       Provider       Provider
             │            │
             ▼            │
      AuroraPlayer        │
        Provider          │
             │            │
             └──────┬─────┘
                    ▼
               AuroraState
                 /      \
                /        \
               ▼          ▼
        SessionQueue     Components
             │              │
             ▼              ▼
       Queue/History     Compact/Hover/Expanded

Cava ──► AuroraAudioProvider ──► AuroraState.spectrumLevels
EasyEffects ──► AuroraEqualizerProvider ──► AuroraState effects state
Lyrics backend ──► AuroraLyricsProvider ──► AuroraState lyrics state
```

Los componentes visuales no importan servicios del host. `AuroraPlayer.qml` es el bootstrap controlado que inicializa los servicios globales.

## Principio de integración

Quickshell es la dependencia central. Cuando ofrece una API oficial suficiente, Aurora la utiliza antes de recurrir a herramientas externas.

- `Quickshell.Services.Mpris` para reproductores y metadata.
- `Quickshell.Services.Pipewire` para el grafo y estado del audio del sistema.
- `Quickshell.Io` para procesos externos que siguen siendo necesarios.
- Cava para muestras de espectro en el baseline actual.
- EasyEffects como integración opcional de efectos/presets.
- Un Provider de letras desacoplado para evitar que el backend de letras entre en Core o Components.

## Core

### `AuroraState`

Única fuente de verdad del estado de runtime: reproductor seleccionado, metadata, timeline, reproducción, capacidades MPRIS, espectro, PipeWire, fuentes, equalizador, sesión, letras y plugins.

Las acciones públicas siguen siendo señales y los Providers correspondientes las escuchan mediante `Connections`.

### `AuroraConfig`

Contiene tamaños, espaciados, animaciones, parámetros del espectro, tolerancias MPRIS, políticas de audio, selección de fuentes y configuración de las superficies opcionales de sesión y letras.

### `AuroraTheme`

Contrato visual consumido por Components. `AuroraThemeProvider` es el escritor de runtime.

## Providers

### `AuroraMprisController`

Adaptador sobre `Quickshell.Services.Mpris`. Mantiene una interfaz estable para Aurora y mejora la detección de cambios usando identidad D-Bus y el identificador de pista cuando están disponibles.

### `AuroraPlayerProvider`

Único punto de contacto de Aurora con MPRIS. Sincroniza metadata, timeline, selección, deduplicación, capacidades y controles. Spotify, MPV, VLC y navegadores entran primero por MPRIS.

### `AuroraPipewireProvider`

Adaptador observacional sobre `Quickshell.Services.Pipewire`. Publica disponibilidad, salida predeterminada, volumen/mute y streams. No modifica routing ni volumen todavía.

### `AuroraAudioProvider`

Ejecuta Cava cuando está disponible y transforma sus muestras en `AuroraState.spectrumLevels` con normalización y sensibilidad configurables.

### `AuroraThemeProvider`

En standalone usa `Themes/Default/Theme.qml`.

### `AuroraEqualizerProvider`

Integra de forma opcional presets de EasyEffects. La gestión activa del estado global requiere snapshot/restore y detección de cambios externos antes de habilitarse.

### `AuroraLyricsProvider`

Adapter opcional para letras. El backend inicial es LRCLIB y puede devolver letra plana o sincronizada. El Provider convierte timestamps LRC en líneas internas y actualiza la línea activa según `AuroraState.position`.

El backend de letras es intercambiable y no es una dependencia del reproductor.

## Session

### `AuroraSessionQueue`

Es una capa propia de Aurora, no una playlist MPRIS.

Mantiene por fuente:

- cola de sesión;
- historial de sesión;
- snapshots de metadata;
- estado de una solicitud de reproducción asistida.

La cola no afirma controlar la playlist interna del reproductor. Cuando una fuente solo ofrece `next()`, Aurora solicita el siguiente elemento y verifica el metadata resultante. Si no coincide, informa que la fuente controla la selección.

Esto permite una experiencia consistente entre Spotify, MPV, VLC y navegadores sin exigir `org.mpris.MediaPlayer2.Playlists`.

## Audio y efectos

```text
MPRIS       → qué está reproduciéndose
PipeWire    → cómo está conectado el audio del sistema
Cava        → muestras para el espectro
EasyEffects → procesamiento de efectos
Lyrics      → metadata textual externa
Session     → cola/historial propios de Aurora
```

Las operaciones que modifiquen el sistema deberán tener ownership explícito y restore seguro. Aurora nunca debe resetear ciegamente la configuración del usuario.

## Compatibilidad

Aurora depende de APIs generales de Quickshell y estándares multimedia. El runtime está diseñado para funcionar standalone sin depender de End-4/ii.

Spotify, MPV, VLC y navegadores son fuentes MPRIS de primera clase mientras publiquen las capacidades necesarias. Los plugins específicos solo se justifican cuando MPRIS no expone la capacidad requerida.

## Plugins

`AuroraPluginRegistry` descubre plugins externos en `$XDG_CONFIG_HOME/aurora/plugins/<id>/plugin.qml`. Los plugins permanecen fuera del payload de Aurora.

## Actualizaciones

`install.sh` administra el payload completo de Aurora. Si detecta una instalación previa, crea un backup, instala el payload nuevo y valida el resultado.

## Herramientas

`aurora-doctor` es read-only y comprueba instalación, Quickshell, MPRIS, PipeWire, Cava, EasyEffects, entorno gráfico, aislamiento del host y documentación.
