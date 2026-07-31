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

---

## Post-fase 4: hacia un framework multimedia (visión completa)

[Nota (30/07/2026): estas ideas nacen de una revisión completa de la arquitectura
tras cerrar Fase 3 y avanzar en Fase 4. Aurora deja de pensarse solo como
"widget de reproducción" y empieza a perfilarse como una base modular para
multimedia en Quickshell — sin dejar de ser un widget en su forma final (ver
PHILOSOPHY.md, principio de "no copie y pegue" y "estructura modular"). Las
cuatro líneas de abajo están ordenadas por prioridad de desarrollo acordada,
no por dificultad técnica.]

### 1. Fuentes múltiples y cola unificada (el diferenciador más grande)

El selector de fuente ya está resuelto desde Fase 4 (`AuroraPlayerSwitcher` +
`AuroraState.selectPlayer()`). Lo que falta y su viabilidad real:

- **Cola/playlist por fuente seleccionada.** MPRIS solo expone esto vía la
  interfaz *opcional* `org.mpris.MediaPlayer2.Playlists`, que casi ningún
  reproductor real implementa: navegadores casi nunca, VLC rara vez, mpv
  expone su cola por su propio socket IPC (no por MPRIS), Spotify tiene
  soporte parcial. La función debe diseñarse asumiendo que la mayoría de
  fuentes van a caer en el mismo fallback "No disponible" que ya usa el
  panel de playlist — no prometer una cola universal para las 5 fuentes.
- **Prioridad de fuentes configurable** (ej. mpv > Spotify > Firefox >
  Chromium > VLC) para decidir el cambio automático cuando suenan varias a
  la vez. Hoy `resolveActivePlayer()` solo sigue a
  `MprisController.activePlayer` o a una selección manual puntual - no
  existe concepto de prioridad ni de persistencia entre sesiones.
- **Recordar última fuente seleccionada** entre reinicios de Aurora -
  necesita algún mecanismo de persistencia que hoy no existe (Aurora no
  guarda nada a disco todavía).
- **Estados de fuente extendidos.** MPRIS solo define oficialmente
  `Playing`/`Paused`/`Stopped` en `PlaybackStatus`. Estados como
  Buffering/Loading/Error no existen en el protocolo - no hay forma
  estándar de que un reproductor se los comunique a Aurora. Lo único
  añadible de forma honesta es un cuarto estado sintético, "Offline",
  cuando una fuente desaparece de `AuroraState.players` (esto sí lo puede
  detectar la arquitectura actual). Buffering/Loading/Error quedan aquí
  como exploratorio, no como compromiso de v0.1/v0.2 - prometerlos ahora
  repetiría el mismo error que ya corregimos con el panel de bitrate/códec
  (dato que MPRIS no garantiza).

### 2. Ecualizador real + panel colapsable / Aurora Doctor (lo más cercano a lo ya construido)

- **EQ por niveles**, vía EasyEffects (PipeWire):
  - *Nivel A (robusto):* control por presets completos
    (`easyeffects -l <preset>` + archivo JSON), igual que
    Flat/Bass/Treble/Vocal/Rock/Pop/Jazz/Classic del mockup de referencia.
  - *Nivel B (exploratorio, sin comprometerse todavía):* arrastre en vivo
    banda por banda vía GSettings - EasyEffects no tiene un D-Bus
    documentado para esto; todo pasa por claves de gsettings sin ruta
    estable confirmada entre versiones. Alto riesgo de romperse con un
    update de EasyEffects.
  - Nota de alcance: el EQ afecta la salida de audio a nivel de
    sistema/stream, no solo la fuente que Aurora está mostrando -
    distinto al resto de Aurora, que siempre está scoped al player
    mostrado. Ver DECISIONS.md.
- **Panel de EQ y Visualizador colapsables** dentro de
  `AuroraExpandedView`, en vez de ocupar espacio fijo siempre. El estado
  expandido/colapsado de cada panel es local al componente, no pertenece
  a `AuroraState` - nadie más necesita leerlo (mismo criterio que
  `hovered`/`expanded` en `AuroraPlayer.qml`).
- **Aurora Doctor**: panel de diagnóstico que reutiliza
  `AuroraConfig.developerMode` (existe desde Fase 1, sin consumidor
  todavía). Mostraría salud de cada Provider (`AuroraState.connected`,
  `AuroraState.audioAvailable`, futura salud del EQ Provider), plugins
  cargados (`AuroraPluginRegistry.registeredNames` ya lo expone) y temas
  encontrados en disco (mecanismo nuevo - falta resolver cómo listar
  `Themes/` en tiempo de ejecución).
- **Ajustes reorganizados** (General / Apariencia / Audio / Fuentes /
  Ecualizador / Avanzado / Acerca de) como panel/overlay que se abre
  desde un ícono dentro del widget - no como vista permanente con
  navegación propia, para no volver a caer en "sidebar de app".

### 3. Sistema de temas múltiples

- El mecanismo (`AuroraTheme` + `AuroraThemeProvider`) ya existe - cada
  tema nuevo es solo un `Theme.qml` adicional en `Themes/`, con la misma
  estructura que `Themes/Default/Theme.qml`.
- Temas a construir: Nebula (paleta morada/neón, ya bocetada en un mockup
  de referencia), Catppuccin, Nord, Tokyo Night, Gruvbox, Material - todos
  con paletas públicas y bien documentadas, bajo riesgo de diseño.
- `System` sigue siendo `ThemeSystem` (ya implementado, se adapta al host
  vía `AuroraThemeProvider.applySystemTheme()`) - no se toca.

---

Exploratorias / futuro

Ejecución exclusiva en terminal (modo alternativo sin UI gráfica completa y posiblemente la oficial).

Ejecución ocupando toda la parte inferior de la pantalla (modo barra completa).

Compatibilidad futura con otros ecosistemas y entornos más allá de Quickshell (alineado con el principio de "compatibilidad extrema" en PHILOSOPHY.md).
