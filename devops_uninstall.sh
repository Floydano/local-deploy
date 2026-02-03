#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Funciones utilitarias
# -----------------------------

uninstall() {
    local pkg="$1"
    echo "Desinstalando $pkg..."
    if brew list "$pkg" &>/dev/null; then
        brew uninstall "$pkg"
        echo "$pkg desinstalado"
    else
        echo "$pkg no está instalado"
    fi
    echo ""
}

uninstall_cask() {
    local pkg="$1"
    echo "Desinstalando $pkg..."
    if brew list --cask "$pkg" &>/dev/null; then
        brew uninstall --cask "$pkg"
        echo "$pkg desinstalado"
    else
        echo "$pkg no está instalado"
    fi
    echo ""
}

remove_line() {
    local file="$1"
    local pattern="$2"

    if [ -f "$file" ]; then
        sed -i '' "/${pattern//\//\\/}/d" "$file"
    fi
}

# -----------------------------
# Listas de herramientas
# -----------------------------

BREW_PACKAGES=(
    git
    gh
    git-lfs
    terraform
    jq
    yq
    tree
    fzf
    watch
    tmux
    kubectl
)

CASK_PACKAGES=(
    google-cloud-sdk
)

# -----------------------------
# Desinstalar herramientas
# -----------------------------

for pkg in "${BREW_PACKAGES[@]}"; do
    uninstall "$pkg"
done

for cask in "${CASK_PACKAGES[@]}"; do
    uninstall_cask "$cask"
done

# -----------------------------
# Limpiar autocompletado
# -----------------------------

echo "Eliminando configuraciones de autocompletado..."

remove_line "$HOME/.bashrc" "google-cloud-sdk/path.bash.inc"
remove_line "$HOME/.bashrc" "google-cloud-sdk/completion.bash.inc"
remove_line "$HOME/.bash_profile" "google-cloud-sdk/path.bash.inc"
remove_line "$HOME/.bash_profile" "google-cloud-sdk/completion.bash.inc"

# fzf cleanup (no borra binarios, solo hooks)
remove_line "$HOME/.bashrc" "fzf"
remove_line "$HOME/.bash_profile" "fzf"

echo "Autocompletado limpiado"
echo ""

# -----------------------------
# Final
# -----------------------------

echo "Desinstalación completada."
echo "Abre una nueva terminal para aplicar los cambios."
