# Providers

Los Providers son la única capa de Aurora con permiso para hablar con servicios externos (MPRIS, procesos del sistema). Ningún componente visual debe importar o llamar servicios externos directamente.

## AuroraPlayerProvider

**Responsabilidad:** leer metadata y estado de reproducción vía MPRIS, y enviar comandos de vuelta.

- Usa `qs.services` (`MprisController`) para leer `activePlayer`.
- Sincroniza en `initialize()` y ante los eventos `onTrackChanged` / `onActivePlayerChanged`.
- Hace polling de `position` cada `AuroraConfig.positionUpdateInterval` ms mientras se reproduce, porque MPRIS no emite continuamente cambios de posición.
- Expone comandos (`togglePlaying`, `next`, `previous`, `seek`) para que los componentes nunca toquen `MprisController` directamente.

## AuroraAudioProvider

**Responsabilidad:** alimentar `AuroraState.spectrumLevels` con datos reales de audio.

- Lanza el proceso externo `cava`, usando la configuración en `Assets/cava/raw_output_config.txt`.
- Solo corre mientras `AuroraState.playbackState === "Playing"` (ahorro de CPU).
- Parsea la salida (`;`-separada) y normaliza los valores a un rango 0–1 usando `maxRange`.
- Si `cava` no está instalado o falla, `spectrumLevels` queda vacío — `Spectrum.qml` debe manejar ese caso con una animación idle (ya implementado).

**Estado:** ⚠️ Esta es la pieza más importante pendiente de validar en producción — ver `DECISIONS.md` (Spectrum data source).

## Reglas para agregar un nuevo Provider

1. Vive en `Providers/`, es un `pragma Singleton`.
2. Solo escribe en `AuroraState`, nunca lo lee un componente para escribir de vuelta.
3. Expone funciones públicas explícitas para cualquier comando — no expone el objeto externo (`MprisController`, `Process`, etc.) directamente a otros módulos.
4. Documenta el "por qué" de decisiones no obvias (timers, polling, fallback) en comentarios, como ya hacen `AuroraPlayerProvider` y `AuroraAudioProvider`.
