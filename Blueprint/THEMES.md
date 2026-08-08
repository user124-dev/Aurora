# Temas en Aurora

Aurora separa el contrato visual (`Core/AuroraTheme.qml`) de la fuente de valores (`AuroraThemeProvider`). Los componentes nunca deben leer directamente el tema de un host.

## Estructura actual

```text
Themes/
└── Default/
    └── Theme.qml
```

`Default` es el tema standalone y la fuente predeterminada de Aurora.

## Modos

`AuroraConfig.themeMode` define el modo lógico:

- `themeAurora` — usa la paleta incluida en Aurora.
- `themeSystem` — reservado para adapters de host. En standalone mantiene la paleta Aurora para evitar dependencias externas.

La implementación actual no importa `qs.modules.common` ni ningún singleton de End-4/ii.

## Contrato

Los componentes consumen:

```qml
AuroraTheme.colorBackground
AuroraTheme.colorPrimary
AuroraTheme.fontFamily
```

No deben importar `Appearance`, Material Symbols u otro sistema visual del host.

## Crear un tema

1. Duplicar `Themes/Default/` en `Themes/<Nombre>/`.
2. Mantener el contrato de propiedades de `AuroraTheme`.
3. Evitar lógica de runtime dentro del archivo de tema.
4. Documentar autor, licencia y cambios visuales.
5. Validar el tema con `aurora-doctor`.

Los adapters de temas específicos de compositor o shell deben mantenerse fuera del Core y añadirse solo cuando exista una integración real que probar.
