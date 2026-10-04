# Temas en Aurora

Aurora separa el contrato visual (`Core/AuroraTheme.qml`) de la fuente de valores (`Themes/*.json`) mediante `AuroraThemeProvider`. Los componentes nunca deben leer directamente archivos de tema ni depender de un host.

## Estructura actual

```text
Themes/
├── aurora.json
├── midnight.json
├── paper.json
└── nebula.json
```

Cada archivo define únicamente datos visuales. `Core/AuroraTheme.qml` conserva el contrato estable que consumen los componentes y `Providers/AuroraThemeProvider.qml` carga la definición seleccionada desde `Quickshell.shellDir + "/Themes"`.

## Selección

La selección persistente se guarda fuera del runtime en:

```text
~/.config/aurora/theme.json
```

Se administra mediante:

```text
aurora-theme list
aurora-theme current
aurora-theme set <theme>
aurora-theme reset
aurora-theme background list
aurora-theme background current
aurora-theme background set <aurora|custom|wallpaper> [image-path]
```

`aurora-theme list` descubre automáticamente los archivos `Themes/*.json`, por lo que añadir un nuevo tema no requiere modificar un `switch` de QML.

`theme.json` guarda la paleta (`name`) y el fondo (`background`). Cuando el fondo es `custom`, también guarda `backgroundPath` con la ruta de la imagen. `set` y `reset` cambian solo la paleta y conservan la configuración del fondo.

## Modos

`AuroraConfig.themeMode` define qué se dibuja **detrás** del widget. No cambia la paleta: los colores y la tipografía siguen viniendo de `Themes/*.json` en los tres modos.

- `themeAurora` — fondo de la superficie del tema con la portada del álbum encima (comportamiento por defecto).
- `themeAurora` — usa la portada del reproductor como fondo de música.
- `themeCustom` — usa una imagen elegida por el usuario mediante su ruta. No modifica el wallpaper del escritorio.
- `themeWallpaper` — usa el wallpaper actual del escritorio. Ver "Fondo Wallpaper".

`AuroraThemeProvider` traduce `background` (`aurora`, `custom`, `wallpaper`) a `themeMode`. El valor histórico `system` se migra a `custom` para no reactivar un modo de host que Aurora ya no usa. Un valor desconocido cae en `themeAurora`.

La implementación no importa `qs.modules.common` ni ningún singleton de End-4/ii.

## Fondo Custom

El modo `custom` no reemplaza ni consulta el sistema de wallpaper. Aurora pide una ruta de imagen al usuario:

```text
aurora-theme background set custom
```

También puede recibirse directamente como argumento:

```text
aurora-theme background set custom /ruta/a/imagen.jpg
```

La ruta se guarda en `theme.json` como `backgroundPath`. Al volver a seleccionar `custom`, se reutiliza la última imagen guardada si no se proporciona otra ruta. Si la imagen deja de existir o no puede decodificarse, `AuroraBackground` conserva el fondo de respaldo sin tocar el wallpaper del escritorio.

## Fondo Wallpaper

Quickshell no documenta una API para consultar el fondo de pantalla, y Wayland no define un protocolo para ello: solo la herramienta que dibuja el wallpaper sabe cuál es. Por eso `Providers/AuroraWallpaperProvider.qml` consulta, en este orden y con la primera respuesta válida, las herramientas que sí lo exponen:

| Estrategia | Comando | Requiere |
|------------|---------|----------|
| `hyprpaper` | `hyprctl hyprpaper listactive` | Hyprland con hyprpaper en ejecución |
| `swww` | `swww query` | swww con su daemon activo |
| `gsettings` | `org.gnome.desktop.background` (`picture-uri` o `picture-uri-dark` según `color-scheme`) | GNOME o compatible |

Las tres son opcionales. La primera que responde queda como preferida para las siguientes consultas. Si ninguna responde, `AuroraState.wallpaperAvailable` queda en `false` y el fondo cae a la superficie por defecto: **el modo wallpaper nunca deja el widget sin fondo**. Lo mismo ocurre si la ruta existe pero la imagen no se puede decodificar (por ejemplo, un slideshow XML de GNOME).

Detalles de comportamiento:

- La consulta solo se ejecuta, y solo se repite cada `AuroraConfig.wallpaperRefreshInterval`, mientras el modo activo es `themeWallpaper`.
- El widget muestra la imagen recortada a su tamaño (`PreserveAspectCrop`), no la porción del escritorio que queda detrás de él.
- La atenuación se configura con `AuroraConfig.wallpaperOpacity` (opacidad de la imagen) y `AuroraConfig.wallpaperDimOpacity` (capa oscura del color del tema encima).
- La imagen se decodifica a `AuroraConfig.wallpaperDecodeWidth` de ancho como máximo para no retener un wallpaper 4K en memoria.
- No usa `QtQuick.Effects` ni shaders.

Para soportar otra herramienta basta añadir una estrategia y su parser al Provider; ni `Core` ni `Components` cambian.

## Contrato

Los componentes consumen exclusivamente:

```qml
AuroraTheme.colorBackground
AuroraTheme.colorPrimary
AuroraTheme.fontFamily
```

No deben importar `Appearance`, Material Symbols u otro sistema visual del host.

## Crear un tema

1. Crear `Themes/<nombre>.json`.
2. Mantener las propiedades del contrato de `AuroraTheme`.
3. Mantener el archivo como datos, sin lógica de runtime.
4. Validar JSON y ejecutar `aurora-theme list`.
5. Ejecutar `aurora-doctor` antes de integrar el cambio.

Los adapters de temas específicos de compositor o shell deben mantenerse fuera del Core y añadirse solo cuando exista una integración real que probar.
