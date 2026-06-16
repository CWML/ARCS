#!/usr/bin/env bash
# Codespace bootstrap for ARCS Part 4.
#
# Runs once at Codespace creation (postCreateCommand). Installs Apptainer from
# the official PPA, then pulls the pre-built DESeq2 .sif image so the workshop
# can start with `apptainer exec`, not a 20-minute live build.
#
# Re-running is safe: apt is idempotent and we skip the pull if the .sif exists.

set -euo pipefail

echo "[setup] Installing Apptainer..."
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt-get update -qq
sudo apt-get install -y apptainer

echo "[setup] Apptainer version:"
apptainer --version

# Pre-built image lives in a GitHub Container Registry namespace you control.
# Update IMAGE_URI when you publish a new image tag.
IMAGE_URI="oras://ghcr.io/arcs-workshop/deseq2:latest"
SIF_PATH="${HOME}/images/deseq2.sif"

mkdir -p "$(dirname "${SIF_PATH}")"

if [[ -f "${SIF_PATH}" ]]; then
  echo "[setup] ${SIF_PATH} already present, skipping pull."
else
  echo "[setup] Pulling ${IMAGE_URI} -> ${SIF_PATH}"
  apptainer pull "${SIF_PATH}" "${IMAGE_URI}"
fi

echo "[setup] Done. Try: apptainer exec ${SIF_PATH} R --version"
