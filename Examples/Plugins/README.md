# Plugin de ejemplo — Examples/Plugins/

Este directorio contiene plantillas y no forma parte del descubrimiento
automático de Aurora.

El mecanismo real busca:

```text
~/.config/aurora/plugins/<plugin-id>/plugin.qml
```

Para probar el detector de navegadores:

```bash
mkdir -p ~/.config/aurora/plugins/browserDetector
cp Examples/Plugins/AuroraBrowserDetectorPlugin.qml \
   ~/.config/aurora/plugins/browserDetector/plugin.qml
```

Después de recargar Quickshell, Aurora debería registrar:

```text
[Aurora] Plugin registered: browserDetector
```

El plugin publica sus datos en:

```qml
AuroraState.plugins.browserDetector
```

## Qué cubre el ejemplo

- Inyección de `auroraState`, `auroraConfig` y `auroraRegistry`.
- Registro mediante `registerProvider()`.
- Namespacing en `AuroraState.plugins`.
- Limpieza mediante `unregisterProvider()`.
- Consumo desde `AuroraBrowserBadge`.

El ejemplo no debe copiarse dentro de `Providers/`. Los plugins de
terceros permanecen fuera del repositorio de Aurora.
