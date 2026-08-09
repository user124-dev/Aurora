# Ideas y backlog

Este documento recoge ideas para Aurora que todavía no forman parte del contrato técnico del proyecto. Se organiza por madurez para distinguir posibilidades de decisiones ya tomadas.

## En evaluación

- Cambio de frecuencias por medio de software.
- Tamaño de las barras según la nota musical que se esté reproduciendo.
- Revelación de imagen mediante las barras del espectro.
- Imagen pequeña del instrumento que se esté reproduciendo, ubicada sobre una barra.

Estas ideas pueden evolucionar, combinarse o descartarse sin que eso implique un cambio en la arquitectura actual.

## Exploratorias / futuro

- Ejecución exclusiva en terminal, como modo alternativo y posiblemente independiente de la UI gráfica.
- Ejecución ocupando toda la parte inferior de la pantalla, como modo de barra completa.
- Compatibilidad futura con otros ecosistemas y entornos más allá de Quickshell.

## Evaluadas para v0.2

### Separar AuroraConfig en AuroraConfig + AuroraTokens

Dividir `Core/AuroraConfig.qml` en dos: `AuroraConfig` para comportamiento y layout por modo, y `AuroraTokens` para valores de diseño puros como spacing, radius, opacity y duraciones.

**A favor:** mejor navegación a medida que crece y separación entre comportamiento y valores de diseño.

**En contra:** afecta muchos componentes y referencias existentes. Es reorganización, no una capacidad nueva, por lo que no es urgente.

### Extraer AuroraIconButton.qml a Components/Common/

Varios botones de `AuroraControls.qml` comparten un patrón de interacción. Un componente común podría reducir duplicación, pero primero debe definirse una API que funcione tanto para botones momentáneos como para controles con estado.

**Conclusión:** ambas propuestas permanecen como candidatas de v0.2 y no forman parte de las correcciones actuales.

## Ideas ya resueltas

La elección de Cava como fuente del espectro y el uso de `AuroraState.spectrumLevels` como arreglo ya son decisiones técnicas implementadas. Su contrato y justificación viven en `Blueprint/DECISIONS.md` y `Blueprint/PROVIDERS.md`, no aquí.
