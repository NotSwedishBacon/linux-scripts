#!/usr/bin/env bash

# fix_kde_google_integration.sh
# Purpose: Repair KDE account integration for Google services by writing
#          a corrected local google.provider configuration file and
#          restarting the account management service.
#
# This script is intended for KDE environments using kaccounts-providers
# where the Google provider configuration is missing or broken.

# Path to the local Google provider override file
PROVIDER_FILE="$HOME/.local/share/accounts/providers/google.provider"

# Backup the existing provider file before making changes
if [ -f "$PROVIDER_FILE" ]; then
  echo "Backing up the original file..."
  cp "$PROVIDER_FILE" "${PROVIDER_FILE}.backup"
  echo "Backup created at ${PROVIDER_FILE}.backup"
else
  echo "Creating empty google.provider file..."
  mkdir -p "$(dirname "$PROVIDER_FILE")" && touch "$PROVIDER_FILE"
fi

# Write the updated configuration to the file
# The local override defines the Google OAuth2 provider settings used by KDE.
echo "Updating the local google.provider file..."
sudo tee "$PROVIDER_FILE" >/dev/null <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<provider id="google">
  <name>Google</name>
  <description>Google Drive and YouTube</description>
  <icon>im-google</icon>
  <translations>kaccounts-providers</translations>
  <domains>.*google\.com</domains>
  <template>
    <group name="auth">
      <setting name="method">oauth2</setting>
      <setting name="mechanism">web_server</setting>
      <group name="oauth2">
        <group name="web_server">
          <setting name="Host">accounts.google.com</setting>
          <setting name="AuthPath">o/oauth2/auth?access_type=offline</setting>
          <setting name="TokenPath">o/oauth2/token</setting>
          <setting name="RedirectUri">http://localhost/oauth2callback</setting>
          <setting name="ResponseType">code</setting>
          <setting type="as" name="Scope">[
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/tasks',
            'https://www.googleapis.com/auth/drive'
          ]</setting>
          <setting type="as" name="AllowedSchemes">['https']</setting>
          <setting name="ClientId">get-your-own.apps.googleusercontent.com</setting>
          <setting name="ClientSecret">my-secret</setting>
          <setting type="b" name="ForceClientAuthViaRequestBody">true</setting>
        </group>
      </group>
    </group>
  </template>
</provider>
EOL

if [ $? -eq 0 ]; then
  echo "google.provider file updated successfully."
else
  echo "Error: Failed to update the google.provider file."
  exit 1
fi

# Restart the KDE account management service so the updated provider configuration is reloaded
echo "Restarting the account management service..."
kquitapp6 kded6

echo "Done. Please re-add your Google account to verify the fix."