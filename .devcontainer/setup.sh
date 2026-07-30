#!/usr/bin/env bash
# =====================================================================
# ARCS Part 4 — Codespace bootstrap
#
# Runs automatically as the Codespace's postCreateCommand. It:
#   1. installs Apptainer (Linux-only — this is why we use a Codespace), and
#   2. pulls the pre-built DESeq2 image to ~/deseq2.sif
# so a student can immediately run:
#   apptainer exec ~/deseq2.sif R --version
# =====================================================================
set -euo pipefail

APPTAINER_VERSION="1.3.6"

echo "==> Installing Apptainer ${APPTAINER_VERSION} ..."
cd /tmp
ARCH="$(dpkg --print-architecture)"          # amd64 on Codespaces
DEB="apptainer_${APPTAINER_VERSION}_${ARCH}.deb"
wget -q "https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/${DEB}"
sudo apt-get update -qq
sudo apt-get install -y -qq "./${DEB}"
rm -f "${DEB}"
apptainer --version

# ---------------------------------------------------------------------
# Pull the pre-built DESeq2 image.
#
# >>> ONE-LINE DELIVERY SWAP <<<
# Default: pull from GHCR (public package — no login needed in class).
# To switch to a GitHub Release asset instead, comment the two lines
# below and uncomment the gh-release line:
#
#   gh release download part4-v1 --repo CWML/ARCS \
#       --pattern deseq2.sif --output "$HOME/deseq2.sif"
# ---------------------------------------------------------------------
IMAGE="${DESEQ2_IMAGE:-oras://ghcr.io/cwml/deseq2:latest}"
echo "==> Pulling DESeq2 image from ${IMAGE} ..."
apptainer pull --force "$HOME/deseq2.sif" "$IMAGE"

echo ""
echo "==> Setup complete."
echo "    Verify : apptainer exec ~/deseq2.sif R --version"
echo "    Run    : cd workshops/arcs_04/_materials && apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R"
