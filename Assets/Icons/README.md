# Assets/Icons

Reserved for a real icon set (image assets - SVG/PNG), replacing the
hand-drawn `QtQuick.Shapes`/`Text` glyphs currently used in
`AuroraControls.qml` and `AuroraCover.qml`'s fallback (see `DECISIONS.md`
→ "Icons"). Empty until a concrete set is chosen.

## Expected icon set

Matches the glyphs currently drawn by hand, one file per name:

| Name              | Currently used in            |
|-------------------|-------------------------------|
| `play.svg`        | `AuroraControls.qml`          |
| `pause.svg`       | `AuroraControls.qml`          |
| `previous.svg`    | `AuroraControls.qml`          |
| `next.svg`        | `AuroraControls.qml`          |
| `shuffle.svg`      | `AuroraControls.qml`          |
| `repeat.svg`       | `AuroraControls.qml`          |
| `music-note.svg`  | `AuroraCover.qml` (fallback)  |

## Rules

- SVG preferred (scales cleanly across Compact/Hover/Expanded sizes).
- No embedded color - icons must tint via `AuroraTheme.colorOnBackground`
  / `colorPrimary` at runtime, same as the current hand-drawn glyphs.
- Adding a real set here is a `Components/` change, not a `Core/` one -
  each icon-drawing block in `AuroraControls.qml`/`AuroraCover.qml` swaps
  its `Shape`/`Text` for an `Image { source: "../Assets/Icons/<name>.svg" }`.
  No `AuroraConfig`/`AuroraState` changes required.
