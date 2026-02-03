#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Funciones utilitarias
# -----------------------------

install() {
    local pkg="$1"
    echo "Instalando $pkg..."
    if brew list "$pkg" &>/dev/null; then
        echo "$pkg ya está instalado"
    else
        brew install "$pkg"
        echo "$pkg instalado correctamente"
    fi
    echo ""
}

install_cask() {
    local pkg="$1"
    echo "Instalando $pkg..."
    if brew list --cask "$pkg" &>/dev/null; then
        echo "$pkg ya está instalado"
    else
        brew install --cask "$pkg"
        echo "$pkg instalado correctamente"
    fi
    echo ""
}

append_once() {
    local file="$1"
    local line="$2"

    mkdir -p "$(dirname "$file")"

    if [ ! -f "$file" ]; then
        echo "$line" >> "$file"
        return
    fi

    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

# -----------------------------
# Homebrew
# -----------------------------

if ! command -v brew &>/dev/null; then
    echo "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew ya está instalado"
fi

brew update

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
    docker
    colima
    kind
    kubectl
)

CASK_PACKAGES=(
    google-cloud-sdk
)

# -----------------------------
# Instalación de herramientas
# -----------------------------

for pkg in "${BREW_PACKAGES[@]}"; do
    install "$pkg"
done

for cask in "${CASK_PACKAGES[@]}"; do
    install_cask "$cask"
done

# -----------------------------
# Configuración mínima de Git
# -----------------------------

echo "Configurando Git..."

if ! git config --global user.name &>/dev/null; then
    read -p "Ingresa tu nombre para Git: " GIT_NAME
    git config --global user.name "$GIT_NAME"
else
    echo "Git ya tiene nombre configurado"
fi

if ! git config --global user.email &>/dev/null; then
    read -p "Ingresa tu email para Git: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
else
    echo "Git ya tiene email configurado"
fi

echo ""

# -----------------------------
# Autocompletado
# -----------------------------

echo "Habilitando autocompletado..."

# gcloud
if command -v gcloud &>/dev/null; then
    append_once "$HOME/.bashrc" "source \"$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc\""
    append_once "$HOME/.bashrc" "source \"$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc\""

    append_once "$HOME/.bash_profile" "source \"$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc\""
    append_once "$HOME/.bash_profile" "source \"$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc\""

    echo "Autocompletado de gcloud habilitado"
fi

# terraform
if command -v terraform &>/dev/null; then
    terraform -install-autocomplete &>/dev/null || true
    echo "Autocompletado de terraform habilitado"
fi

# fzf
if command -v fzf &>/dev/null; then
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
    echo "Autocompletado de fzf habilitado"
fi

echo ""

# -----------------------------
# Docker + Colima
# -----------------------------

echo "Verificando estado de Colima..."

if command -v colima &>/dev/null; then
    if ! colima status &>/dev/null; then
        echo "Iniciando Colima..."
        colima start
        echo "Colima iniciado"
    else
        echo "Colima ya está corriendo"
    fi
else
    echo "Colima no está instalado"
fi

echo ""

echo "Verificando Docker..."

if command -v docker &>/dev/null; then
    if docker ps &>/dev/null; then
        echo "Docker está funcionando correctamente"
    else
        echo "Docker instalado pero no operativo; Colima debería manejarlo"
    fi
else
    echo "Docker no está instalado"
fi

echo ""

# -----------------------------
# kind (cluster Kubernetes local)
# -----------------------------

echo "Verificando cluster kind..."

if command -v kind &>/dev/null; then

    # ¿Existe un cluster llamado "kind"?
    if kind get clusters | grep -q "^kind$"; then
        echo "El cluster kind ya existe"

        # Verificar estado del contenedor
        if docker ps -a --format '{{.Names}} {{.Status}}' | grep -q "kind-control-plane Exited"; then
            echo "El cluster existe pero su contenedor está detenido; recreando cluster..."
            kind delete cluster
            kind create cluster
            echo "Cluster kind recreado"
        else
            # Contenedor existe y está corriendo o iniciable
            if kubectl cluster-info &>/dev/null; then
                echo "kubectl ya está conectado al cluster"
            else
                echo "kubectl no está conectado; configurando contexto..."
                kind export kubeconfig
                echo "Contexto configurado"
            fi
        fi

    else
        echo "Creando cluster local con kind..."
        kind create cluster
        echo "Cluster kind creado"
    fi

else
    echo "kind no está instalado"
fi

echo ""


# -----------------------------
# Final
# -----------------------------

echo "Instalación y configuración completadas."
echo "Abre una nueva terminal para aplicar los cambios."
