<!--
=============================================================================== 
INFO
===============================================================================
[/ael-documentation/components/ael-containers/INDEX.md]

Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
Created     : 2026-09-30 18:54:59 UTC
Updated     : 2026-09-30 18:54:59 UTC
Description : AEL//containers README
-------------------------------------------------------------------------------
-->

# AEL//containers

**AEL//containers** is a TOML-driven Docker container runner for the AEL 
ecosystem.

The Python engine contains the generic lifecycle logic. 

Container-specific knowledge belongs in TOML definitions, so a new application 
can usually be added without changing the the core engine.

## Installation

Requirements:

- Python 3.11 or newer
- Docker for container operations
- `xdg-open` for TOMLs using browser opening

Clone/download the repository, then run:

```bash
chmod +x install.sh uninstall.sh ael-containers
./install.sh
```

The default installation is:

```text
~/.local/bin/ael-containers
~/.local/share/ael-containers/*.toml
~/.config/ael-containers/
```

The installer updates the AEL-owned global catalog. It does not modify files in the private configuration directory.

If `~/.local/bin` is not in `PATH`, add it through your shell configuration.

## Uninstallation

```bash
./uninstall.sh
```

The uninstaller removes:

```text
~/.local/bin/ael-containers
~/.local/share/ael-containers/
```

It deliberately preserves:

```text
~/.config/ael-containers/
```

It also does not remove Docker containers, images, Docker volumes, or host-mounted application data. Use the AEL//Containers lifecycle commands before uninstalling, if those resources should also be removed, or use the normal docker utilities.

## Configuration

AEL//containers deliberately separates the AEL-owned catalog from user-owned configuration.

### Global — AEL-owned

```text
${XDG_DATA_HOME:-~/.local/share}/ael-containers/
```

Normally:

```text
~/.local/share/ael-containers/
```

Files here are installed and updated by AEL.

They are addressed explicitly with the `global/` namespace:

```bash
ael-containers global/kali start
```

### Private — user-owned

```text
${XDG_CONFIG_HOME:-~/.config}/ael-containers/
```

Normally:

```text
~/.config/ael-containers/
```

Files here belong to the user. The installer and uninstaller do not overwrite or delete them.

They are addressed explicitly with the `private/` namespace:

```bash
ael-containers private/stirling-pdf start
```

### Name resolution

An unqualified name prefers the private definition and falls back to the global catalog:

```text
ael-containers stirling-pdf start
        │
        ├── ~/.config/ael-containers/stirling-pdf.toml
        │      private — preferred when present
        │
        └── ~/.local/share/ael-containers/stirling-pdf.toml
               global — fallback
```

Therefore, when no private override exists, these are equivalent:

```bash
ael-containers stirling-pdf start
ael-containers global/stirling-pdf start
ael-containers --config ~/.local/share/ael-containers/stirling-pdf.toml start
```

If both global and private definitions exist, this:

```bash
ael-containers stirling-pdf start
```

uses the private definition.

## Options and Usage

The 0.1.0 command interface is:

```bash
ael-containers list

ael-containers <name> start
ael-containers <name> stop
ael-containers <name> restart
ael-containers <name> status
ael-containers <name> open
ael-containers <name> shell
ael-containers <name> logs
ael-containers <name> install
ael-containers <name> uninstall
ael-containers <name> remove
ael-containers <name> health
```

Follow logs with:

```bash
ael-containers <name> logs -f
```

An arbitrary TOML can also be used directly:

```bash
ael-containers --config /path/to/container.toml start
```

### Listing containers

```bash
ael-containers list
```

Example:

```text
NAME                  CONTAINER            STATUS
--------------------  -------------------  -----------
global/dvwa           dvwa-on-ael          not-created
global/it-tools       it-tools-on-ael      not-created
private/it-tools      personal-it-tools    running
private/kali          kali-on-ael          not-created
private/stirling-pdf  stirling-pdf-on-ael  running
```

Both definitions are shown when the same TOML name exists globally and privately.

Definitions may point to the same Docker container or to different container names. `list` reports the Docker state of the container named by each TOML.

### Lifecycle semantics

#### `install`

Pulls the configured Docker image or builds the configured image.

```bash
ael-containers stirling-pdf install
```

#### `start`

Ensures the image exists, creates the container when necessary, and starts it.

```bash
ael-containers stirling-pdf start
```

#### `stop`

Stops the container without removing it.

#### `restart`

Restarts an existing container. If it does not exist, the engine starts it.

#### `status`

Reports whether the configured container is running, stopped, or not created.

#### `open`

Starts the application when necessary, waits for its configured health check, and launches the configured browser/application command.

#### `shell`

Starts the container when necessary and opens the configured interactive shell.

#### `logs`

Shows Docker logs.

```bash
ael-containers stirling-pdf logs
ael-containers stirling-pdf logs -f
```

#### `health`

Runs the health check described by the TOML definition.

#### `remove`

Removes the Docker container but retains its image, TOML definition, and host-mounted persistent data.

#### `uninstall`

Removes the Docker container and configured image.

It does **not** remove the TOML definition or host-mounted persistent data.

## TOML: Creating a private container

**Do not modify a global TOML container file.** These are overwritten by updates.

Instead, copy a global definition to `~/.config/ael-containers/`:

```bash
cp ~/.local/share/ael-containers/it-tools.toml \
   ~/.config/ael-containers/it-tools.toml
```

Edit the private TOML:

```bash
vim ~/.config/ael-containers/it-tools.toml
```

Then:

```bash
ael-containers it-tools start
```

automatically uses the private definition.

To explicitly select one version:

```bash
ael-containers global/it-tools status
ael-containers private/it-tools status
```

A private definition should use a different Docker container name, allowing the global and private definitions to represent independent instances. If a copy of a global container definition was made, simply remove <-on-ael> at the end of the name.

### TOML example

A simple web application can be described as:

```toml
[container]
name = "it-tools-on-ael"
image = "corentinth/it-tools:latest"
restart = "unless-stopped"

[[container.ports]]
host = 8081
container = 80

[open]
type = "browser"
url = "http://localhost:8081"
wait_for_health = true

[health]
type = "http"
url = "http://localhost:8081"
timeout = 30
interval = 0.5

[shell]
command = ["/bin/sh"]
```

More complex definitions can describe persistent mounts, environment variables, image builds, generated build files, custom shell users, VNC launchers, and other container-specific requirements.

## Requirements

* `python3`
* `docker`
* `xdg-open`

## Resources

* [AEL//Documentation](https://github.com/alterEGO-Linux/ael-documentation)
