Changelog
Todos los cambios notables de Aurora se documentarán en este archivo.
Formato basado en Keep a Changelog. Este proyecto aún no sigue versionado semántico estricto por estar en fase 0.x (desarrollo temprano).
[No publicado]
Agregado
Arquitectura base: AuroraState, AuroraConfig (Core).
AuroraPlayerProvider: sincronización de metadata y comandos vía MPRIS.
AuroraAudioProvider: integración inicial con cava para el espectro (pendiente de validar en producción).
Componentes visuales: Cover, Info, Controls, Spectrum, AuroraBackground.
Layout responsivo: modos Compact / Hover / Expanded (AuroraPlayer.qml).
Sincronización de timeline (duration/position) con polling mientras se reproduce.
Documentación inicial: README.md, PHILOSOPHY.md, DECISIONS.md, Ideas.md.
Pendiente
Confirmar spectrumLevel como arreglo por barra (bloqueante para varias ideas del backlog).
Sistema de temas (AuroraTheme / AuroraThemeProvider) — actualmente los componentes leen del host directamente.
[0.1.0] — No disponible aún
La primera versión etiquetada se publicará cuando el espectro de audio (cava) esté validado como fuente de datos estable. Ver ROADMAP.md.
