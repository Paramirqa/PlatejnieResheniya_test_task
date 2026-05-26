#!/usr/bin/env bash
set -e

echo "=== SYSTEM UPDATE ==="
apt update

echo "=== SYSTEM PACKAGES (NO PYTHON CONFLICTS) ==="
apt install -y \
  ansible \
  sshpass \
  docker.io \
  python3 \
  python3-venv \
  python3-pip \
  git \
  curl \
  jq

echo "=== ENABLE DOCKER ==="
systemctl enable docker
systemctl start docker

usermod -aG docker vagrant || true

echo "=== CREATE ISOLATED PYTHON ENV FOR MOLECULE ==="

sudo -u vagrant bash <<EOF
python3 -m venv /home/vagrant/venv-molecule
source /home/vagrant/venv-molecule/bin/activate

pip install --upgrade pip setuptools wheel

pip install \
  molecule \
  molecule-plugins[docker] \
  docker \
  ansible-lint \
  yamllint
EOF

echo "=== DONE ==="
echo "Activate molecule env with: source ~/venv-molecule/bin/activate"