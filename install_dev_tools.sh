#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo." && exit 1
fi

USER_NAME="${SUDO_USER:-$USER}"

# 1) Docker + Docker Compose
if command -v docker >/dev/null 2>&1; then
  echo "Docker already installed: $(docker --version)"
else
  echo "Installing Docker…"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(. /etc/os-release; echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
fi

# 2) Python 3 + pip
if command -v python3 >/dev/null 2>&1; then
  echo "Python already installed: $(python3 -V)"
else
  echo "Installing Python 3 and pip…"
  apt-get update -y
  apt-get install -y python3 python3-pip python3-venv
fi

# 3) Django
VENV_DIR="/home/$USER_NAME/.venvs/dev"
BIN_DIR="/home/$USER_NAME/.local/bin"

apt-get update -y
apt-get install -y python3-venv

# create venv
if [[ ! -d "$VENV_DIR" ]]; then
  sudo -u "$USER_NAME" python3 -m venv "$VENV_DIR"
fi

# upgrade pip/setuptools/wheel inside venv
sudo -u "$USER_NAME" "$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel

# install Django in venv
if sudo -u "$USER_NAME" "$VENV_DIR/bin/python" -m django --version >/dev/null 2>&1; then
  echo "Django already installed in venv: $(sudo -u "$USER_NAME" "$VENV_DIR/bin/python" -m django --version)"
else
  sudo -u "$USER_NAME" "$VENV_DIR/bin/pip" install "Django>=4"
  echo "Django installed in venv: $(sudo -u "$USER_NAME" "$VENV_DIR/bin/python" -m django --version)"
fi

# expose django-admin on PATH
mkdir -p "$BIN_DIR"
if [[ ! -L "$BIN_DIR/django-admin" ]]; then
  ln -sf "$VENV_DIR/bin/django-admin" "$BIN_DIR/django-admin"
fi

# ensure ~/.local/bin is on PATH
if ! sudo -u "$USER_NAME" grep -q 'HOME/.local/bin' "/home/$USER_NAME/.bashrc"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/$USER_NAME/.bashrc"
fi

echo "Note: activate venv with: source \"$VENV_DIR/bin/activate\""



# 4) Use docker without sudo
if ! id -nG "$USER_NAME" | grep -qw docker; then
  groupadd -f docker
  usermod -aG docker "$USER_NAME"
  echo "Added $USER_NAME to 'docker' group. Log out/in to use docker without sudo."
fi

echo
echo "All set!"
echo "Docker:       $(docker --version 2>/dev/null || echo 'not found')"
echo "Compose:      $(docker compose version 2>/dev/null || echo 'not found')"
echo "Python:       $(python3 -V 2>/dev/null || echo 'not found')"
echo "Django:       $(sudo -u "$USER_NAME" "$VENV_DIR/bin/python" -m django --version 2>/dev/null || echo 'not found')"


