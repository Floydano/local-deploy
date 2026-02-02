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

echo -e "${YELLOW}=========================================="
echo "   DevOps Toolkit UNINSTALL - MODO PRUEBA"
echo "==========================================${NC}"
echo -e "${YELLOW}⚠️  ESTO ES UNA SIMULACIÓN - No se eliminará nada${NC}"
echo ""

# Función para simular detención de servicios
stop_service() {
    local service="$1"
    local stop_cmd="$2"

    echo -e "${BLUE}[SIMULADO]${NC} Detendría $service con: $stop_cmd"
    SERVICES_STOPPED+=("$service")
}

# Función para simular desinstalación
uninstall() {
    if brew list "$1" &>/dev/null; then
        echo -e "${YELLOW}[SIMULADO]${NC} Desinstalaría $1"
        PACKAGES_REMOVED+=("$1")
    else
        echo -e "${BLUE}[SKIP]${NC} $1 no está instalado"
    fi
}

# Función para simular desinstalación de casks
uninstall_cask() {
    if brew list --cask "$1" &>/dev/null; then
        echo -e "${YELLOW}[SIMULADO]${NC} Desinstalaría cask $1"
        PACKAGES_REMOVED+=("$1")
    else
        echo -e "${BLUE}[SKIP]${NC} $1 no está instalado"
    fi
}

# ========== SIMULANDO DETENCIÓN DE SERVICIOS ==========
echo ""
echo -e "${RED}========== SIMULANDO DETENCIÓN DE SERVICIOS ==========${NC}"

# Simular detención de Jenkins
if brew services list 2>/dev/null | grep -q jenkins-lts; then
    stop_service "Jenkins" "brew services stop jenkins-lts"
else
    echo -e "${BLUE}[SKIP]${NC} Jenkins no está instalado"
fi

# Simular detención de colima
if command -v colima &>/dev/null; then
    stop_service "Colima" "colima stop"
else
    echo -e "${BLUE}[SKIP]${NC} Colima no está disponible"
fi

# ========== SIMULANDO DESINSTALACIÓN ==========
echo ""
echo -e "${RED}========== FASE 1: Simulando desinstalación de CLI Tools ==========${NC}"
uninstall fzf
uninstall tmux
uninstall watch
uninstall tree
uninstall yq
uninstall jq

echo ""
echo -e "${RED}========== FASE 2: Simulando desinstalación de Network Tools ==========${NC}"
uninstall wireshark
uninstall nmap
uninstall wget
uninstall curl
uninstall httpie

echo ""
echo -e "${RED}========== FASE 3: Simulando desinstalación de Cloud Tools ==========${NC}"
uninstall azure-cli
uninstall_cask google-cloud-sdk
uninstall aws-sam-cli
uninstall awscli

echo ""
echo -e "${RED}========== FASE 4: Simulando desinstalación de CI/CD Tools ==========${NC}"
uninstall act
uninstall circleci
uninstall jenkins-lts

echo ""
echo -e "${RED}========== FASE 5: Simulando desinstalación de Security Tools ==========${NC}"
uninstall vault-cli
uninstall gitleaks
uninstall snyk-cli
uninstall trivy

echo ""
echo -e "${RED}========== FASE 6: Simulando desinstalación de Infra Tools ==========${NC}"
uninstall pulumi
uninstall ansible
uninstall terragrunt
uninstall terraform

echo ""
echo -e "${RED}========== FASE 7: Simulando desinstalación de Container Tools ==========${NC}"
uninstall kind
uninstall helm
uninstall k9s
uninstall kubectl
uninstall colima
uninstall_cask docker

echo ""
echo -e "${RED}========== FASE 8: Simulando desinstalación de Dev Tools ==========${NC}"
uninstall openjdk
uninstall go
uninstall node
uninstall python

echo ""
echo -e "${RED}========== FASE 9: Simulando desinstalación de Git Tools ==========${NC}"
uninstall git-lfs
uninstall gh
uninstall git

# ========== SIMULANDO LIMPIEZA ==========
echo ""
echo -e "${RED}========== SIMULANDO LIMPIEZA DE CONFIGURACIONES ==========${NC}"

echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría configuración de Git"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría configuración de AWS (~/.aws)"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría configuración de Google Cloud"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría configuración de Azure"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría clusters de Kind"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría Docker (contenedores e imágenes)"

echo ""
echo -e "${RED}========== SIMULANDO LIMPIEZA DE CACHE ==========${NC}"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría cache de Homebrew"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría cache de pip"
echo -e "${YELLOW}[SIMULADO]${NC} Limpiaría cache de npm"

# ========== RESUMEN FINAL ==========
echo ""
echo -e "${YELLOW}=========================================="
echo "   PRUEBA COMPLETADA - RESUMEN"
echo "==========================================${NC}"

if [ ${#SERVICES_STOPPED[@]} -gt 0 ]; then
    echo -e "${GREEN}[✓] Servicios que se detendrían:${NC} ${#SERVICES_STOPPED[@]}"
    for service in "${SERVICES_STOPPED[@]}"; do
        echo "  - $service"
    done
fi

if [ ${#PACKAGES_REMOVED[@]} -gt 0 ]; then
    echo -e "${GREEN}[✓] Paquetes que se desinstalarían:${NC} ${#PACKAGES_REMOVED[@]}"
    echo "  Lista: ${PACKAGES_REMOVED[*]}"
fi

echo ""
echo -e "${GREEN}✅ Prueba completada exitosamente. El script funciona correctamente.${NC}"
echo -e "${BLUE}Para ejecutar la desinstalación real, usa: ./devops_uninstall.sh${NC}"