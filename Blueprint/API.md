# Public API

QML has no `private` keyword - anything can be imported from anywhere.
This document is the actual contract: what a host integrating Aurora
is meant to depend on, versus what's free to change inside a patch
release because nothing outside should be touching it.

Version: `0.1.0-dev`. Nothing here is stable yet - this is what the
contract will be once it is, written down early on purpose (see
`Blueprint/PHILOSOPHY.md` once that exists).

## Supported

### `Components/Layout/AuroraPlayer.qml`

The only component a host is expected to instantiate.

```qml
import "ii/modules/ii/mediaControls/Aurora/Components/Layout" as Aurora

Aurora.AuroraPlayer {
    hostWidth: 400   // optional - omit to let Aurora size itself
    hostHeight: 80   // optional - omit to let Aurora size itself
}
```

### `Core/AuroraConfig.qml`

Read-only for a host, with one exception:

```qml
AuroraConfig.themeMode = AuroraConfig.ThemeSystem  // or ThemeAurora
```

Every other property is `readonly` by design - see `CONVENTIONS.md`.

### `Core/AuroraState.qml` - reading

Safe to read for a host that wants to reflect Aurora's state elsewhere
(a taskbar tooltip, a lock screen widget): `connected`, `playerName`,
`playbackState`, `title`, `artist`, `album`, `coverArt`, `duration`,
`position`, `progress`, `canSeek`.

### `Core/AuroraState.qml` - signals

```qml
AuroraState.trackChanged.connect(function() { ... })
AuroraState.connectionChanged.connect(function(connected) { ... })
```

### `Core/AuroraState.qml` - actions

A host may trigger playback from its own UI instead of Aurora's:

```qml
AuroraState.togglePlaying()
AuroraState.next()
AuroraState.previous()
AuroraState.seek(0.5)  // 0.0 - 1.0
```

## Internal - do not depend on these from outside Aurora

- Everything in `Providers/` (`AuroraPlayerProvider`, `AuroraAudioProvider`,
  `AuroraThemeProvider`) - implementation detail, swappable per host,
  see `DECISIONS.md`.
- `Components/AuroraCover.qml`, `AuroraInfo.qml`, `AuroraControls.qml`,
  `AuroraSpectrum.qml`, `Components/Layout/AuroraBackground.qml` - internal
  building blocks of `AuroraPlayer`, not supported standalone.
- `Core/AuroraTheme.qml`, `Core/AuroraAnimations.qml` - tokens consumed
  by Aurora's own components, not meant to be read from outside.
- `Themes/Default/Theme.qml` - the data `AuroraThemeProvider` reads,
  not a contract itself.
- `Research/` - reference material only, never imported by any real
  Aurora code path.

## Adding to the public surface

If a host genuinely needs something from the internal list, that's a
sign `AuroraState`, `AuroraConfig` or `AuroraPlayer` is missing a
property - add it there, don't reach past it. Keeps this document
short enough to stay accurate.
