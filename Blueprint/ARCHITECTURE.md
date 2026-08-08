# Arquitectura de Aurora

Aurora es un widget de Quickshell con tres modos: Compact, Hover y
Expanded. La arquitectura separa estado, configuración, integración
externa y UI.

## Estructura

```text
Aurora/
├── Assets/       # Recursos estáticos
├── Blueprint/    # Arquitectura, decisiones, API y documentación
├── Components/   # UI pura
│   ├── Layout/   # Compact / Hover / Expanded / raíz
│   └── Media/    # UI especializada de medios
├── Core/         # Estado, configuración, tema y registro de plugins
├── Providers/    # Integración con MPRIS, cava y el tema del host
├── Research/     # Referencias de estudio; no se cargan en runtime
├── Examples/     # Plantillas; no se cargan automáticamente
├── Themes/       # Paletas incluidas
├── Tools/        # Herramientas de desarrollo
└── install.sh    # Instalador
```

## Dirección de dependencias

```text
                    ┌───────────────┐
                    │   Providers   │
                    │ MPRIS / cava  │
                    │  host theme   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  AuroraState  │
                    │   singleton   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  Components   │
                    │      UI       │
                    └───────────────┘

Plugins ──► AuroraPluginRegistry ──► AuroraState.plugins
```

Los componentes no importan Providers ni servicios del host.

Los Providers pueden escribir en `AuroraState`; los componentes solo leen
estado y emiten acciones a través de las señales de `AuroraState`.

## Core

### `AuroraState`

Es la única fuente de verdad del estado de runtime:

- reproductor seleccionado;
- metadata;
- timeline;
- estado de reproducción;
- espectro;
- fuentes MPRIS;
- datos namespaced de plugins.

Las acciones de UI son señales:

```qml
AuroraState.togglePlaying()
AuroraState.next()
AuroraState.previous()
AuroraState.seek(fraction)
AuroraState.toggleShuffle()
AuroraState.cycleRepeat()
AuroraState.selectPlayer(identity)
```

`AuroraPlayerProvider` escucha esas señales y ejecuta la operación contra
el reproductor MPRIS seleccionado.

### `AuroraConfig`

Contiene constantes y opciones estáticas:

- tamaños;
- espaciados;
- animaciones;
- límites del espectro;
- tolerancias de deduplicación;
- fuentes;
- tema.

Los componentes no deben introducir valores de layout o comportamiento
ajustable directamente.

### `AuroraTheme`

Es el contrato visual. Los componentes leen colores y tipografía desde
este singleton.

Solo `AuroraThemeProvider` escribe sus valores.

## Providers

### `AuroraPlayerProvider`

Único punto de contacto con MPRIS.

Responsabilidades:

- sincronizar metadata;
- sincronizar posición;
- seleccionar fuente;
- deduplicar entradas que representan el mismo audio;
- ejecutar controles de reproducción;
- persistir la última fuente cuando está habilitado.

### `AuroraAudioProvider`

Ejecuta cava y transforma sus muestras en:

```qml
AuroraState.spectrumLevels
```

La normalización utiliza `AuroraConfig.spectrumMaxRange`.

### `AuroraThemeProvider`

Es el único archivo que conoce el API de tema del host. Actualmente
mapea `Appearance` del host de referencia.

## Plugins

`AuroraPluginRegistry` descubre automáticamente:

```text
~/.config/aurora/plugins/<id>/plugin.qml
```

El entrypoint recibe por propiedad:

```qml
auroraState
auroraConfig
auroraRegistry
```

Los datos del plugin solo viven en:

```qml
AuroraState.plugins.<id>
```

No se importan plugins desde `Providers/`.

## Layout

`Components/Layout/AuroraPlayer.qml` decide qué vista cargar:

```text
Compact ──► AuroraCompactView
Hover   ──► AuroraHoverView
Expanded ─► AuroraExpandedView
```

`Loader` mantiene activa solamente la vista actual.

## Herramientas

`aurora-doctor` es externo al runtime del widget. Sirve para revisar el
repositorio antes de integrarlo o distribuirlo.

No es una dependencia de Aurora.
