# Changelog

## Unreleased — UX finishing pass

### Animaciones
- Cambios Compact ↔ Hover ↔ Expanded: cross-fade entre vistas y duración propia (`layoutAnimation`) para el tamaño.
- El widget aparece con un fundido en lugar de aparecer de golpe.
- Título y artista hacen cross-fade al cambiar de canción; la portada usa `smoothAnimation`.
- Los iconos play/pause y el badge de repetir uno hacen cross-fade en lugar de cortarse.
- El espectro atenúa con fundido al desconectarse la fuente.
- El badge de navegador, los switchers de fuente y ecualizador, el aviso de EasyEffects y el panel Queue/Lyrics aparecen y desaparecen creciendo/fundiendo en lugar de saltar.
- Nuevas constantes en `AuroraConfig`: `smoothAnimation`, `crossfadeAnimation`, `layoutAnimation`, `lyricsAnimation`.

### Letras
- Desplazamiento automático a la línea actual, contextual (no continuo), sin scroll si la línea sigue visible con contexto y sin animar la colocación inicial.
- `AuroraLyricsPanel` ya no importa `Providers/` (no lo usaba y contradecía la regla de aislamiento).

### Temas
- Nuevo modo de fondo `themeWallpaper` con capa de atenuación configurable y fallback al fondo por defecto.
- Nuevo `AuroraWallpaperProvider` (hyprpaper, swww, gsettings), solo activo con ese modo.
- `aurora-theme background list|current|set`; el modo se guarda en el mismo `theme.json`. `aurora-theme set`/`reset` ya no borran el modo de fondo.

### Ventana
- Compact y Hover se pueden arrastrar por la pantalla; la posición se guarda en `Quickshell.statePath("aurora-window-position.json")`. `AuroraConfig.widgetDragEnabled` lo desactiva.
- Nuevas señales `AuroraState.widgetDragOffset` / `widgetDragFinished`, escuchadas por `shell.qml`.

### Doctor
- Comprueba `AuroraWallpaperProvider.qml`, el cableado del modo wallpaper y las herramientas de wallpaper (warning si no hay ninguna).
- Nueva comprobación de que el camino de render no usa `QtQuick.Effects`, `MultiEffect`, `layer.effect` ni `Qt5Compat`.

### Blueprint
- Corregidas las referencias obsoletas a `Themes/Default/Theme.qml` en `ARCHITECTURE.md`, `DATAFLOW.md` y `DECISIONS_CURRENT.md`.
- Actualizados `API.md`, `PROVIDERS.md`, `THEMES.md`, `INSTALL.md`, `STYLEGUIDE.md`, `DECISIONS_CURRENT.md` y `DECISIONS.md`.

## Unreleased — Runtime & Distribution

### Runtime
- Añadido `shell.qml` como entrypoint standalone.
- Aurora puede ejecutarse como configuración nombrada con `qs -c Aurora`.
- Añadido `AuroraMprisController.qml` sobre `Quickshell.Services.Mpris`.
- Eliminadas las dependencias runtime directas de `qs.services` y `qs.modules.common`.
- El tema Aurora incluido es el fallback/default del runtime standalone.

### Installer
- `install.sh` instala en `~/.config/quickshell/Aurora` por defecto.
- Detecta Quickshell y valida una versión mínima de 0.2.0.
- Pregunta antes de resolver dependencias clave.
- Pregunta antes de instalar Cava como dependencia opcional.
- Reemplaza instalaciones incompletas o desactualizadas.
- Conserva backup y ejecuta rollback si la activación o validación falla.
- Mantiene plugins externos fuera del payload administrado.

### Doctor
- `aurora-doctor` valida el entrypoint standalone.
- Detecta Quickshell, MPRIS, Cava, D-Bus y entorno gráfico.
- Comprueba aislamiento de Core, Components y Providers frente a módulos `qs.*` del host.
- Comprueba coherencia del Blueprint actual.

### Blueprint
- Actualizados `README.md`, `ARCHITECTURE.md`, `API.md`, `INSTALL.md`, `PROVIDERS.md` y `THEMES.md`.
- Documentada la estrategia de compatibilidad basada en APIs generales de Quickshell y adapters específicos.

## Nota

Aurora continúa en desarrollo pre-1.0. Las integraciones específicas de compositor y host se añadirán únicamente cuando exista una necesidad y una prueba real de compatibilidad.
