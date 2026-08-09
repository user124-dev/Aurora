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
├── Providers/                # MPRIS, Cava, EasyEffects y adaptadores de infraestructura
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
Quickshell APIs / estándares
        │
        ├── MPRIS ──► AuroraMprisController ──► AuroraPlayerProvider ──┐
        │                                                               │
        ├── Cava  ──► AuroraAudioProvider ─────────────────────────────┤
        │                                                               ▼
        └── Theme source ──► AuroraThemeProvider ──► AuroraTheme     AuroraState
                                                                        │
                                                                        ▼
                                                                   Components
```

Los componentes visuales no importan Providers ni APIs específicas de un host. `AuroraPlayer.qml` es el único bootstrap controlado y puede inicializar los Providers al cargar el widget.

## Core

### `AuroraState`

Única fuente de verdad del estado de runtime: reproductor seleccionado, metadata, timeline, reproducción, espectro, fuentes MPRIS, equalizador y datos de plugins.

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

Contiene tamaños, espaciados, animaciones, límites y parámetros de respuesta del espectro, tolerancias MPRIS, selección de fuentes y opciones de tema.

### `AuroraTheme`

Contrato visual consumido por los componentes. `AuroraThemeProvider` es el único escritor.

## Providers

### `AuroraMprisController`

Adaptador pequeño sobre `Quickshell.Services.Mpris`. Expone una interfaz estable para Aurora y evita dependencias de módulos privados de un host.

### `AuroraPlayerProvider`

Único punto de contacto de Aurora con el adaptador MPRIS. Sincroniza metadata, timeline, selección, deduplicación y controles.

### `AuroraAudioProvider`

Ejecuta Cava cuando está disponible y transforma sus muestras en `AuroraState.spectrumLevels`, incluyendo la normalización y el procesamiento de sensibilidad configurado.

### `AuroraThemeProvider`

En standalone usa `Themes/Default/Theme.qml`. El modo de tema del sistema existe como punto de extensión, pero actualmente conserva la paleta Aurora y no importa una apariencia de host.

### `AuroraEqualizerProvider`

Integra de forma opcional presets de EasyEffects y publica su disponibilidad y lista de presets mediante `AuroraState`.

## Compatibilidad

### Compatibilidad actual

Aurora depende de las APIs generales de Quickshell y de estándares multimedia, principalmente MPRIS y la fuente de espectro Cava. El runtime actual está diseñado para funcionar como configuración standalone sin depender de End-4/ii.

La funcionalidad multimedia no depende de una API privada de Hyprland, Sway o i3.

### Compatibilidad futura

La arquitectura deja espacio para adapters específicos de entorno cuando exista una integración real que aporte valor y pueda probarse. Estos adapters no deben convertirse en una dependencia del Core ni del contrato básico de reproducción.

El siguiente esquema representa una **dirección futura**, no componentes implementados actualmente:

```text
                    Aurora Core
                        │
                   Quickshell
                        │
             ┌──────────┼──────────┐
             ▼          ▼          ▼
           MPRIS      Audio      Window API
                                    │
                          futuros adapters
```

No se debe documentar un adapter de Hyprland, Sway, i3 u otro compositor como existente hasta que exista código y una prueba verificable.

## Plugins

`AuroraPluginRegistry` descubre plugins externos en:

```text
$XDG_CONFIG_HOME/aurora/plugins/<id>/plugin.qml
```

Los plugins permanecen fuera del payload de Aurora para que una actualización no los sobrescriba.

## Actualizaciones

`install.sh` administra el payload completo de Aurora. Si detecta una instalación previa, crea un backup, instala el payload nuevo y valida el resultado. Un fallo restaura la versión anterior.

Esto permite reparar instalaciones con archivos faltantes y actualizar archivos desfasados sin pedir al usuario una secuencia manual de comandos.

## Herramientas

`aurora-doctor` es una herramienta de diagnóstico read-only. Comprueba la instalación, Quickshell, MPRIS, Cava, entorno gráfico, aislamiento del host y documentación.
