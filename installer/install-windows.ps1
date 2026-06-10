# AgentForge Installer for Windows
# Usage: irm https://agentforge.army/install.ps1 | iex
# Or:    powershell -ExecutionPolicy Bypass -File install-windows.ps1
#
# Single file -- handles EVERYTHING from Windows:
#   WSL2 -> Ubuntu -> system packages -> nvm -> Node.js -> Claude Code -> AgentForge -> ecc install

$ErrorActionPreference = "Stop"
$INSTALLER_DIR = "$env:APPDATA\AgentForge"
$SENTINEL = "$INSTALLER_DIR\agentforge-resume.flag"
$CACHED_SCRIPT = "$INSTALLER_DIR\install-windows.ps1"
$RUN_KEY = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RUN_NAME = "AgentForgeResume"
# TODO: pin to release tag or commit SHA before production launch
$AGENTFORGE_REPO = "https://github.com/reinraus135-cyber/agentforge-install.git"
$UBUNTU_DISTRO = "Ubuntu-22.04"
$NODE_LTS = "22"
$NVM_VERSION = "v0.40.3"

function Write-Step { param($n, $total, $msg) Write-Host "[$n/$total] " -ForegroundColor Cyan -NoNewline; Write-Host $msg }
function Write-Ok { param($msg) Write-Host "[OK]   " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn { param($msg) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Fail { param($msg) Write-Host "[ERR]  " -ForegroundColor Red -NoNewline; Write-Host $msg }
function Write-Info { param($msg) Write-Host "[--]   " -ForegroundColor DarkGray -NoNewline; Write-Host $msg }

# Helper: run a command inside WSL as a given user, fail with message on error
function Invoke-Wsl {
    param(
        [string]$Command,
        [string]$User = "",
        [string]$FailMsg = "",
        [switch]$NoFail
    )
    $args = @("-d", $UBUNTU_DISTRO)
    if ($User) { $args += @("-u", $User) }
    $args += @("--", "bash", "-c", $Command)
    $output = & wsl @args 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $NoFail) {
        if ($FailMsg) { Write-Fail $FailMsg }
        Write-Fail "Command failed: $Command"
        if ($output) { Write-Info ($output | Out-String).Trim() }
        exit 1
    }
    return $output
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AgentForge Installer" -ForegroundColor White
Write-Host "  Your AI team. Ready in 60 seconds." -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TOTAL_STEPS = 12

# -- Check for post-reboot resume --
if (Test-Path $SENTINEL) {
    $resumeStep = (Get-Content $SENTINEL -ErrorAction SilentlyContinue).Trim()
    Remove-Item $SENTINEL -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty $RUN_KEY -Name $RUN_NAME -ErrorAction SilentlyContinue
    Write-Ok "Welcome back! Continuing setup after reboot..."
    Write-Host ""
    $skipWSL = $true
} else {
    $skipWSL = $false
}

# -- Admin elevation --
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Info "AgentForge needs admin access to set up your Linux environment."
    Write-Info "A permission prompt will appear -- click Yes."
    if (-not (Test-Path $INSTALLER_DIR)) { New-Item -ItemType Directory -Path $INSTALLER_DIR -Force | Out-Null }
    $selfContent = if ($MyInvocation.ScriptName) { Get-Content $MyInvocation.ScriptName -Raw } else {
        (Invoke-WebRequest -Uri "https://agentforge.army/install.ps1" -UseBasicParsing).Content
    }
    Set-Content -Path $CACHED_SCRIPT -Value $selfContent -Encoding UTF8
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$CACHED_SCRIPT`""
    exit 0
}

# -- Windows version check --
$build = [System.Environment]::OSVersion.Version.Build
if ($build -lt 19041) {
    Write-Fail "AgentForge requires Windows 10 version 2004 or later (build 19041+)."
    Write-Fail "Your build: $build"
    Write-Info "Please update Windows: Settings > Update & Security > Windows Update"
    exit 1
}
Write-Ok "Windows build $build (supported)"

# ===================================================================
# PHASE 1: Windows-side setup (WSL2 + Ubuntu)
# ===================================================================
if (-not $skipWSL) {

    # -- Step 1: Enable WSL feature --
    Write-Step 1 $TOTAL_STEPS "Checking Windows Subsystem for Linux..."
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        if ($wslFeature.State -ne "Enabled") {
            Write-Info "Enabling WSL..."
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
            $needsReboot = $true
        }
        Write-Ok "WSL feature enabled"
    } catch {
        Write-Fail "Could not enable WSL. Your IT policy may be blocking this."
        Write-Fail "Show your IT team: WSL2 feature enablement blocked by Group Policy"
        exit 1
    }

    # -- Step 2: Enable Virtual Machine Platform --
    Write-Step 2 $TOTAL_STEPS "Checking Virtual Machine Platform..."
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        if ($vmFeature.State -ne "Enabled") {
            Write-Info "Enabling Virtual Machine Platform..."
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
            $needsReboot = $true
        }
        Write-Ok "Virtual Machine Platform enabled"
    } catch {
        Write-Fail "Could not enable Virtual Machine Platform."
        Write-Fail "Show your IT team: VirtualMachinePlatform feature blocked by Group Policy"
        exit 1
    }

    # -- Reboot if needed --
    if ($needsReboot) {
        Write-Host ""
        Write-Warn "Your computer needs to restart to finish enabling WSL2."
        Write-Info "Save your work -- setup will resume automatically after reboot."
        Write-Host ""

        if (-not (Test-Path $INSTALLER_DIR)) { New-Item -ItemType Directory -Path $INSTALLER_DIR -Force | Out-Null }
        "post-reboot" | Out-File -FilePath $SENTINEL -Encoding ASCII
        if ($MyInvocation.ScriptName) {
            Copy-Item $MyInvocation.ScriptName $CACHED_SCRIPT -Force
        } elseif (-not (Test-Path $CACHED_SCRIPT)) {
            (Invoke-WebRequest -Uri "https://agentforge.army/install.ps1" -UseBasicParsing).Content | Set-Content $CACHED_SCRIPT -Encoding UTF8
        }
        $resumeCmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$CACHED_SCRIPT`""
        Set-ItemProperty $RUN_KEY -Name $RUN_NAME -Value $resumeCmd

        Write-Info "Restarting in 10 seconds... (Press Ctrl+C to cancel)"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
        exit 0
    }

    # -- Step 3: Set WSL2 default --
    Write-Step 3 $TOTAL_STEPS "Setting WSL default to version 2..."
    wsl --set-default-version 2 2>&1 | Out-Null
    Write-Ok "WSL2 set as default"

    # -- Step 4: Install Ubuntu --
    Write-Step 4 $TOTAL_STEPS "Checking for Ubuntu 22.04..."
    $installed = wsl --list --quiet 2>&1
    if ($installed -match $UBUNTU_DISTRO) {
        Write-Ok "Ubuntu 22.04 already installed"
    } else {
        Write-Info "Installing Ubuntu 22.04 (this may take a few minutes)..."
        try {
            wsl --install -d Ubuntu-22.04 --no-launch 2>&1 | Out-Null
        } catch {
            Write-Info "Trying alternative install method..."
            wsl --install -d Ubuntu-22.04 2>&1 | Out-Null
        }
        Write-Ok "Ubuntu 22.04 installed"
    }

    # -- Step 5: Set up Ubuntu user --
    Write-Step 5 $TOTAL_STEPS "Setting up Ubuntu user..."
    try {
        wsl -d $UBUNTU_DISTRO -u root -- bash -c "id -u agentforge 2>/dev/null || (useradd -m -s /bin/bash -G sudo agentforge && passwd -l agentforge)" 2>&1 | Out-Null

        $uid = (wsl -d $UBUNTU_DISTRO -u root -- id -u agentforge 2>&1).Trim()

        $lxssPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
        $distroKey = Get-ChildItem $lxssPath -ErrorAction SilentlyContinue | Where-Object {
            (Get-ItemProperty $_.PSPath).DistributionName -eq $UBUNTU_DISTRO
        }
        if ($distroKey) {
            Set-ItemProperty $distroKey.PSPath -Name DefaultUid -Value ([int]$uid)
        }
        Write-Ok "User 'agentforge' created (set a password later with: passwd)"
    } catch {
        Write-Warn "Could not set up default user -- you may need to set one on first launch"
    }
}

