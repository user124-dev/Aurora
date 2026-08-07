# Casos de prueba manual — Examples/Plugins/

Estos dos casos verifican que el mecanismo de plugins (`Core/AuroraPluginRegistry.qml`
+ `AuroraBrowserDetectorPlugin.qml`) se comporta correctamente en sus dos rutas de
fallo esperadas: un plugin duplicado y una ruta inválida en `pluginPaths`. No son
tests automatizados (Aurora no tiene un framework de testing QML configurado) — son
pasos manuales para correr contra una instalación real de Quickshell.

La salida de ejemplo de abajo **no es hipotética**: se generó corriendo los archivos
reales de este repo (`AuroraPluginRegistry.qml`, `AuroraBrowserDetectorPlugin.qml`,
sin modificar) contra el runtime `qml` de Qt6 en un entorno headless, con un stub
mínimo del módulo `Quickshell` (que no está disponible fuera de una instalación real
de Quickshell). Los mensajes de log son textuales, tal como los imprimió el motor.

## Caso A — Registro duplicado

**Qué prueba:** que `registerProvider()` ignora un segundo intento de registro con
el mismo nombre, sin romper nada.

**Cómo reproducirlo:** apuntar `AuroraConfig.pluginPaths` al mismo archivo dos veces,
o instanciar `AuroraBrowserDetectorPlugin` dos veces a mano con el mismo
`auroraRegistry`:

```qml
property var pluginPaths: [
    "/home/tu-usuario/mis-plugins/AuroraBrowserDetectorPlugin.qml",
    "/home/tu-usuario/mis-plugins/AuroraBrowserDetectorPlugin.qml"
]
```

**Log real esperado** (orden: la primera instancia se registra e inicializa: la
segunda se rechaza):

```
[Aurora] Plugin registered: browserDetector
[AuroraBrowserDetectorPlugin] initialized
[Aurora] Plugin 'browserDetector' is already registered - ignoring duplicate.
```

**Resultado verificado:** `AuroraPluginRegistry.registeredNames` contiene
`browserDetector` una sola vez. La segunda instancia queda viva pero inerte — nunca
se le llama `initialize()`, nunca entra a `_providers`, no participa de nada. Sin
excepciones, sin crash, el resto de Aurora (`AuroraState`, `AuroraConfig`, etc.)
sigue funcionando con normalidad.

## Caso B — Ruta inválida en `pluginPaths`

**Qué prueba:** que `loadPlugin()` cae en la rama `Component.Error` sin propagar
el fallo al resto de Aurora.

**Cómo reproducirlo:** agregar una ruta que no existe:

```qml
property var pluginPaths: [
    "/ruta/que/no/existe/Fantasma.qml"
]
```

**Log real esperado** (el texto exacto de `errorString()` puede variar levemente
entre versiones de Qt, pero siempre nombra la ruta y la razón):

```
[Aurora] Plugin failed to load: /ruta/que/no/existe/Fantasma.qml file:///ruta/que/no/existe/Fantasma.qml:-1 No such file or directory
```

**Resultado verificado:** ningún objeto se crea para esa entrada,
`AuroraPluginRegistry.registeredNames` no cambia, y el resto de Aurora — incluyendo
otras entradas válidas en `pluginPaths`, si las hay — sigue cargando y funcionando
con total normalidad. Verificado leyendo `AuroraConfig.compact` y
`AuroraState.connected` inmediatamente después del intento fallido: ambos responden
igual que antes.

## Nota sobre un bug que este mismo trabajo destapó

Verificar estos dos casos con un runtime real (no solo `qmllint`, que no lo detecta)
encontró que `AuroraBrowserDetectorPlugin.qml` — y los tres Providers oficiales —
usaban `QtObject` como tipo raíz, que no tiene *default property* para contener
`Connections`/`Timer`/`Process` como hijos. Esto habría impedido que el plugin (y
los Providers) cargaran en una instalación real de Quickshell. Corregido: el plugin
ahora usa `Item` como raíz (no es `pragma Singleton`, así que no necesita el tipo
`Singleton` de Quickshell). Ver `DECISIONS.md` → "Corrección crítica: QtObject sin
default property" para el detalle completo, que afecta a más archivos que este.
