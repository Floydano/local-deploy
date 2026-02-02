#!/usr/bin/env bash
set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SERVICES_STOPPED=()
SERVICES_FAILED=()
PACKAGES_REMOVED=()
PACKAGES_FAILED=()

echo -e "${RED}=========================================="
echo "   DevOps Toolkit UNINSTALL para macOS"
echo "==========================================${NC}"

echo -e "${RED}⚠️  ADVERTENCIA: Este script eliminará TODAS las herramientas DevOps instaladas${NC}"
echo -e "${RED}   incluyendo configuraciones y datos asociados.${NC}"
echo ""
read -p "¿Estás seguro de continuar? (escribe 'SI' para confirmar): " CONFIRM
if [ "$CONFIRM" != "SI" ]; then
    echo -e "${YELLOW}Operación cancelada.${NC}"
    exit 0
fi

# Función para detener servicios
stop_service() {
    local service="$1"
    local stop_cmd="$2"

    echo -e "${BLUE}[*]${NC} Deteniendo $service..."

    if eval "$stop_cmd" 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} $service detenido exitosamente"
        SERVICES_STOPPED+=("$service")
    else
        echo -e "${YELLOW}[SKIP]${NC} $service no estaba corriendo o no se pudo detener"
    fi
}

# Función para desinstalar herramientas
uninstall() {
    if brew list "$1" &>/dev/null; then
        echo -e "${YELLOW}[-]${NC} Desinstalando $1 ..."
        if brew uninstall "$1" 2>/dev/null; then
            PACKAGES_REMOVED+=("$1")
        else
            PACKAGES_FAILED+=("$1")
        fi
    else
        echo -e "${BLUE}[SKIP]${NC} $1 no está instalado"
    fi
}

# Función para desinstalar casks
uninstall_cask() {
    if brew list --cask "$1" &>/dev/null; then
        echo -e "${YELLOW}[-]${NC} Desinstalando $1 ..."
        if brew uninstall --cask "$1" 2>/dev/null; then
            PACKAGES_REMOVED+=("$1")
        else
            PACKAGES_FAILED+=("$1")
        fi
    else
        echo -e "${BLUE}[SKIP]${NC} $1 no está instalado"
    fi
}

# ========== DETENIENDO SERVICIOS ==========
echo ""
echo -e "${RED}========== DETENIENDO SERVICIOS ==========${NC}"

# Detener Jenkins si está corriendo
if brew services list | grep jenkins-lts | grep started &>/dev/null; then
    stop_service "Jenkins" "brew services stop jenkins-lts"
fi

# Detener colima si está corriendo
if command -v colima &>/dev/null && colima status 2>/dev/null | grep -q "Running"; then
    stop_service "Colima" "colima stop"
fi

# ========== DESINSTALANDO HERRAMIENTAS ==========
echo ""
echo -e "${RED}========== FASE 1: Desinstalando Herramientas de Línea de Comandos ==========${NC}"
uninstall fzf
uninstall tmux
uninstall watch
uninstall tree
uninstall yq
uninstall jq

echo ""
echo -e "${RED}========== FASE 2: Desinstalando Herramientas de Red y Utilidades ==========${NC}"
uninstall wireshark
uninstall nmap
uninstall wget
uninstall curl
uninstall httpie

echo ""
echo -e "${RED}========== FASE 3: Desinstalando Herramientas de Cloud ==========${NC}"
uninstall azure-cli
uninstall_cask google-cloud-sdk
uninstall aws-sam-cli
uninstall awscli

echo ""
echo -e "${RED}========== FASE 4: Desinstalando Herramientas de CI/CD ==========${NC}"
uninstall act
uninstall circleci
uninstall jenkins-lts

echo ""
echo -e "${RED}========== FASE 5: Desinstalando Herramientas de Seguridad ==========${NC}"
uninstall vault-cli
uninstall gitleaks
uninstall snyk-cli
uninstall trivy

echo ""
echo -e "${RED}========== FASE 6: Desinstalando Herramientas de Infraestructura ==========${NC}"
uninstall pulumi
uninstall ansible
uninstall terragrunt
uninstall terraform

echo ""
echo -e "${RED}========== FASE 7: Desinstalando Herramientas de Contenedores y Orquestación ==========${NC}"
uninstall kind
uninstall helm
uninstall k9s
uninstall kubectl
uninstall colima
uninstall_cask docker

echo ""
echo -e "${RED}========== FASE 8: Desinstalando Herramientas de Desarrollo ==========${NC}"
uninstall openjdk
uninstall go
uninstall node
uninstall python

echo ""
echo -e "${RED}========== FASE 9: Desinstalando Herramientas de Git ==========${NC}"
uninstall git-lfs
uninstall gh
uninstall git

# ========== LIMPIANDO CONFIGURACIONES ==========
echo ""
echo -e "${RED}========== LIMPIANDO CONFIGURACIONES ==========${NC}"

# Limpiar configuración de Git
echo -e "${YELLOW}[*]${NC} Limpiando configuración de Git..."
if git config --global --list &>/dev/null; then
    git config --global --unset user.name 2>/dev/null || true
    git config --global --unset user.email 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Configuración de Git limpiada"
else
    echo -e "${BLUE}[SKIP]${NC} No hay configuración de Git"
