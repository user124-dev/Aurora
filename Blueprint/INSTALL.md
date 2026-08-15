# Instalación y distribución

## Objetivo

Aurora se distribuye como una configuración standalone de Quickshell. La instalación normal debe requerir únicamente:

```bash
git clone https://github.com/user124-dev/Aurora.git
cd Aurora
./install.sh
```

El destino oficial es `$XDG_CONFIG_HOME/quickshell/Aurora`, normalmente `~/.config/quickshell/Aurora`.

## Dependencias

### Clave

**Quickshell >= 0.2.0**.

Si falta, `install.sh` pregunta antes de instalarlo. Si el usuario rechaza la dependencia clave, la instalación termina con fallo y no deja una instalación parcial.

### Opcionales

- **Cava** — espectro de audio.
- **EasyEffects** — presets de efectos/ecualización.
- **curl** — cache de carátulas remotas y backend inicial de letras.

Las funciones opcionales degradan de forma independiente. La ausencia de Cava no desactiva MPRIS; la ausencia de EasyEffects no desactiva el reproductor; la ausencia de curl no desactiva reproducción ni el resto de Aurora.

El backend de letras inicial es LRCLIB y es un servicio externo opcional. Aurora no lo considera una dependencia del runtime multimedia principal.

## Actualización y archivos faltantes

`install.sh` trata la instalación de Aurora como un payload administrado. Cada ejecución prepara una copia limpia y sustituye la instalación anterior de forma controlada. Esto permite restaurar archivos faltantes, reemplazar archivos desactualizados, incorporar archivos nuevos y retirar archivos obsoletos.

Antes de reemplazar una instalación existente se crea un backup fechado. Si la activación o la validación falla, el backup anterior se restaura.

La configuración y los plugins externos viven fuera del payload de Aurora y no se eliminan durante una actualización.

## Ejecución

```bash
qs -c Aurora
```

El entrypoint `shell.qml` crea una `PanelWindow` standalone y carga `Components/Layout/AuroraPlayer.qml`.

## Diagnóstico

```bash
./aurora-doctor
```

Doctor comprueba runtime, estructura, aislamiento del host, versión de Quickshell, MPRIS, PipeWire, Cava, sesión gráfica, compositor, instalador y coherencia del Blueprint.

## Plugins

Los plugins externos permanecen fuera de Aurora:

```text
$XDG_CONFIG_HOME/aurora/plugins/<plugin-id>/plugin.qml
```

Una actualización de Aurora no debe sobrescribir código de terceros.

## Compatibilidad

Aurora prioriza APIs de Quickshell y estándares multimedia. MPRIS se consume mediante `Quickshell.Services.Mpris`; PipeWire mediante `Quickshell.Services.Pipewire`; Cava, EasyEffects y el backend de letras son integraciones opcionales.
