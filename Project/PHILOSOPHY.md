# Filosofía de Aurora

Este documento reúne los principios que orientan el proyecto. No es una especificación técnica: describe la intención que debe guiar las decisiones de diseño y desarrollo.

## Identidad propia

Aurora puede inspirarse en ideas y patrones observados en otros reproductores, shells y widgets, pero no debe convertirse en un proyecto de copiar y pegar. La meta es construir una experiencia con identidad propia y decisiones justificadas para Aurora.

## Compatibilidad extrema

Aurora debe aspirar a funcionar en la mayor cantidad posible de entornos y reproductores. A largo plazo, la idea es que el concepto pueda adaptarse a otros ecosistemas y entornos, incluso fuera de los window managers para los que fue pensado inicialmente.

La compatibilidad se busca mediante límites claros entre la experiencia de Aurora y las integraciones específicas de cada entorno.

## Modularidad

Aurora no debe convertirse en un archivo monolítico difícil de mantener. Cada responsabilidad importante debe tener su propio espacio para que otras personas puedan modificar una parte sin romper accidentalmente el resto del proyecto.

## Libertad de temas y código

El código y los temas deben ser fáciles de modificar. Una persona debería poder adaptar Aurora a sus preferencias sin tener que desmontar toda la arquitectura para cambiar una parte visual o de comportamiento.

## La música debe verse en tiempo real

El espectro debe representar el audio que realmente se está reproduciendo, no una animación aleatoria que simplemente parezca música. La respuesta visual debería reflejar diferencias de frecuencia e intensidad del audio siempre que la fuente disponible lo permita.

## Ajustes finos

Aurora debe permitir ajustar la respuesta del espectro y otros comportamientos perceptibles, no solamente colores, tamaños y apariencia. La sensibilidad, la respuesta de bajos y la dinámica general deben poder evolucionar como parte de la experiencia.
