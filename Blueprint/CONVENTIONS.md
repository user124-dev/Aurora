# Conventions

## Naming

- Visual components (`Components/`) carry the `Aurora` prefix:
  `AuroraCover`, `AuroraInfo`, `AuroraControls`, `AuroraSpectrum`.
  Layout pieces too: `AuroraPlayer`, `AuroraBackground`.
- Providers end in `Provider`: `AuroraPlayerProvider`,
  `AuroraAudioProvider`, `AuroraThemeProvider`.
- Everything in `Core/` and `Providers/` is `pragma Singleton`. Nothing
  in `Components/` is - they're instantiated, sometimes more than once.

## Where new code goes

Ask in this order:

1. **Does it read an external system** (MPRIS, cava, a host theme)?
   → `Providers/`. Give it an `initialize()` function and have it
   write results into `AuroraState` or `AuroraTheme`. Never let it
   contain layout or visible items.
2. **Is it a fixed number that would otherwise be typed inline**
   (a size, radius, spacing, duration, timer interval)?
   → `AuroraConfig`. Read directly from components - no need to
   route it through `AuroraState`.
3. **Is it a color or a type size** → `AuroraTheme`, written only
   by `AuroraThemeProvider`.
4. **Is it live data that changes at runtime** (track title, playback
   state, connection status) → `AuroraState`.
5. **Is it something the user sees and can interact with** →
   `Components/`. Depends on `AuroraState`, `AuroraConfig`,
   `AuroraTheme` only - see `DECISIONS.md`.

If it doesn't fit cleanly into one of these, that's worth a note in
`DECISIONS.md` before writing the code, not after.

## File header

Every `Core/`, `Providers/` and `Components/Layout/` file opens with
the same block comment: banner, `File`, `Module`, `Component`,
`Version`, then a `Description`. Add a `Philosophy` line only if the
file enforces a rule the rest of the project depends on (see
`AuroraConfig.qml` and `AuroraState.qml` for the pattern). Plain
`Components/` files (`AuroraCover.qml` etc.) use a shorter version of
the same block - banner + `File`/`Module`/`Component`/`Version` +
`Description`, no `Philosophy` line needed for every single one.

## Comments

Code and comments are in English, regardless of what language the
conversation building them happened in. Matches every file already in
the project.

`// MARK: Section` dividers, wrapped in a `// ====...====` box, group
related properties inside `Core/` and `Providers/` files - see any
existing file in those folders for the exact spacing.

## Language in QML

- Prefer optional chaining (`p?.trackTitle`) and nullish coalescing
  (`?? ""`) over manual null checks when reading from an external
  object (a Provider reading MPRIS, a component reading a possibly-
  empty array).
- No `qs.*` or host-singleton imports below `Components/` or `Core/`.
  Only `Providers/` may import them - see `DECISIONS.md`.