# ===================================================================
# PHASE 2: Linux-side setup (all driven from PowerShell via wsl commands)
# ===================================================================
Write-Host ""
Write-Host "Setting up your AI development environment..." -ForegroundColor Cyan
Write-Host ""

# -- Step 6: System packages --
Write-Step 6 $TOTAL_STEPS "Installing system packages inside Ubuntu..."
Invoke-Wsl -User "root" -Command @"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
for pkg in git curl jq build-essential; do
  dpkg -s \$pkg >/dev/null 2>&1 || NEED="\$NEED \$pkg"
done
if [ -n "\$NEED" ]; then
  apt-get install -y -qq \$NEED
fi
"@ -FailMsg "Could not install system packages"
Write-Ok "System packages ready"

# -- Step 7: nvm --
Write-Step 7 $TOTAL_STEPS "Installing nvm (Node Version Manager)..."
$nvmCheck = Invoke-Wsl -Command "test -d ~/.nvm && echo exists || echo missing" -NoFail
if ($nvmCheck -match "missing") {
    Invoke-Wsl -Command @"
NVM_TMP=\$(mktemp)
curl -fsSL 'https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh' -o \$NVM_TMP
PROFILE=/dev/null bash \$NVM_TMP
rm -f \$NVM_TMP
"@ -FailMsg "Could not install nvm"
    Write-Ok "nvm $NVM_VERSION installed"
} else {
    Write-Ok "nvm already installed"
}

