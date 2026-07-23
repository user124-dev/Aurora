# Temas en Aurora

Aurora está diseñado para que los temas sean intercambiables y fáciles de crear, siguiendo el principio de "libre elección de temas y de código" (`PHILOSOPHY.md`).

## Estructura actual

```
Themes/
└── Default/
    ├── Theme.qml
    └── temas WIP   # notas de trabajo, no un tema real
```

Solo existe el tema `Default` por ahora. `Theme.qml` está vacío/en construcción — es el punto de partida para definir la paleta de colores propia de Aurora.

## Cómo debería funcionar (según arquitectura planeada)

- Ningún componente visual (`Spectrum.qml`, `Cover.qml`, etc.) debe leer colores de un host externo (`Appearance.colors.*`) de forma permanente — la meta es que todos lean de un singleton propio, ej. `Core/AuroraTheme.qml` (ver `DECISIONS.md` → "Theme sourcing").
- `AuroraConfig.themeMode` decide si se resuelve como `"default"` (paleta propia de Aurora) o `"system"` (adaptado al tema del host/Quickshell).
- Un `AuroraThemeProvider` sería el único módulo con permiso para depender del host y traducir eso a `AuroraTheme`.

> Nota: actualmente varios componentes (`Spectrum.qml`, `Controls.qml`, `Cover.qml`, `Info.qml`) todavía importan `qs.modules.common` y leen `Appearance.colors.*` directamente. Esto es una deuda técnica pendiente de migrar hacia `AuroraTheme`, no el estado final deseado.

## Cómo crear un tema nuevo (borrador de proceso)

1. Duplicar `Themes/Default/` en `Themes/<NombreDelTema>/`.
2. Definir la paleta de colores en el `Theme.qml` correspondiente.
3. Verificar que ningún componente tenga colores hardcodeados fuera del sistema de temas.
4. Documentar el tema (nombre, autor, capturas si es posible).

Este proceso se formalizará una vez que `AuroraTheme`/`AuroraThemeProvider` estén implementados (ver `ROADMAP.md`, v0.2).
