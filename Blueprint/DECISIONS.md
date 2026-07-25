# Decisions

## Host isolation

Visual components (`AuroraCover`, `AuroraInfo`, `AuroraControls`,
`AuroraSpectrum`) depend on `AuroraState`, `AuroraConfig` and `AuroraTheme`
only. They never import a Provider, never import anything under `qs.*`
(the "ii" host), and never reference a host singleton like `Appearance`
directly.

Everything that touches the outside world lives in `Providers/`:

- `AuroraPlayerProvider` - MPRIS, via the host's `MprisController`
- `AuroraAudioProvider` - the spectrum, via `cava`
- `AuroraThemeProvider` - the host's theme, via `Appearance` - or Aurora's
  own bundled theme, depending on `AuroraConfig.themeMode`

This is the rule the rest of these decisions exist to protect: if Aurora
ever needs to run in a shell other than "ii", only the three files above
change. Nothing under `Core/` or `Components/` should need to.

Today that isolation is architectural, not literal portability - the
component files have zero host imports, but `AuroraThemeProvider.qml`
still hard-imports `qs.modules.common` to read `Appearance` for
`ThemeSystem` mode, because "ii" is the only host that exists to test
against right now. Porting to a second host means writing a new
`applySystemTheme()` for it - a one-file change, which is the point.

## Config vs. Theme

`AuroraConfig` = layout: sizes, radii, spacing, animation durations,
timers. Read directly by visual components - it's internal and static,
not a live external system, so host isolation doesn't apply to it.

`AuroraTheme` = look: colors and typography. Also read directly by
visual components, but its *values* are live and swappable (Aurora's
own palette vs. system-mapped), unlike Config's fixed constants.

## Actions go through AuroraState, not Providers

`AuroraState` exposes `togglePlaying()`, `next()`, `previous()`, `seek()`.
Components call these instead of reaching into `AuroraPlayerProvider`
directly - keeps "components depend only on AuroraState" true for
actions, not just for reading data. `AuroraState` is the one file in
`Core/` that imports `Providers/` for this reason.

## Naming

Visual components carry the `Aurora` prefix (`AuroraCover`, not `Cover`)
- Aurora's own identity, not borrowed from "ii". Aurora is not a fork of
"ii" and doesn't copy its code, only conceptual patterns (confirmed
against `Research/*.Reference.qml`, kept read-only for that purpose).

## Icons

`AuroraControls` and `AuroraCover`'s fallback draw their own icons with
`QtQuick.Shapes` and plain `Text`, instead of a host icon font
(`MaterialSymbol` in "ii"). Slower to look polished, but keeps the
host-isolation rule true down to the last file. `Assets/Icons/` is still
empty and is where a real icon set would replace these.

## Spectrum data source

`Ideas.md` y `PROVIDERS.md` señalan una "decisión abierta de la fuente de
datos del espectro" en este documento — no existía todavía como sección
propia, solo como razonamiento disperso en `Ideas.md`. Esto la deja
formal: **cava** es la fuente elegida. `AuroraAudioProvider` lo lanza como
proceso externo, parsea su salida `;`-separada y normaliza cada valor a
0–1 en `AuroraState.spectrumLevels` — un arreglo real, un valor por barra,
no un promedio único. Las dos preguntas que `Ideas.md` marcaba como
abiertas (¿cava u otra fuente? ¿arreglo o escalar?) están resueltas e
implementadas.

Lo que sigue abierto es otra cosa: **validar cava contra audio real en
producción**, no la elección en sí (ver `PROVIDERS.md` → "Estado").
Implementado y probado no son la misma afirmación.

## Fase 3: tres Views en vez de un `RowLayout` condicional

Antes de esta fase, todo el layout vivía en `AuroraPlayer.qml`: un
`RowLayout` con Cover/Info/Spectrum/Controls y visibilidad condicional
según `hovered`/`expanded`/`hostSized`. El propio archivo ya marcaba que
"Expanded" no tenía diseño propio — reusaba `hoverHeight` (72) en vez de
`expandedHeight` (300) "hasta que eso se diseñe".

Se dividió en tres archivos nuevos bajo `Components/Layout/`:

- **`AuroraCompactView`** — solo Cover, centrado y recortado al espacio
  disponible. Mismo comportamiento de antes, ahora en su propio archivo.
- **`AuroraHoverView`** — Cover + Info + Controls en una fila, con
  `showSpectrum` opcional (`false` por defecto). Cubre tanto el popup de
  hover normal como el caso `hostSized`, que antes eran dos ramas de
  visibilidad dentro del mismo `RowLayout`.
- **`AuroraExpandedView`** — layout nuevo para los 520×300 que
  `AuroraConfig.expandedWidth/expandedHeight` ya reservaban: Cover+Info
  arriba, Spectrum ocupando el espacio restante (`Layout.fillHeight`),
  Controls abajo centrado.

`AuroraPlayer.qml` ahora solo decide *cuál* de los tres cargar (vía
`Loader.sourceComponent`) y ya no importa `AuroraCover`/`AuroraInfo`/
`AuroraSpectrum`/`AuroraControls` directamente — esos imports se movieron
a los Views que realmente los usan. `implicitHeight` en modo expandido
ahora sí usa `AuroraConfig.expandedHeight`.

Constantes nuevas en `AuroraConfig`, para que ninguno de los tres archivos
tenga números sueltos: `widgetPadding`/`widgetSpacing` (compartidas entre
Compact y Hover — ya existían como literales `8`/`10` dentro del
`RowLayout` viejo) y `expandedPadding`/`expandedSpacing`/
`expandedCoverSize`/`expandedSpectrumHeight` (nuevas, solo para el card
expandido).

**Por qué `Loader` y no tres `Item` con visibilidad condicional:** mismo
criterio que ya usa el resto del proyecto — mantener vivo solo lo que
realmente se muestra, en vez de instanciar Cover/Info/Spectrum/Controls
tres veces cuando solo una copia es visible a la vez.

## Abierto / Pendiente

- **Theme no es reactivo en modo ThemeSystem.** `AuroraThemeProvider.resolve()`
  copia los valores de `Appearance` una sola vez (al iniciar, o cuando
  `themeMode` cambia). Si el host cambia de tema en caliente mientras
  `ThemeSystem` ya está activo, `AuroraTheme` no se entera hasta que algo
  vuelva a llamar `resolve()`. Arreglarlo de raíz implica escuchar alguna
  señal de cambio de color de "ii" - no confirmada todavía - o mover el
  binding a otro lado sin romper el aislamiento de host. Ver el comentario
  en `AuroraThemeProvider.qml`.
- **`Providers/Internal/`, `Providers/External/`, `Components/Common/`,
  `Components/Media/`** están vacías: espacio reservado en la
  estructura, sin uso ni decisión tomada todavía sobre qué va ahí.
