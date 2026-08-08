## Unreleased — limpieza estructural y tooling

- Corregidas referencias de `AuroraConfig` que apuntaban a propiedades inexistentes.
- Unificados los nombres de modos y temas en `camelCase`.
- Restauradas y centralizadas las constantes del espectro, controles e información.
- Eliminados números mágicos de comportamiento y diseño en Providers/Components.
- `AuroraPlayerProvider` usa `Singleton` y tiene inicialización idempotente.
- El tema del sistema queda como valor predeterminado.
- El registro de plugins usa descubrimiento automático por `plugin.qml`.
- Añadida limpieza de registro en el plugin de ejemplo.
- Añadidos `aurora-doctor` e `install.sh` robustos.

No disponible hasta la vercion 1.0.0
