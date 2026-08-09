# Changelog

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