# -- Step 8: Node.js LTS --
Write-Step 8 $TOTAL_STEPS "Installing Node.js $NODE_LTS LTS..."
$nodeCheck = Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
node -v 2>/dev/null | grep -oP '\d+' | head -1 || echo none
"@ -NoFail
$currentNode = ($nodeCheck | Out-String).Trim()
if ($currentNode -ne $NODE_LTS) {
    Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
nvm install $NODE_LTS
nvm alias default $NODE_LTS
nvm use $NODE_LTS
"@ -FailMsg "Could not install Node.js $NODE_LTS"
    Write-Ok "Node.js $NODE_LTS installed"
} else {
    Write-Ok "Node.js $NODE_LTS already installed"
}

# -- Step 9: Claude Code CLI --
Write-Step 9 $TOTAL_STEPS "Installing Claude Code..."
$claudeCheck = Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
command -v claude >/dev/null 2>&1 && echo installed || echo missing
"@ -NoFail
if (($claudeCheck | Out-String).Trim() -eq "installed") {
    Write-Ok "Claude Code already installed"
} else {
    Write-Info "Installing Claude Code via npm (this may take a minute)..."
    Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
npm install -g @anthropic-ai/claude-code --ignore-scripts=false
"@ -FailMsg "Could not install Claude Code. Try manually in Ubuntu: npm i -g @anthropic-ai/claude-code"
    Write-Ok "Claude Code installed"
}

