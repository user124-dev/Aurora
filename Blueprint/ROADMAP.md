# Roadmap de Aurora

Estado y dirección técnica del proyecto. Para decisiones vigentes, ver [`DECISIONS_CURRENT.md`](./DECISIONS_CURRENT.md). Para ideas no normativas, ver [`Project/IDEAS.md`](../Project/IDEAS.md).

## v0.1 — Base y runtime

- [x] Arquitectura inicial (`AuroraState`, `AuroraConfig`)
- [x] Sincronización de metadata vía MPRIS
- [x] Controles de reproducción y timeline
- [x] Layout Compact / Hover / Expanded
- [x] Espectro funcional con Cava
- [x] MPRIS desacoplado mediante `Quickshell.Services.Mpris`
- [x] PipeWire integrado mediante `Quickshell.Services.Pipewire`
- [x] Instalación standalone, actualización, rollback y reparación
- [x] Diagnóstico read-only
- [ ] Tema por defecto completo y revisión visual final

## v0.2 — Audio y personalización

- [ ] Sistema de temas intercambiables documentado y probado
- [ ] Ajustes finos de espectro: bajos, sensibilidad y dinámica
- [ ] Exponer estado PipeWire de forma opcional en UI
- [ ] Separar tokens de audio de tokens generales si `AuroraConfig` continúa creciendo
- [ ] Definir contratos de escritura para volumen/routing antes de habilitar control del grafo PipeWire

## v0.3 — Experiencia visual avanzada

- [ ] Tamaño o comportamiento de barras relacionado con características musicales
- [ ] Revelación de imagen mediante el espectro
- [ ] Logo dinámico
- [ ] Evaluar capacidades futuras de visualización de Quickshell sin abandonar Cava como fallback

## v0.4 — Fuentes múltiples y sesión

- [x] Prioridad de fuentes configurable + cambio automático
- [x] Estados `Playing` / `Paused` / `Offline`
- [x] Fusionar reproductores duplicados
- [x] Recordar última fuente seleccionada
- [x] Cola propia de Aurora por fuente seleccionada
- [x] Historial de sesión propio de Aurora por fuente
- [x] Panel de cola/historial dentro de Expanded
- [x] Reproducción asistida del siguiente elemento cuando MPRIS expone `next()`
- [ ] Confirmación avanzada de identidad para navegadores y wrappers
- [ ] Validar Spotify, MPV, VLC y navegadores como casos MPRIS
- [ ] Persistencia opcional de sesiones
- [ ] Reproducción arbitraria de una entrada cuando una fuente exponga una API compatible

## v0.5 — Ecualizador, efectos, letras y ajustes

- [x] `AuroraEqualizerProvider` — descubrimiento y carga de presets de EasyEffects
- [x] Advertencia explícita cuando Aurora carga un preset
- [ ] Snapshot/restore seguro del estado de EasyEffects
- [x] Panel de presets de EasyEffects
- [x] Aurora Doctor — diagnóstico base
- [x] Provider de letras opcional con backend desacoplado
- [x] Letras planas y sincronizadas en Expanded
- [ ] Backends adicionales de letras
- [ ] Extender Doctor para diagnóstico profundo de Providers/plugins/temas
- [ ] Ajustes reorganizados como panel/overlay
- [ ] Nivel B del EQ: control en vivo banda por banda vía una API estable

## Exploratorio / sin fecha

- Modo terminal
- Modo barra completa
- Compatibilidad con ecosistemas fuera de Quickshell
- Estados `Buffering` / `Loading` / `Error` cuando una fuente los exponga de forma confiable
- Otros procesadores de audio compatibles con PipeWire
- Plugins específicos de Spotify, MPV, VLC o navegadores solo cuando aporten capacidades que MPRIS no exponga

## Notas

Este roadmap es una guía técnica, no un compromiso de fechas. Las ideas conceptuales permanecen en `Project/IDEAS.md`; una vez que una idea se convierte en implementación o decisión técnica, su contrato se mueve a Blueprint.
