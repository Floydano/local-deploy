#!/usr/bin/env bash
set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SERVICES_STARTED=()
SERVICES_FAILED=()

echo -e "${BLUE}=========================================="
echo "   DevOps Toolkit Setup para macOS"
echo "==========================================${NC}"

ARCH=$(uname -m)
echo -e "${BLUE}[INFO]${NC} Arquitectura detectada: $ARCH"

# Función para instalar herramientas
install() {
    if brew list "$1" &>/dev/null; then
        echo -e "${GREEN}[OK]${NC} $1 ya está instalado"
    else
        echo -e "${YELLOW}[+]${NC} Instalando $1 ..."
        brew install "$1"
    fi
}

# Función para instalar casks
install_cask() {
    if brew list --cask "$1" &>/dev/null; then
        echo -e "${GREEN}[OK]${NC} $1 ya está instalado"
    else
        echo -e "${YELLOW}[+]${NC} Instalando $1 ..."
        brew install --cask "$1"
    fi
}

# Función para iniciar servicios
start_service() {
    local service="$1"
    local start_cmd="$2"
    
    echo -e "${BLUE}[*]${NC} Iniciando $service..."
    
    if eval "$start_cmd" 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} $service iniciado exitosamente"
        SERVICES_STARTED+=("$service")
        sleep 2
    else
        echo -e "${RED}[ERROR]${NC} Falló al iniciar $service"
        SERVICES_FAILED+=("$service")
    fi
}

# Función para verificar si un servicio está corriendo
check_service() {
    local service="$1"
    local check_cmd="$2"
    
    if eval "$check_cmd" &>/dev/null; then
        echo -e "${GREEN}[✓]${NC} $service está corriendo"
        return 0
    else
        echo -e "${YELLOW}[✗]${NC} $service no está corriendo"
        return 1
    fi
}

# Función para verificar si un paquete está instalado
is_installed() {
    if brew list "$1" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para verificar si un cask está instalado
is_cask_installed() {
    if brew list --cask "$1" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ========== INSTALACIÓN DE HERRAMIENTAS ==========
echo ""
echo -e "${BLUE}========== FASE 1: Instalando Homebrew ==========${NC}"

if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}[+]${NC} Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}[OK]${NC} Homebrew ya está instalado"
fi

brew update

echo ""
echo -e "${BLUE}========== FASE 2: Herramientas de Git y Desarrollo ==========${NC}"
PHASE2_INSTALLED=0
for pkg in git gh git-lfs python node go openjdk; do
    is_installed "$pkg" && ((PHASE2_INSTALLED++))
