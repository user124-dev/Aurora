#!/usr/bin/env bash
# Aurora installer / updater
# Installs Aurora as a named standalone Quickshell configuration.
# Required dependency: Quickshell >= 0.2.0.
# Optional dependencies: Cava for the spectrum, curl for remote cover art/lyrics.

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_BASE="${XDG_CONFIG_HOME:-${HOME}/.config}"
DEFAULT_TARGET="${CONFIG_BASE%/}/quickshell/Aurora"
BIN_DIR="${HOME}/.local/bin"
TARGET_DIR="$DEFAULT_TARGET"
BACKUP_ENABLED=true
DRY_RUN=false
MIN_QS_VERSION="0.2.0"

info() { printf '\033[1;36m[Aurora]\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m[Aurora]\033[0m %s\n' "$*"; }
warning() { printf '\033[1;33m[Aurora]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[Aurora]\033[0m %s\n' "$*" >&2; }

usage() {
    cat <<EOF
Aurora installer

Usage:
  ./install.sh
  ./install.sh --dry-run
  ./install.sh --no-backup
  ./install.sh --target PATH

Default installation:
  $DEFAULT_TARGET

After installation:
  qs -c Aurora
  aurora-doctor
  aurora-theme list
EOF
}

while (($# > 0)); do
    case "$1" in
        --target)
            if [[ $# -lt 2 ]]; then
                error "--target requiere una ruta."
                exit 2
            fi
            TARGET_DIR="$2"
            shift 2
            ;;
        --no-backup) BACKUP_ENABLED=false; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) error "Opción desconocida: $1"; usage >&2; exit 2 ;;
    esac
done

DEST_DIR="${TARGET_DIR%/}"
VERSION_FILE="$SCRIPT_DIR/VERSION"

require_file() {
    if [[ ! -f "$SCRIPT_DIR/$1" ]]; then
        error "Archivo requerido faltante: $1"
        exit 1
    fi
}

for file in \
    VERSION shell.qml install.sh aurora-doctor aurora-theme \
    Core/AuroraState.qml Core/AuroraConfig.qml Core/AuroraPluginRegistry.qml \
    Components/Layout/AuroraPlayer.qml \
    Providers/AuroraMprisController.qml Providers/AuroraPlayerProvider.qml; do
    require_file "$file"
done

if command -v realpath >/dev/null 2>&1; then
    source_real="$(realpath -m "$SCRIPT_DIR")"
    dest_real="$(realpath -m "$DEST_DIR")"
    if [[ "$dest_real" == "$source_real" || "$dest_real" == "$source_real/"* ]]; then
        error "El destino de instalación no puede estar dentro del repositorio Aurora."
        exit 1
    fi
fi

AURORA_VERSION="$(<"$VERSION_FILE")"
info "Aurora $AURORA_VERSION"
info "Destino: $DEST_DIR"

command_version() {
    local command="$1"
    "$command" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

QS_CMD=""
if command -v qs >/dev/null 2>&1; then QS_CMD="qs"; fi
if [[ -z "$QS_CMD" ]] && command -v quickshell >/dev/null 2>&1; then QS_CMD="quickshell"; fi

version_at_least() {
    [[ "$(printf '%s\n%s\n' "$MIN_QS_VERSION" "$1" | sort -V | head -n1)" == "$MIN_QS_VERSION" ]]
}

package_manager() {
    if command -v pacman >/dev/null 2>&1; then echo pacman
    elif command -v dnf >/dev/null 2>&1; then echo dnf
    elif command -v apt-get >/dev/null 2>&1; then echo apt
    elif command -v zypper >/dev/null 2>&1; then echo zypper
    elif command -v emerge >/dev/null 2>&1; then echo emerge
    elif command -v nix >/dev/null 2>&1; then echo nix
    elif command -v guix >/dev/null 2>&1; then echo guix
    else echo none; fi
}

install_package() {
    local manager="$1" package="$2"
    local sudo_cmd=()
    if [[ $EUID -ne 0 ]]; then sudo_cmd=(sudo); fi

    case "$manager" in
        pacman) "${sudo_cmd[@]}" pacman -S --needed "$package" ;;
        dnf) "${sudo_cmd[@]}" dnf install -y "$package" ;;
        apt) "${sudo_cmd[@]}" apt-get update && "${sudo_cmd[@]}" apt-get install -y "$package" ;;
        zypper) "${sudo_cmd[@]}" zypper --non-interactive install "$package" ;;
        emerge) "${sudo_cmd[@]}" emerge --ask=n "$package" ;;
        nix) nix profile install "nixpkgs#$package" ;;
        guix) guix install "$package" ;;
        *) return 1 ;;
    esac
}

ask_required() {
    local name="$1"
    printf '\n'
    warning "Dependencia clave faltante: $name"
    printf '¿Desea instalarla? [Y/n] '
    read -r answer
    answer="${answer:-Y}"
    [[ "$answer" =~ ^[Yy]$ ]]
}

ask_optional() {
    local name="$1"
    printf '\n'
    warning "Dependencia opcional faltante: $name"
    printf '¿Desea instalarla? [Y/n] '
    read -r answer
    answer="${answer:-Y}"
    [[ "$answer" =~ ^[Yy]$ ]]
}

