# Arquitectura de Aurora

Aurora es un widget multimedia para Quickshell con tres modos de UI: Compact, Hover y Expanded. El proyecto se distribuye como una configuración standalone, pero el widget sigue siendo reutilizable dentro de otras configuraciones.

## Estructura

```text
Aurora/
├── shell.qml                 # Entry point standalone
├── Assets/                   # Recursos estáticos
├── Blueprint/                # Especificación y decisiones
├── Components/               # UI
│   ├── Layout/               # Root + Compact / Hover / Expanded
│   └── Media/                # UI especializada
├── Core/                     # Estado, configuración, tema y plugins
├── Providers/                # MPRIS, Cava y adaptadores externos
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
        ├── MPRIS ──► AuroraMprisController
        │                    │
        ├── Cava  ──► AuroraAudioProvider
        │                    │
        └── Theme adapter ──┤
                             ▼
                       AuroraState
                             │
                             ▼
                        Components
```

Los componentes no importan Providers ni APIs específicas de un host.

## Core

### `AuroraState`

Única fuente de verdad del estado de runtime: reproductor seleccionado, metadata, timeline, reproducción, espectro, fuentes MPRIS y datos de plugins.

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

`AuroraPlayerProvider` escucha esas señales y ejecuta las operaciones.

### `AuroraConfig`

Contiene tamaños, espaciados, animaciones, límites del espectro, tolerancias MPRIS, selección de fuentes y opciones de tema. El tema standalone predeterminado es el incluido en Aurora.

### `AuroraTheme`

Contrato visual consumido por los componentes. `AuroraThemeProvider` es el único escritor.

## Providers

### `AuroraMprisController`

Adaptador pequeño sobre `Quickshell.Services.Mpris`. Expone una interfaz estable para Aurora y evita dependencias de módulos del host.

### `AuroraPlayerProvider`

Único punto de contacto de Aurora con el adaptador MPRIS. Sincroniza metadata, timeline, selección, deduplicación y controles.

### `AuroraAudioProvider`

Ejecuta Cava cuando está disponible y transforma sus muestras en `AuroraState.spectrumLevels`. Cava es opcional.

### `AuroraThemeProvider`

En standalone usa `Themes/Default/Theme.qml`. Los adaptadores de temas de hosts externos podrán implementarse posteriormente sin modificar Core ni Components.

## Compatibilidad

Aurora no intenta implementar un backend independiente para cada compositor. La estrategia es apoyarse en las APIs generales de Quickshell y mantener los adaptadores específicos separados.

```text
                 Aurora Core
                     │
                 Quickshell
          ┌──────────┼──────────┐
          ▼          ▼          ▼
        MPRIS     PipeWire    Window API
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
                Hyprland       Sway           i3
                 adapter       adapter        adapter
```

La funcionalidad multimedia básica no debe depender de Hyprland, Sway o i3.

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
