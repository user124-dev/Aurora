# Temas en Aurora

Aurora está diseñado para que los temas sean intercambiables y fáciles de crear, siguiendo el principio de "libre elección de temas y de código" (`PHILOSOPHY.md`).

## Estructura actual

```
Themes/
└── Default/
    ├── Theme.qml
    └── temas WIP   # notas de trabajo, no un tema real
```

Solo existe el tema `Default` por ahora, ya con una paleta real (`colorBackground`, `colorPrimary`, tipografía, etc. — ver `Themes/Default/Theme.qml`).

## Cómo funciona

- Ningún componente visual (`AuroraSpectrum`, `AuroraControls`, `AuroraCover`, `AuroraInfo`) lee colores de un host externo (`Appearance.colors.*`) directamente — todos leen de `Core/AuroraTheme.qml`, el único contrato visual permitido (ver `DECISIONS.md` → "Host isolation").
- `AuroraConfig.themeMode` decide la fuente: `ThemeAurora` (paleta propia, valor `0`) o `ThemeSystem` (adaptado al host, valor `1`) — son constantes `int`, no strings.
- `AuroraThemeProvider` es el único módulo con permiso para depender del host y traducir eso a `AuroraTheme`.

> Nota (actualizada en fase 3): la migración de componentes a `AuroraTheme` ya está hecha — ninguno de los cuatro importa `qs.modules.common`. Lo único todavía abierto en este frente es que `AuroraThemeProvider` no es reactivo en modo `ThemeSystem` si el host cambia de tema en caliente (ver `DECISIONS.md` → "Abierto / Pendiente").

## Cómo crear un tema nuevo (borrador de proceso)

1. Duplicar `Themes/Default/` en `Themes/<NombreDelTema>/`.
2. Definir la paleta de colores en el `Theme.qml` correspondiente.
3. Verificar que ningún componente tenga colores hardcodeados fuera del sistema de temas.
4. Documentar el tema (nombre, autor, capturas si es posible).

`AuroraTheme`/`AuroraThemeProvider` ya están implementados; lo pendiente para v0.2 es formalizar este borrador en un proceso probado con al menos un tema real además de `Default` (ver `ROADMAP.md`).
