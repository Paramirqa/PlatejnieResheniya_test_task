#!/usr/bin/env bash

set -e

echo "=== Updating system ==="
apt update

echo "=== Installing system dependencies ==="
apt install -y \
  ansible \
  sshpass \
  python3 \
  python3-pip \
  python3-venv \
  docker.io \
  git \
  curl

echo "=== Starting Docker ==="
systemctl enable docker
systemctl start docker

echo "=== Adding vagrant user to docker group ==="
usermod -aG docker vagrant || true

echo "=== Upgrading pip ==="
pip3 install --upgrade pip

echo "=== Installing Python tools ==="
pip3 install \
  molecule \
  molecule-plugins[docker] \
  ansible \
  docker \
  yamllint \
  ansible-lint

echo "=== Bootstrap completed successfully ==="