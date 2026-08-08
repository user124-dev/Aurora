#!/usr/bin/env bash
#
# Aurora installer
#
# Installs Aurora into a Quickshell module directory while keeping the
# source repository untouched and preserving a dated backup.
#
# Usage:
#   ./install.sh
#   ./install.sh /path/to/quickshell/modules/mediaControls
#   ./install.sh --target /path/to/quickshell/modules/mediaControls
#   ./install.sh --dry-run
#   ./install.sh --no-backup
#

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly DEFAULT_TARGET="${HOME}/.config/quickshell/ii/modules/ii/mediaControls"

TARGET_DIR="$DEFAULT_TARGET"
BACKUP_ENABLED=true
DRY_RUN=false

info() {
    printf '\033[1;36m[Aurora]\033[0m %s\n' "$*"
}

success() {
    printf '\033[1;32m[Aurora]\033[0m %s\n' "$*"
}

warning() {
    printf '\033[1;33m[Aurora]\033[0m %s\n' "$*"
}

error() {
    printf '\033[1;31m[Aurora]\033[0m %s\n' "$*" >&2
}

usage() {
    cat <<'EOF'
Aurora installer

Usage:
  ./install.sh [TARGET]
  ./install.sh --target TARGET
  ./install.sh [options]

Options:
  --target PATH     Install into PATH.
  --no-backup       Replace an existing Aurora installation without backup.
  --dry-run         Validate and show the planned operation without changing files.
  -h, --help        Show this help.

Default target:
  ~/.config/quickshell/ii/modules/ii/mediaControls

The installed Aurora directory is:
  <TARGET>/Aurora
EOF
}

while (($# > 0)); do
    case "$1" in
        --target)
            [[ $# -ge 2 ]] || {
                error "--target requires a path."
                exit 2
            }
            TARGET_DIR="$2"
            shift 2
            ;;
        --no-backup)
            BACKUP_ENABLED=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            error "Unknown option: $1"
            usage >&2
            exit 2
            ;;
        *)
            if [[ "$TARGET_DIR" != "$DEFAULT_TARGET" ]]; then
                error "The target was specified more than once."
                exit 2
            fi
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

if (($# > 0)); then
    error "Unexpected argument: $1"
    exit 2
fi

DEST_DIR="${TARGET_DIR%/}/Aurora"

require_file() {
    local relative="$1"

    if [[ ! -f "$SCRIPT_DIR/$relative" ]]; then
        error "Missing required file: $relative"
        exit 1
    fi
}

info "Validating Aurora source..."
require_file "Core/AuroraState.qml"
require_file "Core/AuroraConfig.qml"
require_file "Core/AuroraPluginRegistry.qml"
require_file "Components/Layout/AuroraPlayer.qml"
require_file "aurora-doctor"

if command -v realpath >/dev/null 2>&1; then
    source_real="$(realpath -m "$SCRIPT_DIR")"
    dest_real="$(realpath -m "$DEST_DIR")"

    if [[ "$dest_real" == "$source_real" ]]; then
        if $DRY_RUN; then
            warning "Dry-run target is the source repository itself; no files will be changed."
        else
            error "The installation destination is the source repository itself."
            exit 1
        fi
    elif [[ "$dest_real" == "$source_real/"* ]]; then
        error "The installation destination is inside the Aurora source tree."
        exit 1
    fi
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    info "Target directory does not exist yet:"
    info "  $TARGET_DIR"
fi

info "Source:"
info "  $SCRIPT_DIR"
info "Destination:"
info "  $DEST_DIR"

if [[ -d "$DEST_DIR" ]]; then
    if $BACKUP_ENABLED; then
        BACKUP_DIR="${TARGET_DIR%/}/Aurora.backup.$(date '+%Y%m%d-%H%M%S')"
        info "Existing installation will be backed up to:"
        info "  $BACKUP_DIR"
    else
        warning "Existing installation will be replaced without a backup."
    fi
fi

CONFIG_BASE="${XDG_CONFIG_HOME:-${HOME}/.config}"
PLUGIN_BASE="${CONFIG_BASE%/}/aurora/plugins"
info "Automatic plugin directory:"
info "  $PLUGIN_BASE"

if $DRY_RUN; then
    info "Planned actions:"
    info "  - validate the Aurora source"
    if [[ -d "$DEST_DIR" ]]; then
        if $BACKUP_ENABLED; then
            info "  - move the existing installation to:"
            info "      $BACKUP_DIR"
        else
            info "  - remove the existing installation (--no-backup)"
        fi
    fi
    info "  - copy Aurora to:"
    info "      $DEST_DIR"
    info "  - remove the copied .git directory"
    info "  - make install.sh and aurora-doctor executable"
    info "  - create the external plugin directory:"
    info "      $PLUGIN_BASE"
    success "Dry run complete. No files were changed."
    exit 0
fi

STAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aurora-install.XXXXXX")"
STAGE_DIR="$STAGE_ROOT/Aurora"

cleanup() {
    rm -rf -- "$STAGE_ROOT"
}
trap cleanup EXIT

mkdir -p "$STAGE_DIR"
cp -a "$SCRIPT_DIR"/. "$STAGE_DIR"/
rm -rf "$STAGE_DIR/.git"

# The script is a distributed entrypoint, so keep it executable even
# when Aurora came from a filesystem/archive that lost mode bits.
chmod +x "$STAGE_DIR/install.sh" "$STAGE_DIR/aurora-doctor"

# Re-check the staged copy before touching the existing installation.
[[ -f "$STAGE_DIR/Core/AuroraState.qml" ]]
[[ -f "$STAGE_DIR/Core/AuroraConfig.qml" ]]
[[ -f "$STAGE_DIR/Core/AuroraPluginRegistry.qml" ]]
[[ -f "$STAGE_DIR/Components/Layout/AuroraPlayer.qml" ]]

mkdir -p "$TARGET_DIR"

BACKUP_DIR=""
if [[ -d "$DEST_DIR" ]]; then
    if $BACKUP_ENABLED; then
        BACKUP_DIR="${TARGET_DIR%/}/Aurora.backup.$(date '+%Y%m%d-%H%M%S')"
        mv -- "$DEST_DIR" "$BACKUP_DIR"
    else
        rm -rf -- "$DEST_DIR"
    fi
fi

if ! mv -- "$STAGE_DIR" "$DEST_DIR"; then
    error "Failed to activate the new installation."

    if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" && ! -e "$DEST_DIR" ]]; then
        warning "Restoring the previous installation..."
        mv -- "$BACKUP_DIR" "$DEST_DIR"
    fi

    exit 1
fi

# The directory is intentionally created outside Aurora. It is the
# stable location scanned by AuroraPluginRegistry.
mkdir -p "$PLUGIN_BASE"

success "Aurora installed successfully."
info "Installed at:"
info "  $DEST_DIR"
info "Run diagnostics with:"
info "  $DEST_DIR/aurora-doctor"

if [[ -n "$BACKUP_DIR" ]]; then
    info "Previous installation:"
    info "  $BACKUP_DIR"
fi
