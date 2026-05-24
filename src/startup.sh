#!/bin/bash
set -e

SSH_USERNAME="${SSH_USERNAME:-jetbrains}"
SSH_UID="${SSH_UID:-1001}"
SSH_GID="${SSH_GID:-1001}"
SSH_PASSWORD="${SSH_PASSWORD:-}"
FIX_HOME_OWNERSHIP="${FIX_HOME_OWNERSHIP:-false}"

SSH_HOME="/opt/home"
SSH_DIR="${SSH_HOME}/.ssh"
AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"

ensure_owner() {
  local path="$1"
  local expected_uid="$2"
  local expected_gid="$3"

  [ -e "${path}" ] || return 0

  local current_uid
  local current_gid

  current_uid="$(stat -c "%u" "${path}")"
  current_gid="$(stat -c "%g" "${path}")"

  [ "${current_uid}" = "${expected_uid}" ] && [ "${current_gid}" = "${expected_gid}" ] && return 0

  echo "Fixing ownership for ${path}: ${current_uid}:${current_gid} -> ${expected_uid}:${expected_gid}"
  chown "${expected_uid}:${expected_gid}" "${path}"
}

ensure_mode() {
  local path="$1"
  local expected_mode="$2"

  [ -e "${path}" ] || return 0

  local current_mode

  current_mode="$(stat -c "%a" "${path}")"

  [ "${current_mode}" = "${expected_mode}" ] && return 0

  echo "Fixing permissions for ${path}: ${current_mode} -> ${expected_mode}"
  chmod "${expected_mode}" "${path}"
}

echo "Checking group..."

if ! getent group "${SSH_USERNAME}" > /dev/null; then
  echo "Group not found. Adding..."
  addgroup --gid "${SSH_GID}" "${SSH_USERNAME}"
fi

echo "Checking user..."

ADDUSER_HOME_OPTIONS=(
  --home "${SSH_HOME}"
)

if [ -d "${SSH_HOME}" ]; then
  ADDUSER_HOME_OPTIONS=(
    --home "${SSH_HOME}"
    --no-create-home
  )
fi

if ! id "${SSH_USERNAME}" > /dev/null 2>&1; then
  echo "User not found. Adding..."
  adduser \
    "${ADDUSER_HOME_OPTIONS[@]}" \
    --ingroup "${SSH_USERNAME}" \
    --uid "${SSH_UID}" \
    --disabled-password \
    --gecos "" \
    "${SSH_USERNAME}"
fi

echo "Checking home directory ownership..."
ensure_owner "${SSH_HOME}" "${SSH_UID}" "${SSH_GID}"

if [ -n "${SSH_PASSWORD}" ]; then
  echo "Changing password..."
  echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
fi

if [ -z "${SSH_PASSWORD}" ]; then
  echo "SSH_PASSWORD is empty. Skipping password setup."
fi

if [ "${FIX_HOME_OWNERSHIP}" = "true" ]; then
  echo "Changing home directory ownership recursively..."
  chown -R "${SSH_UID}:${SSH_GID}" "${SSH_HOME}"
fi

if [ -d "${SSH_DIR}" ]; then
  echo "Checking SSH directory permissions..."
  ensure_owner "${SSH_DIR}" "${SSH_UID}" "${SSH_GID}"
  ensure_mode "${SSH_DIR}" "700"
fi

if [ -f "${AUTHORIZED_KEYS}" ]; then
  echo "Checking authorized_keys permissions..."
  ensure_owner "${AUTHORIZED_KEYS}" "${SSH_UID}" "${SSH_GID}"
  ensure_mode "${AUTHORIZED_KEYS}" "600"
fi

if [ -f /opt/setup.sh ]; then
  echo "Running setup script..."
  bash /opt/setup.sh
  echo "Setup completed."
fi

echo "Starting ssh daemon..."
mkdir -p -m0755 /var/run/sshd

/usr/sbin/sshd -D