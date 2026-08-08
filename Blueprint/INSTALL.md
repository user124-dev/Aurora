# Instalación y distribución

## Objetivo

Aurora se distribuye como una configuración standalone de Quickshell. La instalación normal debe requerir únicamente:

```bash
git clone https://github.com/user124-dev/Aurora.git
cd Aurora
./install.sh
```

El destino oficial es `$XDG_CONFIG_HOME/quickshell/Aurora`, normalmente `~/.config/quickshell/Aurora`. Este modelo coincide con la recomendación oficial de Quickshell para configuraciones nombradas. urlDocumentación oficial de distribución de Quickshellhttps://quickshell.org/docs/v0.3.0/guide/distribution/

## Dependencias

### Clave

**Quickshell >= 0.2.0**.

Si falta, `install.sh` pregunta:

```text
Dependencia clave faltante: Quickshell >= 0.2.0
¿Desea instalarla? [Y/n]
```

Si el usuario responde `N`, la instalación termina con fallo y no deja una instalación parcial.

### Opcional

**Cava** proporciona el espectro de audio.

Si falta:

```text
Dependencia opcional faltante: Cava (espectro de audio)
¿Desea instalarla? [Y/n]
```

Responder `N` no cancela Aurora. El reproductor, MPRIS, portada, información y controles continúan disponibles.

El instalador usa el gestor de paquetes disponible cuando es posible y no añade repositorios externos silenciosamente.

## Actualización y archivos faltantes

`install.sh` trata la instalación de Aurora como un payload administrado. Cada ejecución prepara una copia limpia y sustituye la instalación anterior de forma controlada. Esto permite restaurar archivos faltantes, reemplazar archivos desactualizados, incorporar archivos nuevos y retirar archivos obsoletos que ya no pertenecen al payload.

Antes de reemplazar una instalación existente se crea un backup fechado. Si la activación o la validación falla, el backup anterior se restaura.

La configuración y los plugins externos viven fuera del payload de Aurora y no se eliminan durante una actualización.

## Ejecución

Después de instalar:

```bash
qs -c Aurora
```

El entrypoint `shell.qml` crea una `PanelWindow` standalone y carga `Components/Layout/AuroraPlayer.qml`. El entrypoint es deliberadamente pequeño: el widget sigue siendo reutilizable dentro de otra configuración.

## Diagnóstico

Desde el repositorio:

```bash
./aurora-doctor
```

Tras instalar también se crea un enlace en `~/.local/bin/aurora-doctor`.

Doctor comprueba runtime, estructura, aislamiento del host, versión de Quickshell, MPRIS, Cava, sesión gráfica, compositor detectado, instalador y coherencia del Blueprint.

## Plugins

Los plugins externos permanecen fuera de Aurora:

```text
$XDG_CONFIG_HOME/aurora/plugins/<plugin-id>/plugin.qml
```

Una actualización de Aurora no debe sobrescribir código de terceros.

## Compatibilidad

Aurora prioriza APIs de Quickshell y estándares multimedia. MPRIS se consume mediante `Quickshell.Services.Mpris`; Cava es un proveedor opcional del espectro. Las integraciones específicas de compositor deben mantenerse separadas del Core.