fi

# Limpiar configuración de AWS
echo -e "${YELLOW}[*]${NC} Limpiando configuración de AWS..."
if [ -d ~/.aws ]; then
    rm -rf ~/.aws
    echo -e "${GREEN}[OK]${NC} Configuración de AWS eliminada"
else
    echo -e "${BLUE}[SKIP]${NC} No hay configuración de AWS"
fi

# Limpiar configuración de Google Cloud
echo -e "${YELLOW}[*]${NC} Limpiando configuración de Google Cloud..."
if [ -d ~/Library/Application\ Support/google-cloud-tools ]; then
    rm -rf ~/Library/Application\ Support/google-cloud-tools
    echo -e "${GREEN}[OK]${NC} Configuración de Google Cloud eliminada"
else
    echo -e "${BLUE}[SKIP]${NC} No hay configuración de Google Cloud"
fi

# Limpiar configuración de Azure
echo -e "${YELLOW}[*]${NC} Limpiando configuración de Azure..."
if [ -d ~/.azure ]; then
    rm -rf ~/.azure
    echo -e "${GREEN}[OK]${NC} Configuración de Azure eliminada"
else
    echo -e "${BLUE}[SKIP]${NC} No hay configuración de Azure"
fi

# Limpiar clusters de Kind
echo -e "${YELLOW}[*]${NC} Limpiando clusters de Kind..."
if command -v kind &>/dev/null; then
    kind get clusters 2>/dev/null | while read cluster; do
        if [ -n "$cluster" ]; then
            echo -e "${YELLOW}  Eliminando cluster: $cluster${NC}"
            kind delete cluster --name "$cluster" 2>/dev/null || true
        fi
    done
    echo -e "${GREEN}[OK]${NC} Clusters de Kind eliminados"
else
    echo -e "${BLUE}[SKIP]${NC} Kind no está disponible"
fi

# Limpiar imágenes y contenedores de Docker (si Docker está disponible)
echo -e "${YELLOW}[*]${NC} Limpiando Docker..."
if command -v docker &>/dev/null && docker ps &>/dev/null; then
    echo -e "${YELLOW}  Deteniendo contenedores...${NC}"
    docker stop $(docker ps -aq) 2>/dev/null || true
    echo -e "${YELLOW}  Eliminando contenedores...${NC}"
    docker rm $(docker ps -aq) 2>/dev/null || true
    echo -e "${YELLOW}  Eliminando imágenes...${NC}"
    docker rmi $(docker images -q) 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Docker limpiado"
else
    echo -e "${BLUE}[SKIP]${NC} Docker no está disponible o no corriendo"
fi

# ========== LIMPIANDO CACHE Y TEMPORALES ==========
echo ""
echo -e "${RED}========== LIMPIANDO CACHE Y TEMPORALES ==========${NC}"

# Limpiar cache de Homebrew
echo -e "${YELLOW}[*]${NC} Limpiando cache de Homebrew..."
brew cleanup --prune=all 2>/dev/null || true
echo -e "${GREEN}[OK]${NC} Cache de Homebrew limpiado"

# Limpiar cache de pip
echo -e "${YELLOW}[*]${NC} Limpiando cache de pip..."
if command -v pip3 &>/dev/null; then
    pip3 cache purge 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Cache de pip limpiado"
else
    echo -e "${BLUE}[SKIP]${NC} pip3 no está disponible"
fi

# Limpiar cache de npm
echo -e "${YELLOW}[*]${NC} Limpiando cache de npm..."
if command -v npm &>/dev/null; then
    npm cache clean --force 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Cache de npm limpiado"
else
    echo -e "${BLUE}[SKIP]${NC} npm no está disponible"
fi

# ========== RESUMEN FINAL ==========
echo ""
echo -e "${RED}=========================================="
echo "   DESINSTALACIÓN COMPLETADA"
echo "==========================================${NC}"

if [ ${#SERVICES_STOPPED[@]} -gt 0 ]; then
    echo -e "${GREEN}[✓] Servicios detenidos:${NC}"
    for service in "${SERVICES_STOPPED[@]}"; do
        echo "  - $service"
    done
fi

if [ ${#PACKAGES_REMOVED[@]} -gt 0 ]; then
    echo -e "${GREEN}[✓] Paquetes desinstalados:${NC} ${#PACKAGES_REMOVED[@]}"
fi

if [ ${#PACKAGES_FAILED[@]} -gt 0 ]; then
    echo -e "${YELLOW}[!] Paquetes que no se pudieron desinstalar:${NC}"
    for pkg in "${PACKAGES_FAILED[@]}"; do
        echo "  - $pkg"
    done
fi

echo ""
echo -e "${GREEN}¡Limpieza completada! El sistema ha sido restaurado.${NC}"
echo ""
echo -e "${BLUE}Nota: Algunos archivos de configuración pueden permanecer en el sistema.${NC}"
echo -e "${BLUE}Para una limpieza completa, considera revisar manualmente:${NC}"
echo "  - ~/.ssh/ (claves SSH)"
echo "  - ~/.kube/ (configuración de Kubernetes)"
echo "  - ~/Library/Application Support/ (aplicaciones)"
echo "  - /usr/local/ (instalaciones manuales)"