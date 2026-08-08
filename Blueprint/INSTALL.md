# Instalación

## Instalación rápida

Desde la raíz de Aurora:

```bash
./install.sh
```

Por defecto instala Aurora en:

```text
~/.config/quickshell/ii/modules/ii/mediaControls/Aurora
```

También se puede especificar un directorio de módulos:

```bash
./install.sh /ruta/a/tu/quickshell/mediaControls
```

El instalador crea un backup fechado si ya existe una instalación de
Aurora. La copia instalada no contiene `.git`.

## Opciones

```bash
./install.sh --help
./install.sh --dry-run
./install.sh --no-backup
./install.sh --target /ruta/al/directorio
```

El instalador no instala dependencias del sistema. Aurora Doctor informa
después si `quickshell`, `cava` o EasyEffects están disponibles.

## Después de instalar

Importa el widget:

```qml
import "ii/modules/ii/mediaControls/Aurora/Components/Layout" as Aurora

Aurora.AuroraPlayer { }
```

Para un slot de tamaño fijo:

```qml
Aurora.AuroraPlayer {
    hostWidth: 400
    hostHeight: 80
}
```

Si no se especifican `hostWidth` y `hostHeight`, Aurora administra
Compact / Hover / Expanded por sí misma.

## Plugins

Los plugins no se configuran dentro de `AuroraConfig`.

Aurora descubre automáticamente plugins instalados en:

```text
~/.config/aurora/plugins/<plugin-id>/plugin.qml
```

o en:

```text
$XDG_CONFIG_HOME/aurora/plugins/<plugin-id>/plugin.qml
```

Los plugins deben permanecer fuera del repositorio de Aurora para que
una actualización del widget no sobrescriba código de terceros.

Ver `PLUGINS.md`.

## Tema

Aurora usa el tema del sistema por defecto:

```qml
AuroraConfig.themeMode: AuroraConfig.themeSystem
```

También existe el tema incluido de Aurora:

```qml
AuroraConfig.themeMode: AuroraConfig.themeAurora
```

El mapeo del tema del sistema está aislado en
`Providers/AuroraThemeProvider.qml`.

## Diagnóstico

Después de instalar:

```bash
./aurora-doctor
```

Aurora Doctor es una herramienta de terminal. Comprueba estructura,
referencias QML, integración, configuración, números mágicos, scripts y
dependencias opcionales sin participar en la ejecución normal del widget.