done
[ $PHASE2_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE2_INSTALLED paquetes ya instalados${NC}"
[ $PHASE2_INSTALLED -lt 8 ] && echo -e "${YELLOW}  ⟳ $((8 - PHASE2_INSTALLED)) paquetes para instalar${NC}"

install git
install gh
install git-lfs

install python
install node
install go
install openjdk

echo ""
echo -e "${BLUE}========== FASE 3: Herramientas de Contenedores y Orquestación ==========${NC}"
PHASE3_INSTALLED=0
for pkg in docker kubectl k9s helm colima kind; do
    if is_cask_installed "$pkg" 2>/dev/null || is_installed "$pkg" 2>/dev/null; then
        ((PHASE3_INSTALLED++))
    fi
done
[ $PHASE3_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE3_INSTALLED paquetes ya instalados${NC}"
[ $PHASE3_INSTALLED -lt 6 ] && echo -e "${YELLOW}  ⟳ $((6 - PHASE3_INSTALLED)) paquetes para instalar${NC}"

install_cask docker
install colima
install kubectl
install k9s
install helm
install kind

echo ""
echo -e "${BLUE}========== FASE 4: Herramientas de Infraestructura ==========${NC}"
PHASE4_INSTALLED=0
for pkg in terraform terragrunt ansible pulumi; do
    is_installed "$pkg" && ((PHASE4_INSTALLED++))
done
[ $PHASE4_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE4_INSTALLED paquetes ya instalados${NC}"
[ $PHASE4_INSTALLED -lt 4 ] && echo -e "${YELLOW}  ⟳ $((4 - PHASE4_INSTALLED)) paquetes para instalar${NC}"

install terraform
install terragrunt
install ansible
install pulumi

echo ""
echo -e "${BLUE}========== FASE 5: Herramientas de Seguridad ==========${NC}"
PHASE5_INSTALLED=0
for pkg in trivy snyk-cli gitleaks vault-cli; do
    is_installed "$pkg" && ((PHASE5_INSTALLED++))
done
[ $PHASE5_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE5_INSTALLED paquetes ya instalados${NC}"
[ $PHASE5_INSTALLED -lt 4 ] && echo -e "${YELLOW}  ⟳ $((4 - PHASE5_INSTALLED)) paquetes para instalar${NC}"

install trivy
install snyk-cli
install gitleaks
install vault-cli

echo ""
echo -e "${BLUE}========== FASE 6: Herramientas de CI/CD ==========${NC}"
PHASE6_INSTALLED=0
for pkg in jenkins-lts circleci act; do
    is_installed "$pkg" && ((PHASE6_INSTALLED++))
done
[ $PHASE6_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE6_INSTALLED paquetes ya instalados${NC}"
[ $PHASE6_INSTALLED -lt 3 ] && echo -e "${YELLOW}  ⟳ $((3 - PHASE6_INSTALLED)) paquetes para instalar${NC}"

install jenkins-lts
install circleci
install act

echo ""
echo -e "${BLUE}========== FASE 7: Herramientas de Cloud ==========${NC}"
PHASE7_INSTALLED=0
for pkg in awscli aws-sam-cli azure-cli; do
    is_installed "$pkg" && ((PHASE7_INSTALLED++))
done
is_cask_installed "google-cloud-sdk" && ((PHASE7_INSTALLED++))
[ $PHASE7_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE7_INSTALLED paquetes ya instalados${NC}"
[ $PHASE7_INSTALLED -lt 4 ] && echo -e "${YELLOW}  ⟳ $((4 - PHASE7_INSTALLED)) paquetes para instalar${NC}"

install awscli
install aws-sam-cli
install_cask google-cloud-sdk
install azure-cli

echo ""
echo -e "${BLUE}========== FASE 8: Herramientas de Red y Utilidades ==========${NC}"
PHASE8_INSTALLED=0
for pkg in httpie curl wget nmap wireshark; do
    is_installed "$pkg" && ((PHASE8_INSTALLED++))
done
[ $PHASE8_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE8_INSTALLED paquetes ya instalados${NC}"
[ $PHASE8_INSTALLED -lt 5 ] && echo -e "${YELLOW}  ⟳ $((5 - PHASE8_INSTALLED)) paquetes para instalar${NC}"

install httpie
install curl
install wget
install nmap
install wireshark

echo ""
echo -e "${BLUE}========== FASE 9: Herramientas de Línea de Comandos ==========${NC}"
PHASE9_INSTALLED=0
for pkg in jq yq tree watch tmux fzf; do
    is_installed "$pkg" && ((PHASE9_INSTALLED++))
done
[ $PHASE9_INSTALLED -gt 0 ] && echo -e "${GREEN}  ✓ $PHASE9_INSTALLED paquetes ya instalados${NC}"
[ $PHASE9_INSTALLED -lt 6 ] && echo -e "${YELLOW}  ⟳ $((6 - PHASE9_INSTALLED)) paquetes para instalar${NC}"

install jq
install yq
install tree
install watch
install tmux
install fzf

# ========== INICIO DE SERVICIOS ==========
echo ""
echo -e "${BLUE}=========================================="
echo "   FASE 10: Iniciando Servicios"
echo "==========================================${NC}"
echo ""

# Iniciar Docker
if command -v docker &>/dev/null; then
    if ! docker ps &>/dev/null; then
        echo -e "${YELLOW}[*]${NC} Docker no está corriendo. Iniciando colima..."
        if command -v colima &>/dev/null; then
            start_service "Colima" "colima start"
        fi
    else
        echo -e "${GREEN}[✓]${NC} Docker ya está corriendo"
        SERVICES_STARTED+=("Docker")
    fi
fi

# Iniciar kubectl si está disponible
if command -v kubectl &>/dev/null; then
    check_service "kubectl" "kubectl cluster-info &>/dev/null" || echo -e "${YELLOW}[i]${NC} kubectl disponible pero sin cluster conectado"
fi

# Verificar Jenkins
if command -v jenkins-lts &>/dev/null; then
    echo -e "${YELLOW}[i]${NC} Jenkins instalado. Para iniciarlo ejecuta: brew services start jenkins-lts"
fi

# Configurar Git
echo ""
echo -e "${BLUE}========== Configurando Git ==========${NC}"
if ! git config --global user.name &>/dev/null; then
    read -p "Ingresa tu nombre para Git: " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi

if ! git config --global user.email &>/dev/null; then
    read -p "Ingresa tu email para Git: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi

echo -e "${GREEN}[OK]${NC} Git configurado"

# Configurar CLI de AWS si está disponible
if command -v aws &>/dev/null; then
    if [ ! -f ~/.aws/config ]; then
        echo -e "${YELLOW}[i]${NC} AWS CLI no configurado. Para configurarlo: aws configure"
    else
        echo -e "${GREEN}[OK]${NC} AWS CLI ya está configurado"
    fi
fi

# Resumen final
echo ""
echo -e "${BLUE}=========================================="
echo "   Instalación y configuración completada"
echo "==========================================${NC}"

if [ ${#SERVICES_STARTED[@]} -gt 0 ]; then
    echo -e "${GREEN}[✓] Servicios iniciados:${NC}"
    for service in "${SERVICES_STARTED[@]}"; do
        echo "  - $service"
    done
fi

if [ ${#SERVICES_FAILED[@]} -gt 0 ]; then
    echo -e "${RED}[!] Servicios con fallos:${NC}"
    for service in "${SERVICES_FAILED[@]}"; do
        echo "  - $service"
    done
fi

echo ""
echo -e "${BLUE}========== Próximos pasos ==========${NC}"
echo "1. Configura tus credenciales de cloud:"
echo "   - AWS: aws configure"
echo "   - GCP: gcloud auth login"
echo "   - Azure: az login"
echo ""
echo "2. Inicia Jenkins si lo necesitas:"
echo "   brew services start jenkins-lts"
echo ""
echo "3. Conecta un cluster de Kubernetes:"
echo "   - Crea uno local con: kind create cluster"
echo "   - O configura una conexión remota"
echo ""
echo -e "${GREEN}¡DevOps Toolkit listo para usar!${NC}"

