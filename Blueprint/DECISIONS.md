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

**Corrección post-revisión:** `applySystemTheme()` mapeaba todas las
propiedades de color y de tamaño de fuente a un equivalente en
`Appearance`, salvo `fontFamily`, que seguía leyendo del `Theme` bundled
- inconsistente con el resto de la función sin explicación. Verificado
contra el código real de `end-4/dots-hyprland`
(`modules/common/Appearance.qml`): sí existe un equivalente,
`Appearance.font.family.main` (`Config.options.appearance.fonts.main`,
configurable por el usuario), la misma fuente de la que ya toman los
`pixelSize.*` de abajo. No era una decisión deliberada por falta de
equivalente - era un olvido. Corregido.

## Config vs. Theme

`AuroraConfig` = layout: sizes, radii, spacing, animation durations,
timers. Read directly by visual components - it's internal and static,
not a live external system, so host isolation doesn't apply to it.

`AuroraTheme` = look: colors and typography. Also read directly by
visual components, but its *values* are live and swappable (Aurora's
own palette vs. system-mapped), unlike Config's fixed constants.

## Actions go through AuroraState, not Providers

`AuroraState` exposes `togglePlaying()`, `next()`, `previous()`, `seek()`,
`toggleShuffle()`, `cycleRepeat()`, `selectPlayer()`. Components call
these instead of reaching into `AuroraPlayerProvider` directly - keeps
"components depend only on AuroraState" true for actions, not just for
reading data.

**Corrección post-revisión (fase 4):** estos siete eran, hasta esta
revisión, funciones de reenvío directo (`function togglePlaying() {
AuroraPlayerProvider.togglePlaying() }`), lo que obligaba a
`Core/AuroraState.qml` a importar `Providers/` - la única dirección de
dependencia que este proyecto descarta explícitamente (un archivo de
`Core/` no debe conocer `Providers/`; es al revés). Divergía del patrón
ya confirmado para este caso: señales en `AuroraState` que
`AuroraPlayerProvider` escucha vía `Connections`. Ahora estas siete son
`signal`, no `function`, y `AuroraState.qml` no importa nada de
`Providers/`. Desde un componente, invocar una señal y llamar una
función se ven exactamente igual (`AuroraState.togglePlaying()`), así
que nada fuera de estos dos archivos cambió.

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

## Fase 4: multi-player MPRIS

Hasta ahora `AuroraPlayerProvider` seguía un solo `MprisController.activePlayer`
sin alternativa - si sonaban dos fuentes a la vez (Spotify y una pestaña de
Firefox, por ejemplo) no había manera de elegir cuál mostrar ni cuál
controlar. Esto agrega:

- **`computeMeaningfulPlayers()`** - deduplica `MprisController.players`
  cuando dos entradas describen el mismo audio (una pestaña de navegador
  reflejando un player nativo, un proxy de notificaciones delante del
  real). Mismo problema que resuelve `Research/MediaControls.Reference.qml`,
  reescrito desde cero en vez de copiado: la comparación de posición/duración
  usa `Math.abs()` en ambos lados (la resta directa original lee "cercano"
  para cualquier par donde una posición es menor que la otra por más del
  margen, en la dirección equivocada), y un índice ya agrupado no vuelve a
  evaluarse contra un grupo posterior, así que una misma fuente no puede
  terminar representando dos grupos a la vez.
- **`AuroraState.players`** - lista plana (`{identity, title, selected}`)
  que `AuroraPlayerSwitcher` renderiza. Ningún componente ve un
  `MprisPlayer` directamente - mismo principio que ya aplica a todo lo
  demás en `AuroraState`.
- **`AuroraState.selectPlayer(identity)`** - fija manualmente cuál fuente
  mostrar y controlar. Si esa fuente desaparece, `resolveActivePlayer()`
  limpia la selección y vuelve sola a modo automático (sigue a
  `MprisController.activePlayer`, igual que antes de esta fase) en vez de
  quedarse pegado a algo que ya no existe.
