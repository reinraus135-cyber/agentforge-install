#!/usr/bin/env bash
# AgentForge Installer -- Stage 2 (Ubuntu/WSL2)
# Called by install-windows.ps1 or run standalone:
#   curl -fsSL https://agentforge.army/install-ubuntu.sh | bash
#
# Idempotent: safe to re-run. Each step checks before acting.

set -euo pipefail

AGENTFORGE_REPO="https://github.com/reinraus135-cyber/agentforge-install.git"
AGENTFORGE_DIR="$HOME/AgentForge"
NVM_DIR_DEFAULT="$HOME/.nvm"
NODE_LTS="22"
MARKER_DIR="$HOME/.ecc"
MARKER_FILE="$MARKER_DIR/.install-complete"

# -- Colors --
if [ -t 1 ] && command -v tput &>/dev/null; then
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
  CYAN=$(tput setaf 6)
  DIM=$(tput dim)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  GREEN="" YELLOW="" RED="" CYAN="" DIM="" BOLD="" RESET=""
fi

ok()   { echo "${GREEN}[OK]${RESET}   $*"; }
warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
err()  { echo "${RED}[ERR]${RESET}  $*" >&2; }
info() { echo "${DIM}[--]${RESET}   $*"; }
step() { echo "${CYAN}[$1/$2]${RESET} $3"; }

fail() { err "$1"; exit 1; }

TOTAL_STEPS=6

echo ""
echo "${BOLD}========================================${RESET}"
echo "${BOLD}  AgentForge -- Linux Environment Setup${RESET}"
echo "${DIM}  Installing tools and AI environment${RESET}"
echo "${BOLD}========================================${RESET}"
echo ""

# -------------------------------------------------------------------
# Step 1: System packages
# -------------------------------------------------------------------
step 1 $TOTAL_STEPS "Updating system packages..."

sudo apt-get update -qq 2>/dev/null

pkgs_needed=()
for pkg in git curl jq build-essential; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    pkgs_needed+=("$pkg")
  fi
done