MANAGER="$(package_manager)"

if [[ -z "$QS_CMD" ]]; then
    if ! ask_required "Quickshell >= $MIN_QS_VERSION"; then
        error "Fallo de instalación: Quickshell es obligatorio."
        exit 1
    fi
    if ! install_package "$MANAGER" quickshell; then
        error "No fue posible instalar Quickshell automáticamente con el gestor disponible: $MANAGER"
        error "Instale Quickshell >= $MIN_QS_VERSION y vuelva a ejecutar ./install.sh."
        exit 1
    fi
    if command -v qs >/dev/null 2>&1; then QS_CMD="qs"
    elif command -v quickshell >/dev/null 2>&1; then QS_CMD="quickshell"
    else
        error "Fallo de instalación: Quickshell no quedó disponible."
        exit 1
    fi
fi

QS_VERSION="$(command_version "$QS_CMD")"
if [[ -n "$QS_VERSION" ]]; then
    if version_at_least "$QS_VERSION"; then success "Quickshell $QS_VERSION detectado."
    else
        error "Dependencia clave incompatible: Quickshell $QS_VERSION."
        error "Aurora requiere Quickshell >= $MIN_QS_VERSION."
        exit 1
    fi
else
    warning "No se pudo determinar la versión de Quickshell; se continuará con la validación runtime."
fi

if command -v cava >/dev/null 2>&1; then
    success "Cava detectado: espectro disponible."
elif ask_optional "Cava (espectro de audio)"; then
    if install_package "$MANAGER" cava; then success "Cava instalado; espectro habilitado."; else warning "No fue posible instalar Cava automáticamente. Aurora continuará sin espectro."; fi
else
    warning "Cava no será instalado. Aurora continuará sin espectro."
fi

if command -v curl >/dev/null 2>&1; then
    success "curl detectado: carátulas remotas y letras disponibles."
elif ask_optional "curl (carátulas remotas y letras)"; then
    if install_package "$MANAGER" curl; then success "curl instalado."; else warning "No fue posible instalar curl; Aurora conservará las funciones locales y el estado opcional."; fi
else
    warning "curl no será instalado; letras y carátulas remotas pueden no estar disponibles."
fi

if $DRY_RUN; then
    info "Dry-run completado: no se modificaron archivos."
    exit 0
fi

STAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aurora-install.XXXXXX")"
STAGE_DIR="$STAGE_ROOT/Aurora"
BACKUP_DIR=""
cleanup() { rm -rf -- "$STAGE_ROOT"; }
trap cleanup EXIT

mkdir -p "$STAGE_DIR"
cp -a "$SCRIPT_DIR"/. "$STAGE_DIR"/
rm -rf "$STAGE_DIR/.git"
rm -f "$STAGE_DIR/.qmlls.ini"
chmod +x "$STAGE_DIR/install.sh" "$STAGE_DIR/aurora-doctor" "$STAGE_DIR/aurora-theme"

mkdir -p "$(dirname -- "$DEST_DIR")"

if [[ -d "$DEST_DIR" ]]; then
    if $BACKUP_ENABLED; then
        BACKUP_DIR="${DEST_DIR}.backup.$(date '+%Y%m%d-%H%M%S')"
        info "Instalación existente detectada; creando backup: $BACKUP_DIR"
        mv -- "$DEST_DIR" "$BACKUP_DIR"
    else
        warning "Actualización sin backup solicitada."
        rm -rf -- "$DEST_DIR"
    fi
fi

if ! mv -- "$STAGE_DIR" "$DEST_DIR"; then
    error "Fallo de instalación al activar Aurora."
    if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" && ! -e "$DEST_DIR" ]]; then
        mv -- "$BACKUP_DIR" "$DEST_DIR"
        warning "Instalación anterior restaurada."
    fi
    exit 1
fi

mkdir -p "${CONFIG_BASE%/}/aurora/plugins"
mkdir -p "$BIN_DIR"
ln -sfn "$DEST_DIR/aurora-doctor" "$BIN_DIR/aurora-doctor"
ln -sfn "$DEST_DIR/aurora-theme" "$BIN_DIR/aurora-theme"

info "Validando instalación..."
if "$DEST_DIR/aurora-doctor" --installed; then
    success "Validación completada."
else
    error "Fallo de validación después de la instalación."
    error "Aurora no quedó activado; ejecutando rollback..."
    rm -rf -- "$DEST_DIR"
    if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
        mv -- "$BACKUP_DIR" "$DEST_DIR"
        success "Instalación anterior restaurada."
    else
        warning "No existía una instalación anterior; Aurora fue retirado."
    fi
    exit 1
fi

success "Aurora $AURORA_VERSION instalado/actualizado correctamente."
info "Ejecutar: qs -c Aurora"
info "Diagnóstico: aurora-doctor"
info "Temas: aurora-theme list"

if [[ ":${PATH:-}:" != *":$BIN_DIR:"* ]]; then
    warning "$BIN_DIR no está en PATH; el enlace existe y puede añadirse al PATH más adelante."
fi

if [[ -n "$BACKUP_DIR" ]]; then
    info "Backup anterior conservado en: $BACKUP_DIR"
fi
