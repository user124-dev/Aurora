# Arquitectura de Aurora

Aurora es un widget multimedia para Quickshell con tres modos de UI: Compact, Hover y Expanded. El proyecto se distribuye como una configuración standalone y el widget mantiene una arquitectura reutilizable dentro de otras configuraciones.

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
├── Providers/                # MPRIS, PipeWire, Cava, EasyEffects y adapters
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
shell.qml
      │
      ▼
PanelWindow
      │
      ▼
AuroraPlayer
      │
      ├── CompactView
      ├── HoverView
      └── ExpandedView
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
                    │
                    ▼
                Components

Cava ──► AuroraAudioProvider ──► AuroraState.spectrumLevels
EasyEffects ──► AuroraEqualizerProvider ──► AuroraState.effects/equalizer state
```

Los componentes visuales no importan Providers ni APIs específicas de un host. `AuroraPlayer.qml` es el único bootstrap controlado y puede inicializar los Providers al cargar el widget.

## Principio de integración

Quickshell es la dependencia central de Aurora. Cuando Quickshell ofrece una API oficial suficiente, Aurora la utiliza antes de recurrir a herramientas externas.

En la línea 0.2.x esto significa:

- `Quickshell.Services.Mpris` para reproductores y metadata.
- `Quickshell.Services.Pipewire` para el grafo y estado del audio del sistema.
- `Quickshell.Io` para procesos externos que siguen siendo necesarios.
- Cava para muestras de espectro, porque la detección de picos de audio de Quickshell fue añadida posteriormente en 0.3.0.
- EasyEffects como integración opcional de efectos/presets.

## Core

### `AuroraState`

Única fuente de verdad del estado de runtime: reproductor seleccionado, metadata, timeline, reproducción, espectro, estado de PipeWire, fuentes MPRIS, equalizador y datos de plugins.

Las acciones públicas son señales:

```qml
AuroraState.togglePlaying()
AuroraState.next()
AuroraState.previous()
AuroraState.seek(fraction)
AuroraState.toggleShuffle()
AuroraState.cycleRepeat()
AuroraState.selectPlayer(identity)
```

`AuroraPlayerProvider` escucha esas señales y ejecuta las operaciones sobre el reproductor resuelto.

### `AuroraConfig`

Contiene tamaños, espaciados, animaciones, límites y parámetros de respuesta del espectro, tolerancias MPRIS, política de integración de audio, selección de fuentes y opciones de tema.

### `AuroraTheme`

Contrato visual consumido por los componentes. `AuroraThemeProvider` es el único escritor.

## Providers

### `AuroraMprisController`

Adaptador sobre `Quickshell.Services.Mpris`. Mantiene una interfaz estable para Aurora y mejora la detección de cambios usando identidad D-Bus y el identificador de pista cuando están disponibles.

### `AuroraPlayerProvider`

Único punto de contacto de Aurora con el adaptador MPRIS. Sincroniza metadata, timeline, selección, deduplicación y controles. Respeta las capacidades `canXyz` y `xyzSupported` porque la conformidad MPRIS varía entre reproductores.

Spotify, MPV, VLC y navegadores deben entrar primero por MPRIS. Un plugin específico solo se justifica si una aplicación ofrece una capacidad que MPRIS no expone.

### `AuroraPipewireProvider`

Adaptador sobre `Quickshell.Services.Pipewire`.

Actualmente es observacional y publica en `AuroraState`:

- disponibilidad y `ready` de PipeWire;
- salida predeterminada;
- volumen y mute de la salida predeterminada;
- streams conectados a esa salida.

El provider utiliza `PwObjectTracker` cuando necesita propiedades de audio que requieren binding y `PwNodeLinkTracker` para observar conexiones del sink. No modifica routing ni volumen todavía.

### `AuroraAudioProvider`

Ejecuta Cava cuando está disponible y transforma sus muestras en `AuroraState.spectrumLevels`, incluyendo la normalización y el procesamiento de sensibilidad configurado.

PipeWire y Cava no representan la misma capa: PipeWire describe el grafo/estado del audio, mientras Cava aporta las muestras usadas por el visualizador.

### `AuroraThemeProvider`

En standalone usa `Themes/Default/Theme.qml`. El modo de tema del sistema existe como punto de extensión, pero actualmente conserva la paleta Aurora y no importa una apariencia de host.

### `AuroraEqualizerProvider`

Integra de forma opcional presets de EasyEffects y publica su disponibilidad y lista de presets mediante `AuroraState`. Aurora no asume todavía ownership del estado global de EasyEffects. La futura gestión activa deberá incluir snapshot/restore y detección de cambios externos antes de habilitarse.

## Audio y efectos

La arquitectura separa cuatro responsabilidades:

```text
MPRIS       → qué está reproduciéndose
PipeWire    → cómo está conectado el audio del sistema
Cava        → muestras para el espectro
EasyEffects → procesamiento de efectos
```

Esto permite añadir funciones futuras sin convertir `AuroraAudioProvider` en un monolito.

Las operaciones que modifiquen el sistema deberán tener ownership explícito. Si Aurora llega a activar un preset o routing temporal, deberá guardar primero el estado que realmente modificó y restaurarlo únicamente si sigue siendo propiedad de Aurora. Nunca debe resetear ciegamente toda la configuración del usuario al cerrarse.

## Compatibilidad

### Compatibilidad actual

Aurora depende de las APIs generales de Quickshell y de estándares multimedia, principalmente MPRIS y PipeWire, además de Cava y EasyEffects como integraciones opcionales. El runtime está diseñado para funcionar como configuración standalone sin depender de End-4/ii.

La funcionalidad multimedia no depende de una API privada de Hyprland, Sway o i3.

### Compatibilidad futura

La arquitectura deja espacio para adapters específicos de entorno cuando exista una integración real que aporte valor y pueda probarse. Estos adapters no deben convertirse en una dependencia del Core ni del contrato básico de reproducción.

No se debe documentar un adapter de Hyprland, Sway, i3 u otro compositor como existente hasta que exista código y una prueba verificable.

## Plugins

`AuroraPluginRegistry` descubre plugins externos en:

```text
$XDG_CONFIG_HOME/aurora/plugins/<id>/plugin.qml
```

Los plugins permanecen fuera del payload de Aurora para que una actualización no los sobrescriba.

## Actualizaciones

`install.sh` administra el payload completo de Aurora. Si detecta una instalación previa, crea un backup, instala el payload nuevo y valida el resultado. Un fallo restaura la versión anterior.

## Herramientas

`aurora-doctor` es una herramienta de diagnóstico read-only. Comprueba la instalación, Quickshell, MPRIS, PipeWire, Cava, EasyEffects, entorno gráfico, aislamiento del host y documentación.
