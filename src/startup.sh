#!/bin/bash
set -e

SSH_USERNAME="${SSH_USERNAME:-jetbrains}"
SSH_PASSWORD="${SSH_PASSWORD:-jetbrains}"
SSH_UID="${SSH_UID:-1001}"
SSH_GID="${SSH_GID:-1001}"
FIX_HOME_OWNERSHIP="${FIX_HOME_OWNERSHIP:-false}"

echo "Checking group..."

if ! getent group "${SSH_USERNAME}" > /dev/null; then
  echo "Group not found. Adding..."
  addgroup --gid "${SSH_GID}" "${SSH_USERNAME}"
fi

echo "Checking user..."

if ! id "${SSH_USERNAME}" > /dev/null 2>&1; then
  echo "User not found. Adding..."
  adduser \
    --home /opt/home \
    --ingroup "${SSH_USERNAME}" \
    --uid "${SSH_UID}" \
    --disabled-password \
    --gecos "" \
    "${SSH_USERNAME}"
fi

if [ -n "${SSH_PASSWORD}" ]; then
  echo "Changing password..."
  echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
else
  echo "SSH_PASSWORD is empty. Skipping password setup."
fi

if [ "${FIX_HOME_OWNERSHIP}" = "true" ]; then
  echo "Changing home directory ownership recursively..."
  chown -R "${SSH_UID}:${SSH_GID}" /opt/home
fi

if [ -f /opt/setup.sh ]; then
  echo "Running setup script..."
  bash /opt/setup.sh
  echo "Setup completed."
fi

echo "Starting ssh daemon..."
mkdir -p -m0755 /var/run/sshd

/usr/sbin/sshd -D