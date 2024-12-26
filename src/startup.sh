#!/bin/bash

echo "Checking group..."

if ! grep -q ${SSH_USERNAME} /etc/group &> /dev/null; then
    echo "Group not found. Adding..."
	addgroup ${SSH_USERNAME}
fi

echo "Checking user..."

if ! id "${SSH_USERNAME}" &> /dev/null; then
    echo "User not found. Adding..."
	adduser --home /opt/home --ingroup ${SSH_USERNAME} ${SSH_USERNAME}
fi

echo "Changing password..."
echo -e "${SSH_PASSWORD}\n${SSH_PASSWORD}" | passwd ${SSH_USERNAME}

echo "Changing home directory permissions..."
chown -R ${SSH_USERNAME}:${SSH_USERNAME} /opt/home

if [ -f /opt/setup.sh ]; then
    echo "Running setup script..."
    bash /opt/setup.sh
    echo "Setup completed."
fi

echo "Starting ssh daemon..."

mkdir -p -m0755 /var/run/sshd
/usr/sbin/sshd -D
