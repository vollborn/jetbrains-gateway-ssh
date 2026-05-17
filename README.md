# JetBrains Gateway SSH

JetBrains Gateway SSH was made to provide a clean SSH server for JetBrains Gateway.

## Getting started

JetBrains Gateway SSH is pushed to Docker Hub. You can use this `docker-compose.yml` example to quickly start a container:

```yaml
services:
  jetbrains-gateway-ssh:
    image: vollborn/jetbrains-gateway-ssh
    environment:
      SSH_USERNAME: "${SSH_USERNAME:-jetbrains}"
      SSH_PASSWORD: "${SSH_PASSWORD:-jetbrains}"
      SSH_UID: "${SSH_UID:-1001}"
      SSH_GID: "${SSH_GID:-1001}"
      FIX_HOME_OWNERSHIP: "${FIX_HOME_OWNERSHIP:-false}"
    volumes:
      - "./home:/opt/home"
      # - "./setup.sh:/opt/setup.sh"
    ports:
      - "${SSH_PORT:-22}:22"
```

You should change the default password and username by creating an `.env` file with your own credentials:

```env
SSH_PORT=22
SSH_USERNAME=jetbrains
SSH_PASSWORD=myownpassword
SSH_UID=1001
SSH_GID=1001
FIX_HOME_OWNERSHIP=false
```

## Configuration

### `SSH_USERNAME`

The username created inside the container.

Default:

```env
SSH_USERNAME=jetbrains
```

### `SSH_PASSWORD`

The SSH password for the created user.

Default:

```env
SSH_PASSWORD=jetbrains
```

If `SSH_PASSWORD` is empty, password setup is skipped. This is useful when you want to authenticate only with SSH keys.

Example:

```env
SSH_PASSWORD=
```

### `SSH_UID` and `SSH_GID`

The UID and GID used when creating the SSH user inside the container.

Default:

```env
SSH_UID=1001
SSH_GID=1001
```

This is useful when bind-mounting directories from the host. Set these values to match the UID and GID of your host user to avoid permission problems.

You can check your host UID and GID with:

```shell
id
```

Example output:

```text
uid=3000(username) gid=3000(username) groups=3000(username)
```

In that case, use:

```env
SSH_UID=3000
SSH_GID=3000
```

### `FIX_HOME_OWNERSHIP`

Controls whether `/opt/home` should be recursively changed to the configured `SSH_UID:SSH_GID` when the container starts.

Default:

```env
FIX_HOME_OWNERSHIP=false
```

Set it to `true` only if you want the container to recursively change ownership of the mounted `/opt/home` directory:

```env
FIX_HOME_OWNERSHIP=true
```

Be careful when enabling this option with an existing host directory, especially if you mount your real home directory.

## SSH key authentication

To use SSH key authentication, mount a home directory containing an `.ssh/authorized_keys` file.

Example host structure:

```text
./home/
└── .ssh/
    └── authorized_keys
```

The `authorized_keys` file should contain your public SSH key, for example the contents of:

```shell
cat ~/.ssh/id_rsa.pub
```

Do not put your private key into `authorized_keys`.

Recommended permissions:

```shell
chmod 700 ./home/.ssh
chmod 600 ./home/.ssh/authorized_keys
```

If the mounted directory should belong to a specific host user, make sure ownership matches the configured `SSH_UID` and `SSH_GID`.

Example:

```shell
sudo chown -R 3000:3000 ./home
```

Then configure:

```env
SSH_UID=3000
SSH_GID=3000
SSH_PASSWORD=
```

With an empty `SSH_PASSWORD`, the container will skip password setup and allow SSH key based authentication.

## Bind-mounted home directory warning

When mounting a host directory to `/opt/home`, make sure the UID and GID used inside the container match the owner of the host directory.

For example, this can cause permission issues if the host user has UID/GID `3000:3000`, but the container user is created with `1001:1001`:

```yaml
volumes:
  - "/home/username:/opt/home"
```

To avoid this, configure matching IDs:

```env
SSH_UID=3000
SSH_GID=3000
```

Avoid mounting your real host home directory unless you understand the ownership implications. A safer approach is to mount a dedicated directory:

```yaml
volumes:
  - "./jetbrains-home:/opt/home"
```

If you do mount an existing host directory and enable:

```env
FIX_HOME_OWNERSHIP=true
```

the container will recursively run ownership changes on `/opt/home`. This may modify ownership of files on the host through the bind mount.

## Example: password authentication

```yaml
services:
  jetbrains-gateway-ssh:
    image: vollborn/jetbrains-gateway-ssh
    environment:
      SSH_USERNAME: jetbrains
      SSH_PASSWORD: jetbrains
      SSH_UID: "1001"
      SSH_GID: "1001"
      FIX_HOME_OWNERSHIP: "false"
    volumes:
      - "./home:/opt/home"
    ports:
      - "22:22"
```

## Example: SSH key authentication only

Prepare the home directory:

```shell
mkdir -p ./home/.ssh
cat ~/.ssh/id_rsa.pub > ./home/.ssh/authorized_keys
chmod 700 ./home/.ssh
chmod 600 ./home/.ssh/authorized_keys
```

Example `docker-compose.yml`:

```yaml
services:
  jetbrains-gateway-ssh:
    image: vollborn/jetbrains-gateway-ssh
    environment:
      SSH_USERNAME: jetbrains
      SSH_PASSWORD: ""
      SSH_UID: "1001"
      SSH_GID: "1001"
      FIX_HOME_OWNERSHIP: "false"
    volumes:
      - "./home:/opt/home"
    ports:
      - "22:22"
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

### 3. Copy `.env.example` to `.env`
```shell
# Linux
cp .env.example .env

# Windows
copy .env.example .env
```

### 4. Change the default configuration in the `.env` file
```shell
# Linux
vim .env

# Windows
notepad .env
```

Current default configuration:
```env
SSH_PORT=22
SSH_USERNAME=jetbrains
SSH_PASSWORD=jetbrains
SSH_UID=1001
SSH_GID=1001
FIX_HOME_OWNERSHIP=false
```

For SSH key only authentication:
```env
SSH_PORT=22
SSH_USERNAME=jetbrains
SSH_PASSWORD=
SSH_UID=1001
SSH_GID=1001
FIX_HOME_OWNERSHIP=false
```

### 5. Optional: setup script

Do you have additional dependencies you need to install? Just copy the `setup.sh.example`, add your dependencies and mount it as `/opt/setup.sh`.
<br>The script will run every time the container starts.

```yaml
services:
  jetbrains-gateway-ssh:
    image: vollborn/jetbrains-gateway-ssh
    volumes:
      - "./home:/opt/home"
      - "./setup.sh:/opt/setup.sh"
```

### 6. Start the Docker container

```shell
docker-compose up
```

Congratulations!<br>
You can now access the SSH server with your specified credentials.
