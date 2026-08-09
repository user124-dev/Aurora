# Aurora — Project

Esta carpeta contiene el contexto no técnico del proyecto.

Aquí se mantienen la identidad, filosofía, propósito y backlog de ideas de Aurora. Estos documentos explican **por qué existe Aurora y hacia dónde quiere ir**, pero no definen el contrato del runtime.

## Contenido

- [`PHILOSOPHY.md`](./PHILOSOPHY.md) — principios que orientan el proyecto.
- [`OURS.md`](./OURS.md) — identidad, origen y propósito humano del proyecto.
- [`IDEAS.md`](./IDEAS.md) — ideas y posibilidades futuras que todavía no forman parte del contrato técnico.

## Regla de separación

`Blueprint/` es la fuente de verdad para la arquitectura y el comportamiento técnico actual.

`Project/` contiene material conceptual, de identidad y planificación no normativa.

Cuando una idea de `Project/IDEAS.md` se convierte en una decisión técnica o una funcionalidad implementada, su parte normativa debe pasar a `Blueprint/DECISIONS.md`, `Blueprint/API.md` u otro documento técnico correspondiente. El texto conceptual puede permanecer aquí como historial.
