# Contribuir a Aurora

Esta guía describe el proceso técnico para contribuir al repositorio. El contexto de identidad y filosofía del proyecto está separado en [`Project/`](../Project/).

## Antes de empezar

Lee primero:
- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — cómo están organizados los módulos.
- [`DECISIONS_CURRENT.md`](./DECISIONS_CURRENT.md) — decisiones arquitectónicas vigentes.
- [`CONVENTIONS.md`](./CONVENTIONS.md) — dónde debe vivir cada tipo de código.
- [`STYLEGUIDE.md`](./STYLEGUIDE.md) — estilo de código QML.
- [`Project/PHILOSOPHY.md`](../Project/PHILOSOPHY.md) — principios del proyecto, si tu propuesta afecta dirección o identidad.

## Flujo de trabajo

1. Haz un fork del repositorio.
2. Crea una rama descriptiva: `feature/spectrum-cava`, `fix/timeline-sync`, etc.
3. Sigue `STYLEGUIDE.md` y `CONVENTIONS.md` para el código QML.
4. Si tu cambio afecta arquitectura o introduce una decisión técnica, actualiza `DECISIONS_CURRENT.md` y, cuando corresponda, `API.md`, `PROVIDERS.md` o `DATAFLOW.md`.
5. Si una idea todavía no tiene implementación ni contrato técnico, puede registrarse en [`Project/IDEAS.md`](../Project/IDEAS.md).
6. Abre un Pull Request describiendo el "por qué", no solo el "qué".

## Tipos de contribución bienvenidas

- Corrección de bugs.
- Nuevos temas en `Themes/`.
- Mejoras de documentación técnica.
- Investigación en `Research/` sobre otros reproductores, APIs o shells.
- Ideas nuevas → [`Project/IDEAS.md`](../Project/IDEAS.md), no directamente como código.

## Qué evitar

- Copiar código de otros proyectos sin adaptarlo y sin respetar sus licencias.
- Crear archivos monolíticos de cientos de líneas cuando una división por responsabilidad sea razonable.
- Introducir dependencias privadas de un host en `Core/` o Components.
- Cambiar la arquitectura sin actualizar el contrato técnico correspondiente.

## Código de conducta

Mantén una comunicación respetuosa y técnica. Las preguntas y contribuciones pequeñas también son válidas; el objetivo es que el repositorio pueda ser entendido y mantenido por colaboradores con distintos niveles de experiencia.
