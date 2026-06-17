# linux-scripts

Personal helper scripts for Fedora-style systems, with a focus on rpm-ostree/KDE fixes and local package setup. These scripts are intended for personal use and should be reviewed carefully before running.

## Repository Contents

- `scripts/01-main.sh`
- `scripts/02-gdrive.sh`

## Scripts

### `scripts/01-main.sh`

A broad Fedora/rpm-ostree setup script.

What it does:
- Enables TPM2 disk unlocking with `systemd-cryptenroll`
- Disables RAOP (AirPlay) support in PipeWire
- Restarts user PipeWire services
- Disables and masks `NetworkManager-wait-online.service`
- Adds and enables the Flathub Flatpak remote
- Removes installed Flatpak applications and runtimes
- Deletes the Fedora and Fedora-testing Flatpak remotes
- Installs a set of Flatpak apps from Flathub
- Disables the built-in Firefox desktop entry by creating a local override
- Downloads and installs the official Discord tarball to `/var/opt/discord`
- Adds the Visual Studio Code repository
- Enables RPM Fusion and installs packages via `rpm-ostree`
- Writes an `i915` kernel module config and regenerates initramfs for rpm-ostree
- Updates `/etc/rpm-ostreed.conf` to `AutomaticUpdatePolicy=stage`

Important notes:
- This script assumes a Fedora-style rpm-ostree environment.
- Many operations require `sudo`.
- The script modifies system state and can be destructive.

Run:

```bash
bash scripts/01-main.sh
```

### `scripts/02-gdrive.sh`

Fixes KDE Google account integration by installing a local `google.provider` override.

What it does:
- Backs up any existing local provider file at `$HOME/.local/share/accounts/providers/google.provider`
- Writes an updated Google OAuth2 provider configuration
- Restarts KDE account services via `kquitapp6 kded6`

Important notes:
- Update `ClientId` and `ClientSecret` in the script before use.
- This is specific to KDE account provider integration.

Run:

```bash
bash scripts/02-gdrive.sh
```

## Usage

Review the scripts before executing them.

- `bash scripts/01-main.sh`
- `bash scripts/02-gdrive.sh`

## Disclaimer

These are personal utility scripts. They are not guaranteed to work on every system and may require manual adjustment for your environment.
