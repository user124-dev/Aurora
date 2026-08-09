# Conventions

## Naming

- Visual components (`Components/`) carry the `Aurora` prefix: `AuroraCover`, `AuroraInfo`, `AuroraControls`, `AuroraSpectrum`. Layout pieces too: `AuroraPlayer`, `AuroraBackground`.
- Providers end in `Provider`: `AuroraPlayerProvider`, `AuroraAudioProvider`, `AuroraThemeProvider`.
- Everything in `Core/` and `Providers/` that acts as a global service uses `pragma Singleton`. `Components/` contiene instancias visuales normales.

## Where new code goes

Ask in this order:

1. **Does it read or control an external system** (MPRIS, Cava, EasyEffects or a future host adapter)? → `Providers/`. Give a global service an `initialize()` function when startup work is required and have it write results into `AuroraState` or `AuroraTheme`. Never let a visual component contain that integration logic.
2. **Is it a fixed number that would otherwise be typed inline** (a size, radius, spacing, duration, timer interval)? → `AuroraConfig`. Read directly from components; no need to route static configuration through `AuroraState`.
3. **Is it a color or typography value** → `AuroraTheme`, written only by `AuroraThemeProvider`.
4. **Is it live data that changes at runtime** (track title, playback state, connection status, spectrum samples)? → `AuroraState`.
5. **Is it something the user sees and can interact with** → `Components/`. Visual components depend on `AuroraState`, `AuroraConfig` and `AuroraTheme` only.
6. **Is it bootstrap code** needed to initialize the widget's Providers? → `Components/Layout/AuroraPlayer.qml` may contain that bootstrap as the single controlled exception. It must not become a general-purpose service layer.

If it doesn't fit cleanly into one of these, that's worth a note in `Blueprint/DECISIONS.md` before writing the code, not after.

## File header

Every `Core/`, `Providers/` and `Components/Layout/` file opens with the same block comment: banner, `File`, `Module`, `Component`, `Version`, then a `Description`. Add a `Philosophy` line only if the file enforces a rule the rest of the project depends on.

Plain `Components/` files use a shorter version of the same block: banner + `File`/`Module`/`Component`/`Version` + `Description`.

## Comments

Code and comments are in English, regardless of what language the conversation building them happened in.

Comments should explain **why**, not restate **what** the code already makes obvious.

## Language in QML

- Prefer optional chaining (`p?.trackTitle`) and nullish coalescing (`?? ""`) over manual null checks when reading from an external object.
- `Core/` never imports `Providers/` or host-specific services.
- Visual Components never import Providers directly. They use `AuroraState` for runtime data and action signals.
- `Components/Layout/AuroraPlayer.qml` is the controlled bootstrap exception and may import Providers only to call their initialization entrypoints.
- Providers may import the official Quickshell APIs they actually need, such as `Quickshell`, `Quickshell.Services.Mpris` and `Quickshell.Io`.
- Private host modules such as End-4/ii `qs.services` or `qs.modules.common` are not runtime dependencies of Aurora.
