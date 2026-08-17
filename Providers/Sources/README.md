# Source providers

This directory is the reserved extension point for future source-specific adapters.

## Rule: MPRIS first

Spotify, MPV, VLC, Firefox/Chromium and other media applications should enter Aurora through MPRIS whenever they expose the required capability.

A source-specific adapter belongs here only when the generic MPRIS contract cannot provide a capability Aurora actually needs. The adapter must normalize its data into Aurora's existing state contract rather than exposing application-specific objects to Components.

```text
Application
    │
    ├── MPRIS ───────────────┐
    │                        ▼
    │                 AuroraPlayerProvider
    │                        │
    └── specialized adapter ─┤  only when needed
                             ▼
                        AuroraState
                             ▼
                         Components
```

## Required contract for a future adapter

A future source adapter should provide, at minimum:

- stable source identity;
- display name and source kind;
- normalized track metadata;
- playback state and timeline;
- explicit capability flags instead of assumed operations;
- availability/connection state;
- graceful fallback when the source disappears;
- no direct dependency from Components on the external application.

If a capability can be represented by the existing `AuroraState` contract, extend that contract before creating application-specific UI.

## Planned candidates

- Spotify: MPRIS baseline; specialized adapter only for Spotify-only capabilities.
- MPV: MPRIS baseline; optional adapter for MPV-specific metadata/control.
- VLC: MPRIS baseline; optional adapter for VLC-specific capabilities.
- Browsers: MPRIS baseline plus optional browser detector/plugin for richer source identity.

This directory intentionally contains no application-specific runtime implementation yet. It is an architectural extension point, not a collection of speculative integrations.
