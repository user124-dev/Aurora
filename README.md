# Aurora

Aurora es un widget multimedia para **Quickshell** con identidad propia. Combina MPRIS para reproducción y metadata con Cava para el espectro opcional, y presenta tres modos visuales: Compact, Hover y Expanded.

## Objetivo

Aurora nació del estudio de arquitecturas de Quickshell y End-4. El objetivo es aprender de esos patrones sin depender de End-4/ii en el runtime: Aurora mantiene su propia arquitectura, API y sistema de distribución.

El contexto conceptual del proyecto — identidad, filosofía y backlog de ideas — está separado de la especificación técnica en [`Project/`](./Project/).

## Instalación

La experiencia objetivo es de pocos pasos:

```bash
git clone https://github.com/user124-dev/Aurora.git
cd Aurora
chmod +x install.sh aurora-doctor
./install.sh
```

El instalador coloca Aurora en:

```text
~/.config/quickshell/Aurora
```

y puede ejecutarse con:

```bash
qs -c Aurora
```

`install.sh` detecta dependencias, pregunta antes de instalar dependencias clave u opcionales, actualiza instalaciones existentes, restaura archivos faltantes y realiza rollback si una actualización falla.

## Dependencias

### Clave

- **Quickshell >= 0.2.0** — necesario para ejecutar Aurora.

Si falta, el instalador pregunta si desea instalarlo. Si el usuario rechaza una dependencia clave, la instalación falla y no deja una instalación parcial.

### Opcional

- **Cava** — proporciona el espectro de audio.
- **EasyEffects** — habilita la integración opcional de presets del ecualizador.

Si una dependencia opcional no está disponible, Aurora conserva las demás funciones y utiliza su comportamiento de ausencia elegante correspondiente.

## Diagnóstico

```bash
./aurora-doctor
```

Doctor es **read-only** y audita tanto el entorno como el repositorio. Comprueba:

- entrypoint standalone;
- estructura y archivos principales de Aurora;
- inventario del repositorio y superficies QML/documentales;
- referencias locales rotas en Markdown;
- referencias a archivos runtime que ya no existen;
- referencias heredadas de End-4/ii y otras APIs obsoletas conocidas;
- imports host-specific en el runtime;
- declaraciones de singleton de Core;
- marcadores de mantenimiento;
- archivos temporales o backups que puedan ocultar implementaciones duplicadas;
- versión de Quickshell;
- uso de `Quickshell.Services.Mpris`;
- Cava;
- D-Bus/MPRIS;
- sesión Wayland/X11;
- compositor detectado;
- instalador y ShellCheck;
- estado Git local;
- formato de `VERSION`;
- coherencia del Blueprint.

Las referencias históricas a módulos privados de End-4/ii dentro de `Blueprint/` o `Research/` pueden aparecer como advertencias porque esos documentos explican decisiones o material de referencia. Lo que bloquea el runtime son las dependencias host-specific dentro del código ejecutable.

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
│   ├── AuroraThemeProvider.qml
│   └── AuroraEqualizerProvider.qml
├── Themes/
├── Assets/
├── Blueprint/               # documentación técnica
├── Project/                 # identidad, filosofía e ideas
└── aurora-doctor
```

El Core y los Components no conocen APIs privadas de End-4/ii. MPRIS se consume mediante la API oficial de Quickshell y Cava es opcional.

## Compatibilidad

Aurora no intenta duplicar cada compositor. La estrategia actual es aprovechar las APIs generales de Quickshell y estándares multimedia, manteniendo cualquier adapter específico en la frontera de infraestructura.

La compatibilidad futura con otros compositores, shells o ecosistemas es un objetivo arquitectónico, no una afirmación de soporte ya implementado. Un entorno solo se considerará soportado cuando exista una integración real y una prueba verificable.

## Documentación técnica

La especificación técnica está en [`Blueprint/`](./Blueprint/):

- [`ARCHITECTURE.md`](./Blueprint/ARCHITECTURE.md)
- [`API.md`](./Blueprint/API.md)
- [`DATAFLOW.md`](./Blueprint/DATAFLOW.md)
- [`PROVIDERS.md`](./Blueprint/PROVIDERS.md)
- [`INSTALL.md`](./Blueprint/INSTALL.md)
- [`DECISIONS.md`](./Blueprint/DECISIONS.md)
- [`CONVENTIONS.md`](./Blueprint/CONVENTIONS.md)
- [`STYLEGUIDE.md`](./Blueprint/STYLEGUIDE.md)
- [`THEMES.md`](./Blueprint/THEMES.md)

## Contexto del proyecto

Los documentos que no forman parte del contrato técnico están en [`Project/`](./Project/):

- [`PHILOSOPHY.md`](./Project/PHILOSOPHY.md)
- [`OURS.md`](./Project/OURS.md)
- [`IDEAS.md`](./Project/IDEAS.md)

## Estado

**Work in Progress — etapa Runtime & Distribution.**

La prioridad actual es conseguir una instalación reproducible, standalone, actualizable y diagnosticable antes de ampliar funcionalidades.

## Licencia

MIT — ver [`LICENSE`](./LICENSE).
