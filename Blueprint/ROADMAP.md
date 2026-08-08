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

- [ ] Sistema de temas intercambiables documentado y probado — temas concretos a construir: **Neon**, **Catppuccin**, **Nord**, **Tokyo Night**, **Gruvbox**, **Material** (mecanismo ya existe vía `AuroraTheme`/`AuroraThemeProvider`; `System` sigue mapeando al host, sin cambios)
- [ ] Ajustes finos de espectro (respuesta de bajos, sensibilidad)
- [ ] Documentación completa (este roadmap + ARCHITECTURE + API)

## v0.3 — Experiencia visual avanzada

- [ ] Tamaño de barras según nota musical (`spectrumLevel` como arreglo)
- [ ] Efecto de "revelación de imagen" mediante el espectro
- [ ] Logo dinámico

## v0.4 — Fuentes múltiples avanzadas (el diferenciador más grande)

Ver `Ideas.md` → "Fuentes múltiples y cola unificada" y `DECISIONS.md` → "Fase 4: fuentes múltiples avanzadas" para el detalle y las limitaciones reales de MPRIS.

- [x] Prioridad de fuentes configurable + cambio automático (`AuroraConfig.sourcePriority` / `autoSwitchEnabled`)
- [x] Estados de fuente extendidos: `Playing`/`Paused` (reales) + `Offline` (sintético, derivado de `sourcePriority`)
- [x] "Fusionar reproductores duplicados" como toggle configurable (`AuroraConfig.mergeDuplicatePlayers`)
- [x] Recordar última fuente seleccionada entre sesiones (`AuroraConfig.rememberLastSource`, vía `Quickshell.statePath()`)
- [ ] Cola/playlist por fuente seleccionada, con fallback "No disponible" cuando la fuente no expone `org.mpris.MediaPlayer2.Playlists` (la mayoría de casos) — pendiente, requiere integración por fuente

## v0.5 — Ecualizador real, diagnóstico y ajustes

Ver `Ideas.md` → "Ecualizador real + panel colapsable / Aurora Doctor" para el detalle de niveles y dependencias.

- [ ] `AuroraEqualizerProvider` — Nivel A: control por presets vía EasyEffects (CLI, `easyeffects -l <preset>`)
- [ ] Panel de Ecualizador y Visualizador colapsables dentro de `AuroraExpandedView`
- [x] Base de Aurora Doctor — diagnóstico de estructura, referencias QML,
  integración, números mágicos y contratos. Se ejecuta desde terminal y no
  forma parte del runtime del widget.
- [ ] Ajustes reorganizados como panel/overlay (General / Apariencia / Audio / Fuentes / Ecualizador / Avanzado / Acerca de) — no como vista permanente
- [ ] *(Exploratorio, sin compromiso de fecha)* Nivel B del EQ: control en vivo banda por banda vía GSettings

## Exploratorio / sin fecha

- Modo terminal (sin UI gráfica completa)
- Modo barra completa (ocupando la parte inferior de pantalla)
- Compatibilidad con ecosistemas fuera de Quickshell
- Buffering/Loading/Error como estados de fuente reales (no confirmados por ningún protocolo estándar — ver `Ideas.md`)
- Nivel B del EQ (bandas en vivo vía GSettings) si se confirma una ruta estable

## Notas

Este roadmap es una guía, no un compromiso de fechas — el proyecto es mantenido por estudiantes en tiempo libre. Las prioridades pueden reordenarse según lo que bloquee más funcionalidad. Orden acordado para esta ampliación (30/07/2026): visión completa → fuentes múltiples (v0.4, avance parcial ya implementado el 31/07/2026) → EQ + Doctor + Ajustes (v0.5) → tema Neon (v0.2, mecanismo ya existe).
