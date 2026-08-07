Ideas y Backlog
Este documento recoge ideas para Aurora, organizadas por su nivel de madurez y su nivel de complejidad. Una idea que pasa a implementarse debería moverse a DECISIONS.md.

[Nota post-fase-2: las dos referencias de abajo a "decisión abierta" sobre cava
y sobre spectrumLevel como arreglo ya se resolvieron e implementaron -
AuroraAudioProvider.qml usa cava y AuroraState.spectrumLevels ya es un arreglo.
Se deja el texto original tal cual para no perder el razonamiento; ya se
movió formalmente a DECISIONS.md → "Spectrum data source" (fase 3).]

*En evaluación / relacionadas con decisiones abiertas

Cambio de frecuencias por medio de software. Relacionado directamente con la decisión abierta de la fuente de datos del espectro en DECISIONS.md (candidato: cava).

Tamaño de las barras según la nota musical que se esté tocando. Depende de que AuroraState.spectrumLevel se resuelva como arreglo (un valor por barra) — ver decisión pendiente.

Revelación de imagen por medio de barras. Efecto visual donde una imagen se "revela" a través del movimiento del espectro.
Imagen pequeña del instrumento que se esté tocando, ubicada en la parte superior de la barra

Exploratorias / futuro

Ejecución exclusiva en terminal (modo alternativo sin UI gráfica completa y posiblemente la oficial).

Ejecución ocupando toda la parte inferior de la pantalla (modo barra completa).

Compatibilidad futura con otros ecosistemas y entornos más allá de Quickshell (alineado con el principio de "compatibilidad extrema" en PHILOSOPHY.md).

---

## Evaluadas para v0.2 (no implementadas ahora — solo evaluación, por pedido explícito)

### Separar AuroraConfig en AuroraConfig + AuroraTokens

Dividir `Core/AuroraConfig.qml` en dos: `AuroraConfig` (tamaños por modo,
delays, `pluginPaths`, `developerMode` — comportamiento/layout) y
`AuroraTokens` (spacing, radius, opacity, duraciones de animación — valores
de diseño puros). Hoy todo vive junto en un solo archivo que ya pasa las
200 líneas.

**A favor:** más navegable a medida que crece; separa "cómo se comporta el
widget" de "qué pinta tienen las cosas", lo cual encaja si el theming algún
día se extiende más allá de color (spacing themes, no solo paletas).

**En contra:** cada componente que hoy lee `AuroraConfig.<algo>` de diseño
(radius, spacing, opacity) tendría que cambiar a `AuroraTokens.<algo>` — es
un cambio ancho (toca imports y referencias en casi todos los archivos de
`Components/`), no profundo. Reorganización, no nueva capacidad — bajo
riesgo técnico pero tampoco urgente. Candidato razonable para v0.2 si
`AuroraConfig.qml` sigue creciendo, no antes.

### Extraer AuroraIconButton.qml a Components/Common/

4 de los 5 botones en `AuroraControls.qml` (shuffle, prev, next, repeat —
no Play, que ya es distinto por su fondo sólido) repiten el mismo
esqueleto: `Rectangle` + `HoverHandler` + `TapHandler` + `Behavior on color`
con `ColorAnimation`. Solo cambian tamaño, ícono/contenido, y la acción del
`TapHandler`.

**A favor:** duplicación real y medible — 4 copias casi idénticas del mismo
patrón. `Components/Common/` existe reservada y vacía desde hace fases,
esta sería su primer uso real.

**En contra:** diseñar la API correcta (¿el ícono entra por `default
property` como contenido hijo? ¿por una property `iconText`? ¿el componente
necesita saber si es "toggle" con estado activo/inactivo, como
shuffle/repeat, o solo "botón momentáneo", como prev/next?) no es trivial
de acertar al primer intento — vale la pena pensarlo con calma en su propia
sesión, no de paso dentro de una tanda de correcciones más grande.

**Conclusión para ambas:** documentadas aquí como candidatas de v0.2, no
implementadas todavía — a la espera de una sesión dedicada.

