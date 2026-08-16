# Temas en Aurora

Aurora separa el contrato visual (`Core/AuroraTheme.qml`) de la fuente de valores (`Themes/*.json`) mediante `AuroraThemeProvider`. Los componentes nunca deben leer directamente archivos de tema ni depender de un host.

## Estructura actual

```text
Themes/
├── aurora.json
├── midnight.json
├── paper.json
└── nebula.json
```

Cada archivo define únicamente datos visuales. `Core/AuroraTheme.qml` conserva el contrato estable que consumen los componentes y `Providers/AuroraThemeProvider.qml` carga la definición seleccionada desde `Quickshell.shellDir + "/Themes"`.

## Selección

La selección persistente se guarda fuera del runtime en:

```text
~/.config/aurora/theme.json
```

Se administra mediante:

```text
aurora-theme list
aurora-theme current
aurora-theme set <theme>
aurora-theme reset
```

`aurora-theme list` descubre automáticamente los archivos `Themes/*.json`, por lo que añadir un nuevo tema no requiere modificar un `switch` de QML.

## Modos

`AuroraConfig.themeMode` define el modo lógico:

- `themeAurora` — usa el tema seleccionado de la colección Aurora.
- `themeSystem` — reservado para adapters de host. En standalone mantiene la colección local para evitar dependencias externas.

La implementación no importa `qs.modules.common` ni ningún singleton de End-4/ii.

## Contrato

Los componentes consumen exclusivamente:

```qml
AuroraTheme.colorBackground
AuroraTheme.colorPrimary
AuroraTheme.fontFamily
```

No deben importar `Appearance`, Material Symbols u otro sistema visual del host.

## Crear un tema

1. Crear `Themes/<nombre>.json`.
2. Mantener las propiedades del contrato de `AuroraTheme`.
3. Mantener el archivo como datos, sin lógica de runtime.
4. Validar JSON y ejecutar `aurora-theme list`.
5. Ejecutar `aurora-doctor` antes de integrar el cambio.

Los adapters de temas específicos de compositor o shell deben mantenerse fuera del Core y añadirse solo cuando exista una integración real que probar.
