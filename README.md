# Aurora

Aurora es un widget multimedia para **Quickshell** con identidad propia. Combina MPRIS para reproducción y metadata, PipeWire para estado del audio del sistema y Cava para el espectro opcional.

## Objetivo

Aurora nació del estudio de arquitecturas de Quickshell y End-4. El objetivo es aprender de esos patrones sin depender de End-4/ii en el runtime: Aurora mantiene su propia arquitectura, API y sistema de distribución.

El contexto conceptual del proyecto — identidad, filosofía e ideas — está separado de la especificación técnica en [`Project/`](./Project/).

## Funciones actuales

- MPRIS para Spotify, MPV, VLC, navegadores y otros reproductores compatibles.
- Deduplicación de fuentes que representan el mismo audio.
- Compact / Hover / Expanded.
- Espectro con Cava y respuesta configurable.
- Integración observacional con PipeWire mediante la API oficial de Quickshell.
- Presets opcionales de EasyEffects con advertencia de ownership.
- Cola e historial de sesión propios de Aurora por fuente.
- Reproducción asistida cuando la fuente expone `next()` mediante MPRIS.
- Letras planas y sincronizadas mediante un Provider desacoplado.
- Sistema de plugins externo.
- Temas runtime seleccionables desde terminal, persistidos fuera del código de Aurora.

La cola de Aurora no depende de `org.mpris.MediaPlayer2.Playlists`: una fuente puede no exponer una playlist seleccionable. Aurora conserva su propio historial/cola y solo solicita acciones que la fuente realmente soporte.

## Instalación

```bash
git clone https://github.com/user124-dev/Aurora.git
cd Aurora
chmod +x install.sh aurora-doctor aurora-theme
./install.sh
```

El instalador coloca Aurora en `~/.config/quickshell/Aurora` y crea comandos de usuario en `~/.local/bin`:

```bash
qs -c Aurora
aurora-doctor
aurora-theme list
aurora-theme set aurora
```

Importante: `git pull` actualiza el repositorio fuente (`~/Downloads/Aurora` en un desarrollo local), mientras `qs -c Aurora` ejecuta la copia instalada en `~/.config/quickshell/Aurora`. Después de actualizar el repositorio hay que ejecutar `./install.sh` para que el runtime instalado reciba los cambios.

## Temas

Aurora incluye cuatro paletas base:

- `aurora` — negro profundo y beige neutro, pensada como identidad principal.
- `midnight` — azul oscuro/negro.
- `paper` — clara y neutra.
- `nebula` — oscura y cálida.

El cambio se puede hacer en caliente con `aurora-theme set <tema>`. La preferencia se guarda en `~/.config/aurora/theme.json`, separada del runtime técnico.

## Dependencias

### Clave

- **Quickshell >= 0.2.0** — necesario para ejecutar Aurora.

### Opcionales

- **Cava** — espectro de audio.
- **EasyEffects** — presets de efectos/ecualización.
- **curl** — backend inicial de letras y cache de carátulas remotas.

Si una dependencia opcional no está disponible, Aurora conserva las demás funciones y degrada únicamente la capacidad correspondiente.

## Diagnóstico

```bash
./aurora-doctor
```

Doctor es read-only y audita el entorno y el repositorio: entrypoint, estructura, documentación, imports host-specific, MPRIS, PipeWire, Cava, EasyEffects, instalador, ShellCheck, estado Git y coherencia del Blueprint.

Las referencias históricas a módulos privados de End-4/ii dentro de `Blueprint/` o `Research/` pueden aparecer como advertencias. Lo que bloquea el runtime son las dependencias host-specific dentro del código ejecutable.

## Arquitectura

```text
Aurora
├── shell.qml
├── Core/
├── Components/
├── Providers/
│   ├── AuroraMprisController.qml
│   ├── AuroraPlayerProvider.qml
│   ├── AuroraAudioProvider.qml
│   ├── AuroraPipewireProvider.qml
│   ├── AuroraLyricsProvider.qml
│   └── AuroraEqualizerProvider.qml
├── Session/
│   └── AuroraSessionQueue.qml
├── Themes/
├── Assets/
├── Blueprint/               # documentación técnica
├── Project/                 # identidad, filosofía e ideas
├── aurora-doctor
└── aurora-theme
```

Core y Components no conocen APIs privadas de End-4/ii. MPRIS y PipeWire se consumen mediante APIs oficiales de Quickshell; Cava, EasyEffects y el backend de letras son integraciones opcionales.

## Compatibilidad

Spotify, MPV, VLC y navegadores se consideran primero fuentes MPRIS. Un plugin específico solo se justifica cuando una aplicación ofrece una capacidad que MPRIS no expone.

Aurora no afirma soporte para una fuente hasta que exista una integración real y una prueba verificable.

## Documentación técnica

La especificación está en [`Blueprint/`](./Blueprint/):

- [`ARCHITECTURE.md`](./Blueprint/ARCHITECTURE.md)
- [`API.md`](./Blueprint/API.md)
- [`DATAFLOW.md`](./Blueprint/DATAFLOW.md)
- [`PROVIDERS.md`](./Blueprint/PROVIDERS.md)
- [`INSTALL.md`](./Blueprint/INSTALL.md)
- [`DECISIONS.md`](./Blueprint/DECISIONS.md)
- [`DECISIONS_CURRENT.md`](./Blueprint/DECISIONS_CURRENT.md)
- [`ROADMAP.md`](./Blueprint/ROADMAP.md)

## Contexto del proyecto

Los documentos que no forman parte del contrato técnico están en [`Project/`](./Project/):

- [`PHILOSOPHY.md`](./Project/PHILOSOPHY.md)
- [`OURS.md`](./Project/OURS.md)
- [`IDEAS.md`](./Project/IDEAS.md)

## Estado

**Work in Progress — etapa Runtime, Distribution & Media Experience.**

La arquitectura standalone ya está establecida. Las siguientes iteraciones se centran en experiencia multimedia avanzada, persistencia opcional de sesión, backends de letras y control seguro de audio.

## Licencia

MIT — ver [`LICENSE`](./LICENSE).
