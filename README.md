# JetBrains Gateway SSH

JetBrains Gateway SSH was made to provide a clean SSH server for JetBrains Gateway.

## Setup

1. Clone the repository
```shell
git clone https://github.com/vollborn/jetbrains-gateway-ssh.git
```

2. Build the container
```shell
docker-compose build
```

3. Copy .env.example to .env
```shell
# Linux
cp .env.example .env

# Windows
copy .env.example .env
```

4. Change the default password in the .env file.
```shell
# Linux
vim .env

# Windows
notepad .env
```

Current default configuration:
```
SSH_PORT=22
SSH_USERNAME=jetbrains
SSH_PASSWORD=jetbrains
```

5. Start the Docker
```shell
docker-compose up
```

Congratulations!<br>
You can now access the SSH server with your specified credentials.