- **Los comandos siguen al player mostrado, no al "activo" de MPRIS** -
  `togglePlaying()`, `next()`, `previous()`, `seek()`, `toggleShuffle()` y
  `cycleRepeat()` leen `resolveActivePlayer()` en vez de
  `MprisController.activePlayer` directamente. Sin esto, seleccionar
  Firefox en el switcher mostraría su metadata pero el botón de play
  seguiría controlando Spotify - un bug peor que cualquier caso donde un
  comando no haga nada.
- **`AuroraPlayerSwitcher` solo vive en `AuroraExpandedView`** por ahora -
  `AuroraCompactView` no tiene espacio y `AuroraHoverView` ya está justo.
  Con un solo player conectado no se renderiza (altura 0), así que no
  cambia nada para el caso más común.

**Limitación conocida:** la selección se fija por `identity` (nombre del
player, ej. `"Spotify"`), no por un id único de instancia - dos ventanas
del mismo player serían indistinguibles para el switcher. MPRIS no
garantiza un identificador mejor de forma genérica; queda documentado en
vez de resuelto con una suposición no confirmada.

## Fase 4: plugins de terceros

`PROVIDERS.md` ya definía cómo agregar un Provider oficial (vive en
`Providers/`, se agrega editando el repo). "Plugins" pedía algo distinto:
código externo que se conecta sin tocar el repo de Aurora en absoluto.
Esto agrega:

- **`Core/AuroraPluginRegistry`** - un plugin llama a
  `registerProvider(nombre, this)` desde su propio `Component.onCompleted`
  una vez que ya está vivo. El registro llama a `initialize()` en el
  plugin si existe, misma convención que ya siguen los 3 Providers
  oficiales.
- **Carga real vía `Qt.createComponent()`** - `AuroraConfig.pluginPaths`
  es solo una lista de rutas (absolutas o `file://`); `AuroraPlayer.qml`
  llama a `loadConfiguredPlugins()` en su `Component.onCompleted` y cada
  ruta se instancia sin que ningún archivo de Aurora la importe nunca.
  Sigue existiendo la opción de importar un plugin a mano junto a
  `AuroraPlayer`, para quien lo prefiera.
- **Inyección por propiedad, no por import** - un plugin recibe
  `auroraState`/`auroraConfig`/`auroraRegistry` como propiedades al
  crearse, en vez de hacer `import "../../Core"` como sí puede hacer un
  Provider oficial. Un plugin vive fuera de la carpeta de Aurora, así
  que no hay una ruta relativa confiable de vuelta a `Core/` - y una
  ruta absoluta se rompería en cuanto alguien instale Aurora en otro
  lugar (ver `INSTALL.md`).
- **`AuroraState.plugins["nombre"]`** - namespacing obligatorio. Un
  plugin nunca escribe en una propiedad de primer nivel de `AuroraState`
  (esas son de los Providers oficiales), solo dentro de su propio slot.
  Arquitectónicamente imposible que choque con otro plugin o con lo que
  ya escribe `AuroraPlayerProvider`/`AuroraAudioProvider`/
  `AuroraThemeProvider`.
- **`Examples/Plugins/AuroraBrowserDetectorPlugin.qml`** - prueba de
  concepto: lee `AuroraState.playerName` (ya público) y decide si la
  fuente que se muestra parece un navegador, sin importar nada de
  `Aurora/Core` directamente - valida el mecanismo completo end-to-end.
  Vive en `Examples/`, no en `Providers/`, a propósito: Aurora no lo
  carga por sí sola, es una plantilla para copiar. Todavía no dibuja
  nada en la UI - eso queda para cuando haya un caso real que lo pida.

Ver `PLUGINS.md` para la guía completa y las limitaciones conocidas
(sin limpieza automática al destruirse un plugin, sin versión de API
garantizada todavía).

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
