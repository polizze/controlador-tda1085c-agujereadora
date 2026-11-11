#!/usr/bin/env bash
# =============================================================================
# init_repo.sh - Inicialización y Estructuración del Repositorio GitHub
# Proyecto: Controlador de Velocidad TDA1085C para Agujereadora de Banco
# =============================================================================
set -euo pipefail

echo "[1/5] Creando estructura de directorios para Hardware Libre..."
mkdir -p Hardware/TDA1085C_Controller
mkdir -p Hardware/TDA1085C_Controller/TDA1085C_Custom.pretty
mkdir -p Hardware/Fabrication
mkdir -p Simulations
mkdir -p Docs

echo "[2/5] Reubicando archivos existentes en sus carpetas correspondientes..."
# Mover simulaciones LTspice si se encuentran en la raíz
find . -maxdepth 1 -type f \( -name "*.asc" -o -name "*.net" -o -name "*.log" -o -name "*.plt" \) -exec mv -f {} Simulations/ \; 2>/dev/null || true

# Mover hojas de datos y relevamiento fotográfico si se encuentran en la raíz
find . -maxdepth 1 -type f \( -iname "*.pdf" -o -iname "*.jpg" -o -iname "*.png" \) -exec mv -f {} Docs/ \; 2>/dev/null || true

echo "[3/5] Verificando archivo .gitignore estándar (KiCad + LTspice)..."
cat << 'EOF' > .gitignore
# =============================================================================
# .gitignore - Controlador TDA1085C (KiCad + LTspice + OS)
# =============================================================================

# --- LTspice (Simulations) ---
*.raw
*.op.raw
*.fft
*.tmp
*.db

# --- KiCad (Hardware) ---
*.lck
~*
_autosave-*
*.bak
*.bck
*.kicad_pcb-bak
*.kicad_sch-bak
*.kicad_prl
fp-info-cache
sym-lib-table.lock
fp-lib-table.lock
*-backups/
*.dsn
*.ses

# --- Sistema Operativo / IDE ---
.DS_Store
Thumbs.db
Desktop.ini
*.swp
.vscode/
.idea/
__pycache__/
*.pyc
EOF

echo "[4/5] Inicializando repositorio Git local..."
if command -v git >/dev/null 2>&1; then
    if [ ! -d ".git" ]; then
        git init -b main
    fi
    git add .
    echo "[5/5] Estado del repositorio listo para el primer commit:"
    git status -s
    echo ""
    echo "Ejecutá:"
    echo "  git commit -m 'feat: estructura inicial TDA1085C (KiCad + LTspice + Docs)'"
    echo "  git remote add origin https://github.com/<usuario>/<repo>.git"
    echo "  git push -u origin main"
else
    echo "[!] Advertencia: 'git' no está en el PATH actual. Estructura de carpetas creada exitosamente."
fi
