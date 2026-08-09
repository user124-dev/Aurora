# Blueprint

Blueprint es la **especificación técnica de Aurora**. Debe mantenerse sincronizado con el runtime real; si una decisión cambia en código, la documentación correspondiente se actualiza en la misma etapa.

Blueprint no contiene identidad, filosofía ni backlog conceptual. Ese material vive en [`Project/`](../Project/).

## Documentos técnicos

- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — estructura, runtime standalone, dependencias y estrategia de compatibilidad.
- [`API.md`](./API.md) — contrato de `AuroraState`, `AuroraConfig` y Providers.
- [`DATAFLOW.md`](./DATAFLOW.md) — flujo de datos entre fuentes externas, Providers, Core y Components.
- [`PROVIDERS.md`](./PROVIDERS.md) — diseño y responsabilidades de Providers.
- [`PLUGINS.md`](./PLUGINS.md) — sistema de plugins externos.
- [`INSTALL.md`](./INSTALL.md) — instalación, actualización, dependencias y rollback.
- [`DECISIONS_CURRENT.md`](./DECISIONS_CURRENT.md) — decisiones arquitectónicas vigentes.
- [`DECISIONS.md`](./DECISIONS.md) — historial técnico detallado de decisiones anteriores.
- [`CONVENTIONS.md`](./CONVENTIONS.md) — nomenclatura y organización del código.
- [`STYLEGUIDE.md`](./STYLEGUIDE.md) — estilo QML.
- [`THEMES.md`](./THEMES.md) — contrato y estructura de temas.
- [`CHANGELOG.md`](./CHANGELOG.md) — historial técnico de cambios del proyecto.

## Contexto no técnico

La identidad, filosofía y backlog conceptual de Aurora se mantienen fuera de Blueprint:

- [`Project/README.md`](../Project/README.md) — separación entre contexto de proyecto y especificación técnica.
- [`Project/PHILOSOPHY.md`](../Project/PHILOSOPHY.md) — principios del proyecto.
- [`Project/OURS.md`](../Project/OURS.md) — identidad y propósito.
- [`Project/IDEAS.md`](../Project/IDEAS.md) — ideas y posibilidades futuras.

## Regla de sincronización

Blueprint describe lo que Aurora **es técnicamente hoy**. `Project/` describe por qué existe, qué identidad busca y qué posibilidades se están evaluando.

Una idea de `Project/IDEAS.md` no se convierte en parte del contrato técnico hasta que existe una decisión o implementación verificable. Cuando eso ocurre, la decisión normativa se registra en el documento técnico correspondiente.

## Estado de esta etapa

La etapa Runtime & Distribution establece:

1. entrypoint `shell.qml`;
2. instalación standalone en `~/.config/quickshell/Aurora`;
3. ejecución mediante `qs -c Aurora`;
4. instalación y actualización con `install.sh`;
5. resolución interactiva de dependencias clave y opcionales;
6. rollback ante fallos;
7. reparación de archivos faltantes y actualización del payload;
8. `aurora-doctor` como diagnóstico de compatibilidad;
9. MPRIS desacoplado del host mediante `Quickshell.Services.Mpris`;
10. arquitectura de Providers y estado central documentada contra el runtime actual.

Las integraciones específicas de compositor y temas de hosts externos permanecen desacopladas del Core y se desarrollarán como adapters únicamente cuando exista una integración real que probar.
