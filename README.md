# linux-scripts

These scripts are intended for my personal use and should be reviewed carefully before running.

## Repository Contents

- `scripts/01-aurora.sh`
- `scripts/02-kde-gdrive.sh`
- `scripts/03-wonderbrushed.sh`
- `scripts/99-clean-vscode.sh`

## Scripts

### `scripts/01-aurora.sh`

My post install script to customize Aurora after a fresh install.

### `scripts/02-kde-gdrive.sh`

Fixes KDE Google account integration by installing a local `google.provider` override.

Important notes:
- Update `ClientId` and `ClientSecret` in the script before use.

### `scripts/03-wonderbrushed.sh`

Downloads the latest Wonderbrushed release from GitHub and installs its icon assets locally.

### `scripts/99-clean-vscode.sh`

Cleans up Visual Studio Code user state and extensions directories if something gets corrupted.
