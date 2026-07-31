# Roadmap de Aurora

Estado y dirección del proyecto. Para el detalle técnico de cada decisión, ver [`DECISIONS.md`](./Blueprint/DECISIONS.md). Para ideas sin madurar, ver [`Ideas.md`](./Blueprint/Ideas.md).

## v0.1 — Base (en progreso)

- [x] Arquitectura inicial (`AuroraState`, `AuroraConfig`)
- [x] Sincronización de metadata vía MPRIS (`AuroraPlayerProvider`)
- [x] Controles de reproducción (play/pause, next, previous)
- [x] Sincronización de timeline/posición
- [x] Layout responsivo (Compact / Hover / Expanded)
- [x] Espectro de audio funcional (`AuroraAudioProvider` + `cava`) — implementado; pendiente de validar contra audio real en producción (ver `DECISIONS.md` → "Spectrum data source")
- [ ] Tema por defecto completo (`Themes/Default`)

## v0.2 — Personalización

- [ ] Sistema de temas intercambiables documentado y probado — temas concretos a construir: **Nebula**, **Catppuccin**, **Nord**, **Tokyo Night**, **Gruvbox**, **Material** (mecanismo ya existe vía `AuroraTheme`/`AuroraThemeProvider`; `System` sigue mapeando al host, sin cambios)
- [ ] Ajustes finos de espectro (respuesta de bajos, sensibilidad)
- [ ] Documentación completa (este roadmap + ARCHITECTURE + API)

## v0.3 — Experiencia visual avanzada

- [ ] Tamaño de barras según nota musical (`spectrumLevel` como arreglo)
- [ ] Efecto de "revelación de imagen" mediante el espectro
- [ ] Logo dinámico

## v0.4 — Fuentes múltiples avanzadas (el diferenciador más grande)

Ver `Ideas.md` → "Fuentes múltiples y cola unificada" para las limitaciones reales de MPRIS que enmarcan esta fase.

- [ ] Cola/playlist por fuente seleccionada, con fallback "No disponible" cuando la fuente no expone `org.mpris.MediaPlayer2.Playlists` (la mayoría de casos)
- [ ] Prioridad de fuentes configurable + cambio automático según esa prioridad
- [ ] Recordar última fuente seleccionada entre sesiones (requiere mecanismo de persistencia nuevo)
- [ ] Estados de fuente extendidos: los tres reales de MPRIS (`Playing`/`Paused`/`Stopped`) + un cuarto sintético (`Offline`, cuando la fuente desaparece de `AuroraState.players`)
- [ ] "Fusionar reproductores duplicados" como toggle configurable (la lógica de `computeMeaningfulPlayers()` ya existe, hoy está siempre activa)

## v0.5 — Ecualizador real, diagnóstico y ajustes

Ver `Ideas.md` → "Ecualizador real + panel colapsable / Aurora Doctor" para el detalle de niveles y dependencias.

- [ ] `AuroraEqualizerProvider` — Nivel A: control por presets vía EasyEffects (CLI, `easyeffects -l <preset>`)
- [ ] Panel de Ecualizador y Visualizador colapsables dentro de `AuroraExpandedView`
- [ ] Aurora Doctor — diagnóstico de Providers/plugins/temas, activado vía `AuroraConfig.developerMode`
- [ ] Ajustes reorganizados como panel/overlay (General / Apariencia / Audio / Fuentes / Ecualizador / Avanzado / Acerca de) — no como vista permanente
- [ ] *(Exploratorio, sin compromiso de fecha)* Nivel B del EQ: control en vivo banda por banda vía GSettings

## Exploratorio / sin fecha

- Modo terminal (sin UI gráfica completa)
- Modo barra completa (ocupando la parte inferior de pantalla)
- Compatibilidad con ecosistemas fuera de Quickshell
- Buffering/Loading/Error como estados de fuente reales (no confirmados por ningún protocolo estándar — ver `Ideas.md`)
- Nivel B del EQ (bandas en vivo vía GSettings) si se confirma una ruta estable

## Notas

Este roadmap es una guía, no un compromiso de fechas — el proyecto es mantenido por estudiantes en tiempo libre. Las prioridades pueden reordenarse según lo que bloquee más funcionalidad. Orden acordado para esta ampliación (30/07/2026): visión completa → fuentes múltiples (v0.4) → EQ + Doctor + Ajustes (v0.5) → temas (v0.2, ya incorporado arriba).