# -- Step 10: Clone AgentForge --
Write-Step 10 $TOTAL_STEPS "Setting up AgentForge..."
$repoCheck = Invoke-Wsl -Command "test -d ~/AgentForge/.git && echo exists || echo missing" -NoFail
if (($repoCheck | Out-String).Trim() -eq "exists") {
    Write-Info "AgentForge already cloned, pulling latest..."
    Invoke-Wsl -Command "cd ~/AgentForge && git pull --ff-only 2>/dev/null || true" -NoFail
    Write-Ok "AgentForge updated"
} else {
    # Back up any non-git AgentForge directory
    Invoke-Wsl -Command @"
if [ -d ~/AgentForge ] && [ ! -d ~/AgentForge/.git ]; then
  mv ~/AgentForge ~/AgentForge.bak.\$(date +%s)
fi
"@ -NoFail
    Write-Info "Cloning AgentForge..."
    Invoke-Wsl -Command "git clone --depth 1 $AGENTFORGE_REPO ~/AgentForge" `
        -FailMsg "Could not clone AgentForge. Check your internet connection."
    Write-Ok "AgentForge cloned"
}

# -- Step 11: Activate license (gated model: clone is the CLI; activate downloads content) --
Write-Step 11 $TOTAL_STEPS "Activating your AgentForge license..."
Invoke-Wsl -Command "chmod +x ~/AgentForge/ecc" -NoFail
$markerCheck = Invoke-Wsl -Command "test -f ~/.ecc/.install-complete && echo done || echo needed" -NoFail
if (($markerCheck | Out-String).Trim() -eq "done") {
    Write-Ok "AgentForge already activated"
} else {
    Write-Host ""
    Write-Info "Enter your AgentForge license key to download and install your tier."
    Write-Info "Don't have one yet? Get it at https://agentforge.army/pricing"
    $licenseKey = Read-Host "License key (or press Enter to skip for now)"
    if ($licenseKey) {
        $lkEsc = $licenseKey -replace "'", "'\''"
        $activated = Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
bash ~/AgentForge/ecc activate '$lkEsc' && echo __AF_OK__
"@ -NoFail
        if (($activated | Out-String) -match "__AF_OK__") {
            Invoke-Wsl -Command "mkdir -p ~/.ecc && date -Iseconds > ~/.ecc/.install-complete" -NoFail
            Write-Ok "AgentForge activated and installed"
        } else {
            Write-Warn "Activation failed. Retry later in Ubuntu: ~/AgentForge/ecc activate <key>"
        }
    } else {
        Write-Warn "Skipped activation. When ready, run in Ubuntu: ~/AgentForge/ecc activate <your-license-key>"
    }
}

# -- Step 12: Final setup (PATH, doctor check) --
Write-Step 12 $TOTAL_STEPS "Final setup..."

# Add AgentForge to PATH in .bashrc
Invoke-Wsl -Command @"
if ! grep -qF 'AgentForge' ~/.bashrc 2>/dev/null; then
  printf '\n%s\n%s\n' '# AgentForge -- CLI on PATH' 'export PATH="\$HOME/AgentForge:\$PATH"' >> ~/.bashrc
fi
"@ -NoFail

# Run doctor check
Write-Info "Running health check..."
Invoke-Wsl -Command @"
export NVM_DIR=~/.nvm
[ -s \$NVM_DIR/nvm.sh ] && . \$NVM_DIR/nvm.sh
bash ~/AgentForge/ecc doctor
"@ -NoFail

Write-Ok "Health check complete"

# -- API key prompt (Windows-side, since we have the console) --
Write-Host ""
$apiKeyCheck = Invoke-Wsl -Command "test -f ~/.secrets/anthropic_api_key -a -s ~/.secrets/anthropic_api_key && echo configured || echo missing" -NoFail
if (($apiKeyCheck | Out-String).Trim() -eq "configured") {
    Write-Ok "Anthropic API key already configured"
} else {
    Write-Info "Claude Code needs an Anthropic API key to work."
    Write-Info "Get yours at: https://console.anthropic.com/settings/keys"
    Write-Host ""
    $apiKey = Read-Host "Paste your API key (or press Enter to skip)"
    if ($apiKey) {
        if ($apiKey -notmatch "^sk-ant-") {
            Write-Warn "Key doesn't look like an Anthropic API key (expected sk-ant-...)"
            Write-Warn "Saving anyway -- double-check at https://console.anthropic.com/settings/keys"
        }
        # Write key securely inside WSL
        Invoke-Wsl -Command @"
mkdir -p ~/.secrets && chmod 700 ~/.secrets
printf '%s\n' '$($apiKey -replace "'","'\''")' > ~/.secrets/anthropic_api_key
chmod 600 ~/.secrets/anthropic_api_key
if ! grep -qF 'ANTHROPIC_API_KEY' ~/.bashrc 2>/dev/null; then
  printf '\n%s\n%s\n' '# AgentForge -- Anthropic API key' 'export ANTHROPIC_API_KEY=\$(cat ~/.secrets/anthropic_api_key 2>/dev/null)' >> ~/.bashrc
fi
"@ -NoFail
        Write-Ok "API key saved securely"
    } else {
        Write-Warn "Skipped API key setup."
        Write-Info "Set it later in Ubuntu:"
        Write-Info "  mkdir -p ~/.secrets && chmod 700 ~/.secrets"
        Write-Info "  echo 'your-key' > ~/.secrets/anthropic_api_key && chmod 600 ~/.secrets/anthropic_api_key"
    }
}

# ===================================================================
# DONE
# ===================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  AgentForge installed successfully!" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Info "To start using AgentForge:"
Write-Info "  1. Open 'Ubuntu 22.04' from your Start menu"
Write-Info "  2. Type: claude"
Write-Info "  3. Start building with AI"
Write-Host ""
Write-Info "Useful commands (run inside Ubuntu):"
Write-Info "  ecc status  -- see what's installed"
Write-Info "  ecc list    -- browse available skills"
Write-Info "  ecc doctor  -- health check"
Write-Host ""
Write-Info "Upgrade to Pro: https://agentforge.army/pricing"
Write-Host ""
Write-Info "Your AI team is ready. Welcome to AgentForge."
Write-Host ""
