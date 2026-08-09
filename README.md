# Aurora

Aurora es un widget multimedia para **Quickshell** con identidad propia. Combina MPRIS para reproducción y metadata con Cava para el espectro opcional, y presenta tres modos visuales: Compact, Hover y Expanded.

## Objetivo

Aurora nació del estudio de arquitecturas de Quickshell y End-4. El objetivo es aprender de esos patrones sin depender de End-4/ii en el runtime: Aurora debe mantener su propia arquitectura, API y sistema de distribución.

## Instalación

La experiencia objetivo es de pocos pasos:

```bash
git clone https://github.com/user124-dev/Aurora.git
chmod +x install.sh aurora-doctor
cd Aurora
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

Si falta y el usuario decide no instalarlo, Aurora continúa funcionando con sus funciones multimedia y su fallback visual del espectro.

## Diagnóstico

```bash
./aurora-doctor
```

Doctor es **read-only** y ahora audita tanto el entorno como el repositorio completo. Comprueba:

- entrypoint standalone;
- estructura y archivos principales de Aurora;
- inventario del repositorio y superficies QML/documentales;
- referencias locales rotas en Markdown;
- referencias a archivos runtime que ya no existen;
- referencias heredadas de End-4/ii y otras APIs obsoletas conocidas;
- imports host-specific en el runtime;
- declaraciones de singleton de Core;
- marcadores `TODO`, `FIXME`, `DEPRECATED` y `OBSOLETE`;
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

Los hallazgos de mantenimiento intencional, como `TODO` en documentación o investigación, se reportan como advertencias y no bloquean automáticamente Aurora. Las referencias obsoletas dentro del runtime y las referencias rotas sí pueden bloquear el diagnóstico.

> **Nota sobre falsos positivos conocidos:** dos categorías de warning son
> esperadas y no requieren acción.
>
> 1. **`qs.modules.common` / `qs.services` en `Blueprint/` y `Research/`** —
>    el check de referencias obsoletas es intencionalmente amplio: marca la
>    cadena en *cualquier* archivo de texto, incluida documentación que
>    menciona esos módulos en tiempo pasado (para explicar que se
>    eliminaron) o material de referencia en `Research/` que nunca formó
>    parte del runtime. Solo es un `[FAIL]` bloqueante si aparece dentro de
>    `Core/`, `Components/`, `Providers/`, `Themes/` o `shell.qml` - ver la
>    lógica en `aurora-doctor` → sección "Repository audit".
> 2. **Marcadores de mantenimiento (`TODO`/`DEPRECATED`/etc.)** — el check
>    usa `grep -i`, así que también captura la palabra española "todo"
>    ("hoy **todo** vive junto...") y menciones de "obsolete"/"deprecated"
>    dentro de documentación que describe qué revisa el propio doctor. Antes
>    de asumir que hay trabajo pendiente, abre el archivo señalado y
>    confirma si es un marcador real en mayúsculas.

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
│   └── AuroraThemeProvider.qml
├── Themes/
├── Assets/
├── Blueprint/
└── aurora-doctor
```

El Core y los Components no conocen APIs de End-4/ii. MPRIS se consume mediante la API oficial de Quickshell y Cava es opcional.

## Compatibilidad

Aurora no intenta duplicar cada compositor. La estrategia es aprovechar las APIs generales de Quickshell y mantener adapters específicos separados.

Esto permite que el mismo núcleo multimedia pueda utilizarse en distintos entornos soportados por Quickshell, aunque determinadas integraciones visuales o de posicionamiento puedan requerir un adapter específico.

## Documentación

La especificación técnica está en [`Blueprint/`](./Blueprint/), especialmente:

- [`ARCHITECTURE.md`](./Blueprint/ARCHITECTURE.md)
- [`API.md`](./Blueprint/API.md)
- [`INSTALL.md`](./Blueprint/INSTALL.md)
- [`DECISIONS.md`](./Blueprint/DECISIONS.md)
- [`PROVIDERS.md`](./Blueprint/PROVIDERS.md)

## Estado

**Work in Progress — etapa Runtime & Distribution.**

La prioridad actual es conseguir una instalación reproducible, standalone, actualizable y diagnosticable antes de ampliar funcionalidades.

## Licencia

MIT — ver [`LICENSE`](./LICENSE).
