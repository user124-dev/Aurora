# Fuentes multimedia

Aurora usa una estrategia **MPRIS-first**. La fuente de reproducción se abstrae antes de llegar a la UI, de modo que Spotify, MPV, VLC y navegadores no requieren componentes visuales separados.

## Flujo vigente

```text
Aplicación
    │
    ▼
MPRIS (Quickshell.Services.Mpris)
    │
    ▼
AuroraMprisController
    │
    ▼
AuroraPlayerProvider
    │
    ▼
AuroraState
    │
    ▼
Components
```

PipeWire, Cava, EasyEffects y el backend de letras son capas complementarias; no sustituyen al contrato de reproducción MPRIS.

## Identidad de fuente

La identidad de una fuente debe ser estable y separarse de su nombre de presentación. El estado normalizado puede crecer hacia:

```text
source.id
source.name
source.kind
source.backend
source.capabilities
source.connected
```

No se debe codificar `Spotify`, `Firefox`, `mpv` o `VLC` dentro de Components para resolver diferencias de integración.

## Capacidades

Las operaciones deben estar gobernadas por capacidades reales:

- play/pause;
- next/previous;
- seek;
- shuffle;
- repeat;
- selección de playlist, si la fuente realmente la expone;
- metadata extendida;
- carátula;
- letras;
- información específica del backend.

Si una fuente no soporta una operación, Aurora debe degradar la UI y explicar el motivo en lugar de simularla.

## Adapters específicos

Los adapters específicos se reservan para capacidades que MPRIS no pueda expresar. Se ubicarán en `Providers/Sources/` y deberán traducir sus datos al contrato de Aurora.

```text
Providers/
├── AuroraMprisController.qml
├── AuroraPlayerProvider.qml
└── Sources/
    └── <FutureSourceAdapter>.qml
```

No se crean adapters solo por el nombre de una aplicación. Un adapter requiere una capacidad concreta, un contrato documentado y una prueba verificable.

## Plugins y fuentes

Un plugin externo puede enriquecer la identidad de una fuente —por ejemplo, distinguir Firefox de otro navegador— sin convertirse en el reproductor principal. El plugin escribe datos normalizados en `AuroraState.plugins` y no modifica directamente Components.

## Compatibilidad futura

Esta estructura deja preparado el proyecto para añadir fuentes especializadas, nuevos backends, detección de navegadores y capacidades multimedia sin reescribir `AuroraPlayer`, `AuroraExpandedView` ni el resto de la UI.
