# NotSwedishBacon's linux scripts

Simple helper scripts for Fedora Atomic desktop installs.

## Purpose
These scripts are my personal tools for local setup and fixes. Use or adapt them if you like, but review the files before running.

## Scripts

### `scripts/installdiscord.sh`

Installs Discord for the current user without requiring root access.

What it does:
- Creates `$HOME/.local/share/discord`
- Downloads the latest Discord tarball to `$HOME/Downloads/discord.tar.gz`
- Extracts Discord into the local install directory
- Creates a local icon and desktop entry
- Refreshes the local desktop database
- Removes the downloaded tarball

Run:

```bash
bash scripts/installdiscord.sh
```

### `scripts/disable_raop.sh`

Disables RAOP (AirPlay) support in PipeWire. 

What it does:
- Creates `/etc/pipewire/pipewire.conf.d` (requires `sudo`) or `~/.config/pipewire/pipewire.conf.d`
- Writes `disable-raop.conf` to disable RAOP
- Restarts `pipewire` and `pipewire-pulse`

Run:

```bash
bash scripts/disable_raop.sh
```

### `scripts/disable_nm_wait_online.sh`

Stops `NetworkManager-wait-online.service` from delaying boot. (requires `sudo`)

What it does:
- Uses `systemctl` to disable and mask the service 
- Does nothing if the service is not installed

Run:

```bash
bash scripts/disable_nm_wait_online.sh
```

Notes:
- Undo with `sudo systemctl unmask --now NetworkManager-wait-online.service`.

### `scripts/enable_kargs.sh`

Adds `i915` kernel options and updates initramfs on rpm-ostree systems. (requires `sudo`)

What it does:
- Backs up `/etc/modprobe.d/i915.conf` if it exists
- Writes:

```
options i915 enable_guc=2
options i915 enable_fbc=1
```

- Runs `sudo rpm-ostree initramfs --enable --arg=-I --arg=/etc/modprobe.d/i915.conf`

Run:

```bash
bash scripts/enable_kargs.sh
```

Notes:
- Reboot is required for the changes to take effect.

### `scripts/fix_kde_google_integration.sh`

Fixes KDE Google account provider configuration.

What it does:
- Backs up `$HOME/.local/share/accounts/providers/google.provider` if present
- Writes a corrected Google OAuth2 provider override
- Restarts KDE account services to load the new config

Important:
- You must provide your own Google OAuth client ID and secret.
- Replace the placeholders in the script before running:
  - `ClientId=get-your-own.apps.googleusercontent.com`
  - `ClientSecret=my-secret`

Run:

```bash
bash scripts/fix_kde_google_integration.sh
```

## Generating Google credentials

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Create or select a project.
3. Configure the OAuth consent screen under `APIs & Services`.
4. Create credentials in `APIs & Services` > `Credentials`.
5. Choose `OAuth 2.0 Client ID`.
6. Select `Desktop app` or `Web application`.
7. Copy the `Client ID` and `Client Secret`.
8. Add them to `scripts/fix_kde_google_integration.sh`.