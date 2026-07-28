# Plugins en Aurora

Un plugin es código de un tercero que vive **fuera** de la carpeta de
Aurora y se conecta en tiempo de ejecución. No es lo mismo que agregar
un Provider nuevo — `PROVIDERS.md` y sus 4 reglas siguen siendo para
código de Aurora mismo, el que se agrega editando el repo vía fork + PR.

## Por qué no es lo mismo que "agregar un Provider"

Un Provider oficial vive en `Providers/`, es un `pragma Singleton`, y
llega a `Core/AuroraState`/`AuroraConfig` con un simple
`import "../Core"` porque su ruta relativa dentro del repo es fija y
conocida. Un plugin es lo opuesto: nadie edita el repo de Aurora para
agregar uno, así que no tiene una ruta relativa confiable de vuelta a
`Core/` — y una ruta absoluta se rompería en cuanto alguien instale
Aurora en otro lugar (ver `INSTALL.md`).

Por eso un plugin nunca importa nada de Aurora directamente. En vez de
eso, recibe `AuroraState`, `AuroraConfig` y el propio registro como
**propiedades**, asignadas por quien lo instancia:

```qml
// El plugin solo declara esto - no las llena él mismo
property var auroraState
property var auroraConfig
property var auroraRegistry
```

## Dos formas de cargar un plugin

### 1. Vía `AuroraConfig.pluginPaths` (sin tocar el repo de Aurora en absoluto)

```qml
// En tu propio AuroraConfig.qml, o donde prefieras configurarlo
property var pluginPaths: [
    "/home/tu-usuario/mis-plugins/AuroraBrowserDetectorPlugin.qml"
]
```

`AuroraPlayer.qml` llama a `AuroraPluginRegistry.loadConfiguredPlugins()`
en su `Component.onCompleted`. Esta función usa `Qt.createComponent()`
sobre cada ruta y le pasa `auroraState`/`auroraConfig`/`auroraRegistry`
al crear el objeto. Usá rutas absolutas o `file://` — no relativas, un
plugin puede vivir en cualquier lado.

### 2. Importándolo vos mismo, junto a `AuroraPlayer`

```qml
import "ii/modules/ii/mediaControls/Aurora/Core" as AuroraCore
import "ruta/a/tus/plugins" as MyPlugins

MyPlugins.AuroraBrowserDetectorPlugin {
    auroraState: AuroraCore.AuroraState
    auroraConfig: AuroraCore.AuroraConfig
    auroraRegistry: AuroraCore.AuroraPluginRegistry
}
```

Ambos caminos terminan igual: el plugin, ya vivo, se anuncia solo:

```qml
Component.onCompleted: {
    auroraRegistry.registerProvider("nombre-del-plugin", this)
}
```

`registerProvider()` llama a `initialize()` en el plugin si existe (la
misma convención que ya siguen los 3 Providers oficiales).

## Dónde escribe sus datos un plugin

**Nunca** en una propiedad de primer nivel de `AuroraState` (`title`,
`connected`, etc. — esas son de los Providers oficiales). Siempre en su
propio espacio dentro de `AuroraState.plugins`, reasignando el objeto
completo (no mutando el existente in-place, o QML no notifica el
cambio):

```qml
AuroraState.plugins = Object.assign({}, AuroraState.plugins, {
    "nombre-del-plugin": { loQueSea: true }
})
```

Esto hace arquitectónicamente imposible que un plugin choque con lo que
ya escriben `AuroraPlayerProvider` / `AuroraAudioProvider` /
`AuroraThemeProvider`, o con otro plugin — ver la Philosophy en
`Core/AuroraPluginRegistry.qml`.

## Ejemplo de referencia

`Examples/Plugins/AuroraBrowserDetectorPlugin.qml` lee
`AuroraState.playerName` (ya público — lo mismo que lee `AuroraInfo`) y
decide si la fuente que se está mostrando parece un navegador
(Firefox/Chromium/Chrome/Brave), escribiendo el resultado en
`AuroraState.plugins["browserDetector"]`. No importa nada de
`Aurora/Core` directamente — recibe todo por propiedad, como se describe
arriba. Vive en `Examples/` y no en `Providers/` a propósito: es una
plantilla para copiar y adaptar, no algo que Aurora cargue por sí sola.

Ahora mismo no dibuja nada — solo deja el dato disponible en
`AuroraState.plugins`. Conectarlo a un componente visual (un ícono de
navegador junto a `AuroraInfo`, por ejemplo) queda pendiente para cuando
haya un caso real que lo pida.

## Limitaciones conocidas (v0.1 de esto)

- No hay limpieza automática al destruirse un plugin — existe
  `unregisterProvider()`, pero cada plugin tiene que llamarla él mismo
  (típicamente desde su propio `Component.onDestruction`) si le importa
  limpiar detrás suyo.
- `Qt.createComponent()` no valida qué hace el plugin una vez cargado —
  uno mal escrito puede ensuciar su propio slot en `AuroraState.plugins`,
  pero no puede tocar nada más gracias al namespacing.
- Esto es una prueba de concepto, no un sistema con versión de API
  garantizada. Si la forma de `AuroraState` cambia en una fase futura,
  un plugin viejo podría necesitar ajustarse — no hay compromiso de
  compatibilidad todavía.
