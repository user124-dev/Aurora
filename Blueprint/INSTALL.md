# Install

## Quick install

```bash
unzip Aurora-*.zip
cd <extracted-folder>
./install.sh
```

Copies `Aurora/` into `~/.config/quickshell/ii/modules/ii/mediaControls/`.
Backs up any existing install found there first (`Aurora.backup.<timestamp>`).

To install into a different Quickshell config:

```bash
./install.sh /path/to/your/quickshell/modules/mediaControls
```

## After installing

Import `AuroraPlayer` wherever the bar/config wants the widget:

```qml
import "ii/modules/ii/mediaControls/Aurora/Components/Layout" as Aurora

Aurora.AuroraPlayer { }
```

Pass `hostWidth`/`hostHeight` if the host has a specific slot for it -
Aurora fills exactly that space instead of managing its own size:

```qml
Aurora.AuroraPlayer {
    hostWidth: 400
    hostHeight: 80
}
```

Leave both unset (default) and Aurora sizes itself between
Compact/Hover/Expanded on hover and tap instead.

## Optional dependencies

- **cava** - powers the live spectrum in `AuroraSpectrum`. Without it,
  the spectrum falls back to a soft idle animation instead of real
  audio data. Nothing else in Aurora needs it.

## Theme

Aurora ships its own bundled theme by default
(`Themes/Default/Theme.qml`) - works with zero host integration. To use
the host shell's theme instead, open `Core/AuroraConfig.qml` and set:

```qml
property int themeMode: ThemeSystem
```

This is only implemented for "ii" today, in
`Providers/AuroraThemeProvider.qml`. Porting Aurora to a different host
means rewriting that one file - nothing else should need to change.
