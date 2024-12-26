# JetBrains Gateway SSH

JetBrains Gateway SSH was made to provide a clean SSH server for JetBrains Gateway.

## Getting started

JetBrains Gateway SSH is pushed to Docker Hub. You can use this docker-compose.yml example to quickly start a container:

```
services:
  jetbrains-gateway-ssh:
    image: vollborn/jetbrains-gateway-ssh
    environment:
      SSH_USERNAME: "${SSH_USERNAME:-jetbrains}"
      SSH_PASSWORD: "${SSH_PASSWORD:-jetbrains}"
    volumes:
      - "./home:/opt/home"
      # - "./setup.sh:/opt/setup.sh"
    ports:
      - "${SSH_PORT:-22}:22"
```

You should change the default password and username by creating an .env file with your own credentials:

```
SSH_PORT=22
SSH_USERNAME=jetbrains
SSH_PASSWORD=myownpassword
```

## Development

### 1. Clone the repository
```shell
git clone https://github.com/vollborn/jetbrains-gateway-ssh.git
```

### 2. Build the container
```shell
docker-compose build
```

### 3. Copy .env.example to .env
```shell
# Linux
cp .env.example .env

# Windows
copy .env.example .env
```

### 4. Change the default password in the .env file.
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

### 5. Optional: setup script

Do you have additional dependencies you need to install? Just copy the `setup.sh.example`, add your dependencies and mount it as `/opt/setup.sh`.
<br>The script will run every time the container starts.

### 6. Start the Docker
```shell
docker-compose up
```

Congratulations!<br>
You can now access the SSH server with your specified credentials.
