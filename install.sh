#!/usr/bin/env bash
#
# Aurora installer - copia esta carpeta (Aurora/) dentro del
# mediaControls/ de un config de Quickshell, respaldando cualquier
# instalación previa que encuentre ahí.
#
# Uso:
#   ./install.sh                                    # destino por defecto
#   ./install.sh /ruta/a/tu/quickshell/mediaControls # destino custom
#
# Ver Blueprint/INSTALL.md para qué hacer después de instalar.

set -euo pipefail

DEFAULT_TARGET="$HOME/.config/quickshell/ii/modules/ii/mediaControls"
TARGET_DIR="${1:-$DEFAULT_TARGET}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SOURCE_DIR/Core/AuroraState.qml" ]; then
    echo "error: no encuentro Core/AuroraState.qml junto a este script." >&2
    echo "Corré install.sh desde la raíz de la carpeta Aurora extraída." >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

DEST="$TARGET_DIR/Aurora"

if [ -d "$DEST" ]; then
    BACKUP="$TARGET_DIR/Aurora.backup.$(date +%Y%m%d%H%M%S)"
    echo "Ya existe una instalación en $DEST - moviéndola a $BACKUP"
    mv "$DEST" "$BACKUP"
fi

echo "Copiando Aurora a $DEST"
cp -r "$SOURCE_DIR" "$DEST"

# .git no es parte de la instalación - solo llega si install.sh se
# corre directo desde un clon en vez de un zip extraído.
rm -rf "$DEST/.git"

echo "Listo. Importá AuroraPlayer desde:"
echo "  $DEST/Components/Layout"
echo "Ver $DEST/Blueprint/INSTALL.md para el resto (tema, plugins, etc.)."
