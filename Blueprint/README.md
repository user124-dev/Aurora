# Blueprint

Blueprint es la especificación técnica de Aurora. Debe mantenerse sincronizado con el runtime real; si una decisión cambia en código, la documentación correspondiente se actualiza en la misma etapa.

## Documentos

- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — estructura, runtime standalone, dependencias y compatibilidad.
- [`API.md`](./API.md) — contrato de `AuroraState`, `AuroraConfig` y Providers.
- [`DATAFLOW.md`](./DATAFLOW.md) — flujo de datos entre Providers, Core y Components.
- [`PROVIDERS.md`](./PROVIDERS.md) — diseño y responsabilidades de Providers.
- [`PLUGINS.md`](./PLUGINS.md) — sistema de plugins externos.
- [`INSTALL.md`](./INSTALL.md) — instalación, actualización, dependencias y rollback.
- [`DECISIONS.md`](./DECISIONS.md) — decisiones arquitectónicas e historial técnico.
- [`CONVENTIONS.md`](./CONVENTIONS.md) — nomenclatura y organización del código.
- [`STYLEGUIDE.md`](./STYLEGUIDE.md) — estilo QML.
- [`PHILOSOPHY.md`](./PHILOSOPHY.md) — principios del proyecto.
- [`OURS.md`](./OURS.md) — identidad y propósito.
- [`Ideas.md`](./Ideas.md) — backlog futuro.
- [`CHANGELOG.md`](./CHANGELOG.md) — historial de versiones.

## Estado de esta etapa

La primera etapa de distribución/runtime establece:

1. entrypoint `shell.qml`;
2. instalación standalone en `~/.config/quickshell/Aurora`;
3. ejecución mediante `qs -c Aurora`;
4. instalación y actualización con `install.sh`;
5. resolución interactiva de dependencias clave y opcionales;
6. rollback ante fallos;
7. reparación de archivos faltantes y actualización del payload;
8. `aurora-doctor` como diagnóstico de compatibilidad;
9. MPRIS desacoplado del host mediante `Quickshell.Services.Mpris`;
10. documentación alineada con el runtime.

Las integraciones específicas de compositor y temas de hosts externos permanecen desacopladas del Core y se desarrollarán como adapters cuando exista una necesidad real.
