# Roadmap de Aurora

Estado y dirección técnica del proyecto. Para el detalle de cada decisión vigente, ver [`DECISIONS_CURRENT.md`](./DECISIONS_CURRENT.md). Para el historial técnico detallado, ver [`DECISIONS.md`](./DECISIONS.md). Para ideas no normativas, ver [`Project/IDEAS.md`](../Project/IDEAS.md).

## v0.1 — Base y runtime (en progreso)

- [x] Arquitectura inicial (`AuroraState`, `AuroraConfig`)
- [x] Sincronización de metadata vía MPRIS (`AuroraPlayerProvider`)
- [x] Controles de reproducción (play/pause, next, previous)
- [x] Sincronización de timeline/posición
- [x] Layout responsivo (Compact / Hover / Expanded)
- [x] Espectro de audio funcional (`AuroraAudioProvider` + `cava`)
- [x] MPRIS desacoplado del host mediante `Quickshell.Services.Mpris`
- [x] Instalación standalone, actualización, rollback y reparación (`install.sh`)
- [x] Diagnóstico read-only (`aurora-doctor`)
- [ ] Tema por defecto completo y revisión visual final (`Themes/Default`)

## v0.2 — Personalización

- [ ] Sistema de temas intercambiables documentado y probado — temas concretos a construir: **Neon**, **Catppuccin**, **Nord**, **Tokyo Night**, **Gruvbox**, **Material**.
- [ ] Ajustes finos de espectro: respuesta de bajos, sensibilidad y dinámica.
- [ ] Reorganización de tokens visuales si `AuroraConfig` continúa creciendo (candidata actualmente en `Project/IDEAS.md`).

## v0.3 — Experiencia visual avanzada

- [ ] Tamaño o comportamiento de barras relacionado con características musicales más específicas.
- [ ] Efecto de revelación de imagen mediante el espectro.
- [ ] Logo dinámico.

## v0.4 — Fuentes múltiples avanzadas

Las funciones base de fuentes múltiples ya están parcialmente implementadas.

- [x] Prioridad de fuentes configurable + cambio automático (`AuroraConfig.sourcePriority` / `autoSwitchEnabled`)
- [x] Estados de fuente extendidos: `Playing` / `Paused` reales + `Offline` sintético
- [x] Fusionar reproductores duplicados (`AuroraConfig.mergeDuplicatePlayers`)
- [x] Recordar última fuente seleccionada (`AuroraConfig.rememberLastSource` vía `Quickshell.statePath()`)
- [ ] Cola/playlist por fuente seleccionada, con fallback "No disponible" cuando la fuente no expone `org.mpris.MediaPlayer2.Playlists`

## v0.5 — Ecualizador, diagnóstico y ajustes

- [x] `AuroraEqualizerProvider` — Nivel A: descubrimiento y carga de presets de salida vía EasyEffects
- [ ] Panel de Ecualizador y Visualizador colapsables dentro de `AuroraExpandedView`
- [x] Aurora Doctor — diagnóstico base del repositorio, runtime y entorno
- [ ] Extender Doctor para diagnóstico profundo de Providers/plugins/temas si aporta valor real
- [ ] Ajustes reorganizados como panel/overlay (General / Apariencia / Audio / Fuentes / Ecualizador / Avanzado / Acerca de)
- [ ] Nivel B del EQ: control en vivo banda por banda vía GSettings, solo si se confirma una ruta estable

## Exploratorio / sin fecha

- Modo terminal (sin UI gráfica completa)
- Modo barra completa (ocupando la parte inferior de pantalla)
- Compatibilidad con ecosistemas fuera de Quickshell
- Estados `Buffering` / `Loading` / `Error` solo si existe una fuente/protocolo que los exponga de forma confiable
- Nivel B del EQ si se confirma una ruta estable de control en vivo

## Notas

Este roadmap es una guía técnica, no un compromiso de fechas. Las ideas conceptuales permanecen en `Project/IDEAS.md`; una vez que una idea se convierte en implementación o decisión técnica, su contrato se mueve a Blueprint.
