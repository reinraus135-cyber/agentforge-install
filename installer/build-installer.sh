#!/usr/bin/env bash
# Build AgentForge-Setup.exe from agentforge.nsi
# Requires: sudo apt install nsis
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v makensis &>/dev/null; then
  echo "ERROR: makensis not found. Install with: sudo apt install nsis"
  exit 1
fi

echo "Building AgentForge-Setup.exe..."
makensis agentforge.nsi

if [ -f "AgentForge-Setup.exe" ]; then
  echo ""
  echo "SUCCESS: AgentForge-Setup.exe created ($(du -h AgentForge-Setup.exe | cut -f1))"
  echo "Location: $(pwd)/AgentForge-Setup.exe"
else
  echo "ERROR: Build failed"
  exit 1
fi