if [ ${#pkgs_needed[@]} -gt 0 ]; then
  info "Installing: ${pkgs_needed[*]}"
  sudo apt-get install -y -qq "${pkgs_needed[@]}" 2>/dev/null
fi
ok "System packages ready"

# -------------------------------------------------------------------
# Step 2: nvm + Node.js LTS
# -------------------------------------------------------------------
step 2 $TOTAL_STEPS "Setting up Node.js..."

export NVM_DIR="${NVM_DIR:-$NVM_DIR_DEFAULT}"

if [ ! -d "$NVM_DIR" ]; then
  info "Installing nvm v0.40.3..."
  nvm_tmp=$(mktemp)
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh" -o "$nvm_tmp" \
    || fail "Could not download nvm installer"
  PROFILE=/dev/null bash "$nvm_tmp"
  rm -f "$nvm_tmp"
fi

# Source nvm for this session
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if ! command -v nvm &>/dev/null; then
  fail "nvm installation failed. Try manually: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
fi

current_node=""
if command -v node &>/dev/null; then
  current_node=$(node -v 2>/dev/null | grep -oP '\d+' | head -1)
fi

if [ "$current_node" != "$NODE_LTS" ]; then
  info "Installing Node.js $NODE_LTS LTS..."
  nvm install "$NODE_LTS" 2>/dev/null
  nvm alias default "$NODE_LTS" 2>/dev/null
  nvm use "$NODE_LTS" 2>/dev/null
fi

ok "Node.js $(node -v) via nvm"

# -------------------------------------------------------------------
# Step 3: Claude Code CLI
# -------------------------------------------------------------------
step 3 $TOTAL_STEPS "Installing Claude Code..."

if command -v claude &>/dev/null; then
  ok "Claude Code already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
else
  info "Installing Claude Code via npm..."
  npm install -g @anthropic-ai/claude-code --ignore-scripts=false 2>/dev/null \
    || fail "Claude Code installation failed. Try manually: npm i -g @anthropic-ai/claude-code"
  ok "Claude Code installed"
fi

# -------------------------------------------------------------------
# Step 4: Clone AgentForge
# -------------------------------------------------------------------
step 4 $TOTAL_STEPS "Setting up AgentForge..."

if [ -d "$AGENTFORGE_DIR/.git" ]; then
  info "AgentForge already cloned, pulling latest..."
  if git -C "$AGENTFORGE_DIR" pull --ff-only 2>/dev/null; then
    ok "AgentForge updated"
  else
    warn "Could not update AgentForge -- proceeding with cached version"
  fi
else
  if [ -d "$AGENTFORGE_DIR" ]; then
    info "AgentForge directory exists but is not a git repo -- backing up"
    mv "$AGENTFORGE_DIR" "${AGENTFORGE_DIR}.bak.$(date +%s)"
  fi
  info "Cloning AgentForge..."
  git clone --depth 1 "$AGENTFORGE_REPO" "$AGENTFORGE_DIR" 2>/dev/null \
    || fail "Could not clone AgentForge. Check your internet connection."
  ok "AgentForge cloned to $AGENTFORGE_DIR"
fi

# -------------------------------------------------------------------
# Step 5: Run ecc install (Core tier)
# -------------------------------------------------------------------
step 5 $TOTAL_STEPS "Activating your AgentForge license..."

chmod +x "$AGENTFORGE_DIR/ecc"

# Gated model: the clone above is just the CLI. Content is downloaded by `ecc activate`
# after the license key validates. Prompt for the key; skipping leaves a working CLI.
if [ -f "$MARKER_FILE" ]; then
  ok "AgentForge already activated (manage with: ~/AgentForge/ecc status)"
elif [ -t 0 ]; then
  echo ""
  info "Enter your AgentForge license key to download and install your tier."
  info "Don't have one yet? Get it at https://agentforge.army/pricing"
  echo ""
  read -rp "License key (or press Enter to skip for now): " license_key
  echo ""
  if [ -n "$license_key" ]; then
    if bash "$AGENTFORGE_DIR/ecc" activate "$license_key"; then
      mkdir -p "$MARKER_DIR"
      date -Iseconds > "$MARKER_FILE"
      ok "AgentForge activated and installed"
    else
      warn "Activation failed. Retry later: ~/AgentForge/ecc activate <your-license-key>"
    fi
  else
    warn "Skipped activation. When ready: ~/AgentForge/ecc activate <your-license-key>"
  fi
else
  info "Non-interactive mode -- skipping activation."
  info "Activate later: ~/AgentForge/ecc activate <your-license-key>"
fi

# -------------------------------------------------------------------
# Step 6: API key + doctor check
# -------------------------------------------------------------------
step 6 $TOTAL_STEPS "Final checks..."

if [ -t 0 ]; then
  api_key_file="$HOME/.secrets/anthropic_api_key"
  if [ -f "$api_key_file" ] && [ -s "$api_key_file" ]; then
    ok "Anthropic API key already configured"
  else
    echo ""
    info "Claude Code needs an Anthropic API key to work."
    info "Get yours at: https://console.anthropic.com/settings/keys"
    echo ""
    read -rsp "Paste your API key (or press Enter to skip): " api_key
    echo ""
    if [ -n "$api_key" ]; then
      if [[ ! "$api_key" =~ ^sk-ant- ]]; then
        warn "Key doesn't look like an Anthropic API key (expected sk-ant-...)"
        warn "Saving anyway -- double-check at https://console.anthropic.com/settings/keys"
      fi
      mkdir -p "$HOME/.secrets"
      chmod 700 "$HOME/.secrets"
      printf '%s\n' "$api_key" > "$api_key_file"
      chmod 600 "$api_key_file"

      shell_rc="$HOME/.bashrc"
      export_line='export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic_api_key 2>/dev/null)'
      if ! grep -qF 'ANTHROPIC_API_KEY' "$shell_rc" 2>/dev/null; then
        printf '\n%s\n%s\n' "# AgentForge -- Anthropic API key" "$export_line" >> "$shell_rc"
      fi
      export ANTHROPIC_API_KEY="$api_key"
      ok "API key saved to $api_key_file"
    else
      warn "Skipped API key setup. Set it later:"
      info "  mkdir -p ~/.secrets && chmod 700 ~/.secrets"
      info "  echo 'your-key' > ~/.secrets/anthropic_api_key"
      info "  chmod 600 ~/.secrets/anthropic_api_key"
    fi
  fi
else
  info "Non-interactive mode -- skipping API key setup"
  info "Set your API key after install:"
  info "  mkdir -p ~/.secrets && chmod 700 ~/.secrets"
  info "  echo 'your-key' > ~/.secrets/anthropic_api_key"
  info "  chmod 600 ~/.secrets/anthropic_api_key"
fi

echo ""
info "Running health check..."
bash "$AGENTFORGE_DIR/ecc" doctor || true

# -- Add AgentForge to PATH --
shell_rc="$HOME/.bashrc"
path_line='export PATH="$HOME/AgentForge:$PATH"'
if ! grep -qF 'AgentForge' "$shell_rc" 2>/dev/null; then
  printf '\n%s\n%s\n' "# AgentForge -- CLI on PATH" "$path_line" >> "$shell_rc"
fi

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
echo ""
echo "${BOLD}${GREEN}========================================${RESET}"
echo "${BOLD}  Setup complete!${RESET}"
echo "${GREEN}========================================${RESET}"
echo ""
info "Quick start:"
info "  1. Open a new terminal (or run: source ~/.bashrc)"
info "  2. Type: ${BOLD}claude${RESET}"
info "  3. Start building with AI"
echo ""
info "Useful commands:"
info "  ecc status    -- see what's installed"
info "  ecc list      -- browse available skills"
info "  ecc doctor    -- health check"
echo ""
info "Upgrade to Pro: https://agentforge.army/pricing"
echo ""
info "Your AI team is ready. Welcome to AgentForge."
echo ""
