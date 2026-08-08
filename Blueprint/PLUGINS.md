# Plugins en Aurora

Un plugin es código de terceros que vive **fuera del repositorio de
Aurora** y se conecta en tiempo de ejecución.

Los Providers oficiales siguen siendo parte de `Providers/` y se
mantienen dentro del repositorio. Un plugin no necesita modificar Aurora
para instalarse.

## Descubrimiento automático

Aurora no mantiene una lista de rutas de plugins en `AuroraConfig`.

El registro busca automáticamente este directorio:

```text
~/.config/aurora/plugins/
└── <plugin-id>/
    ├── plugin.qml
    └── recursos.qml
```

Si `XDG_CONFIG_HOME` está definido, se utiliza:

```text
$XDG_CONFIG_HOME/aurora/plugins/
```

Solo se carga un archivo llamado exactamente `plugin.qml` a dos niveles
de profundidad. Esto evita que Aurora intente instanciar por accidente
componentes auxiliares del plugin.

`AuroraPluginRegistry` utiliza `Qt.createComponent()` para cargar cada
entrypoint y le inyecta:

```qml
property var auroraState
property var auroraConfig
property var auroraRegistry
```

El plugin no debe importar rutas internas de Aurora.

## Entry point de un plugin

Ejemplo mínimo:

```qml
import QtQuick

Item {
    property var auroraState
    property var auroraConfig
    property var auroraRegistry

    readonly property string pluginName: "example"

    function initialize() {
        // Inicialización opcional.
    }

    Component.onCompleted: {
        auroraRegistry.registerProvider(pluginName, this)
    }

    Component.onDestruction: {
        auroraRegistry.unregisterProvider(pluginName)
    }
}
```

El registro expone una versión de API:

```qml
auroraRegistry.apiVersion
```

Los plugins deben evitar depender de detalles internos que no formen
parte del contrato documentado.

## Namespacing obligatorio

Un plugin **nunca** escribe directamente en propiedades de primer nivel
de `AuroraState`.

Correcto:

```qml
const next = Object.assign({}, auroraState.plugins ?? ({}))
next.example = {
    enabled: true
}
auroraState.plugins = next
```

Resultado:

```qml
AuroraState.plugins.example
```

Esto evita colisiones entre plugins y evita que un plugin modifique el
estado que pertenece a los Providers oficiales.

## Ejemplo incluido

`Examples/Plugins/AuroraBrowserDetectorPlugin.qml` es una plantilla.
No se instala ni se carga automáticamente desde `Examples/`.

Para probarlo:

1. Crear `~/.config/aurora/plugins/browserDetector/`.
2. Copiar el ejemplo como `plugin.qml`.
3. Reiniciar/reloadar Quickshell.
4. Aurora lo descubrirá automáticamente.

El plugin detecta Firefox/Chromium/Chrome/Brave a partir de la identidad
MPRIS y publica sus datos en:

```qml
AuroraState.plugins.browserDetector
```

`Components/Media/AuroraBrowserBadge.qml` consume esos datos sin conocer
el archivo del plugin ni el registro.

## Responsabilidades

```text
AuroraPluginRegistry
        │
        ├── descubre plugins
        ├── instancia entrypoints
        ├── inyecta el contrato Aurora
        └── registra/desregistra plugins
                    │
                    ▼
                 Plugin
                    │
                    ▼
          AuroraState.plugins.<id>
                    │
                    ▼
             Componentes UI
```

El registro no contiene lógica específica de un plugin.

## Compatibilidad

La API de plugins todavía está en fase inicial. `apiVersion` existe para
poder evolucionarla de forma explícita antes de prometer compatibilidad
hacia atrás.
