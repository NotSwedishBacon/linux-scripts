# linux-scripts

Useful Linux scripts for setting up Fedora Atomic or minimal desktop installations.

Personal note: This repository reflects my personal setup and the small helper
scripts I use on my own systems. Feel free to use or adapt any parts of it,
but review the scripts and adjust paths or credentials before running.

## Purpose

This repository contains small helper scripts for installing user applications and fixing KDE account integration issues on Fedora-based systems.

## Scripts

### `scripts/installdiscord.sh`

Installs Discord for the current user without requiring root access.

What it does:
- Creates a local Discord install directory under `$HOME/.local/share/discord`
- Downloads the latest Discord tarball to `$HOME/Downloads/discord.tar.gz`
- Extracts Discord into the local install directory
- Sets up a local icon and desktop entry so Discord appears in app menus
- Refreshes the local desktop database
- Cleans up the downloaded tarball

How to run:

```bash
bash scripts/installdiscord.sh
```

### `scripts/disable_raop.sh`

Disables RAOP (AirPlay) support in PipeWire by writing a local PipeWire override file.

What it does:
- Creates `/etc/pipewire/pipewire.conf.d`
- Writes `disable-raop.conf` to disable the RAOP module
- Restarts the user PipeWire services `pipewire` and `pipewire-pulse`

How to run:

```bash
bash scripts/disable_raop.sh
```

### `scripts/enable_kargs.sh`

Writes a `i915` kernel module options file and updates the
initramfs on rpm-ostree systems so the file is included early in boot.

What it does:
- Backs up an existing `/etc/modprobe.d/i915.conf` to a timestamped backup
- Writes the following lines to `/etc/modprobe.d/i915.conf`:

```
options i915 enable_guc=2
options i915 enable_fbc=1
```
- Runs `sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf`

How to run:

```bash
bash scripts/enable_kargs.sh
```

Notes:
- Intended for rpm-ostree systems (Fedora Silverblue, Kinoite, etc.).
- Requires `sudo` and `rpm-ostree` to be available.
- A reboot is required for the kernel options to take effect.

### `scripts/fix_kde_google_integration.sh`

Writes a corrected local KDE accounts provider configuration for Google and restarts KDE account services.

What it does:
- Backs up an existing local provider file at `$HOME/.local/share/accounts/providers/google.provider`
- Creates or updates the local override file with a working Google OAuth2 provider configuration
- Restarts the KDE account management service so the new configuration is loaded

Important:
- This script requires a Google OAuth client ID and client secret generated from the Google Cloud Console.
- Replace the placeholder values in the script before running:
  - `ClientId=get-your-own.apps.googleusercontent.com`
  - `ClientSecret=my-secret`

How to run:

```bash
bash scripts/fix_kde_google_integration.sh
```

## Generating Google credentials

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Create or select a project.
3. Open `APIs & Services` > `OAuth consent screen` and configure the consent screen for external or internal use.
4. Open `APIs & Services` > `Credentials` and create an OAuth 2.0 Client ID.
5. Choose `Desktop app` or `Web application` as the application type.
6. Copy the generated `Client ID` and `Client Secret`.
7. Update `scripts/fix_kde_google_integration.sh` with those values.

## Notes

- These scripts are intended for user-local installs and local configuration fixes.
- Run them from the repository root or with the correct relative paths.
- Review the script contents before execution, especially if you are modifying Google credentials or KDE config files.
