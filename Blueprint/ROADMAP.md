# Roadmap de Aurora

Estado y dirección del proyecto. Para el detalle técnico de cada decisión, ver [`DECISIONS.md`](./Blueprint/DECISIONS.md). Para ideas sin madurar, ver [`Ideas.md`](./Blueprint/Ideas.md).

## v0.1 — Base (en progreso)

- [x] Arquitectura inicial (`AuroraState`, `AuroraConfig`)
- [x] Sincronización de metadata vía MPRIS (`AuroraPlayerProvider`)
- [x] Controles de reproducción (play/pause, next, previous)
- [x] Sincronización de timeline/posición
- [x] Layout responsivo (Compact / Hover / Expanded)
- [ ] Espectro de audio funcional (`AuroraAudioProvider` + `cava`) — **pendiente crítico**
- [ ] Tema por defecto completo (`Themes/Default`)

## v0.2 — Personalización

- [ ] Sistema de temas intercambiables documentado y probado
- [ ] Ajustes finos de espectro (respuesta de bajos, sensibilidad)
- [ ] Documentación completa (este roadmap + ARCHITECTURE + API)

## v0.3 — Experiencia visual avanzada

- [ ] Tamaño de barras según nota musical (`spectrumLevel` como arreglo)
- [ ] Efecto de "revelación de imagen" mediante el espectro
- [ ] Logo dinámico

## Exploratorio / sin fecha

- Modo terminal (sin UI gráfica completa)
- Modo barra completa (ocupando la parte inferior de pantalla)
- Compatibilidad con ecosistemas fuera de Quickshell

## Notas

Este roadmap es una guía, no un compromiso de fechas — el proyecto es mantenido por estudiantes en tiempo libre. Las prioridades pueden reordenarse según lo que bloquee más funcionalidad (actualmente: la fuente de datos del espectro).
