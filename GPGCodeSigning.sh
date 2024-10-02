#!/bin/bash

#---------------------------------------------------------------------------------
#Name: Codesinging.sh
#version: 1.3
#Author: Tony Carruthers
#---------------------------------------------------------------------------------

# Credentials file (stores username and hashed password)
CREDENTIALS_FILE="credentials.txt"

# Function to set up user credentials (run this once to initialise)
setup_credentials() {
  echo "Setting up new user credentials..."
  read -p "Enter username: " username
  read -s -p "Enter password: " password
  echo
  read -s -p "Confirm password: " password_confirm
  echo

  if [ "$password" != "$password_confirm" ]; then
    echo "Error: Passwords do not match."
    exit 1
  fi

  # Hash the password using SHA-256 for storage
  hashed_password=$(echo -n "$password" | sha256sum | awk '{print $1}')
  
  # Store username and hashed password
  echo "$username:$hashed_password" > $CREDENTIALS_FILE
  echo "Credentials set up successfully!"
  exit 0
}

# Function to authenticate user
authenticate_user() {
  if [[ ! -f $CREDENTIALS_FILE ]]; then
    echo "Error: Credentials not set up. Please run the script with '--setup' to set credentials."
    exit 1
  fi

  # Prompt for username and password
  read -p "Username: " username
  read -s -p "Password: " password
  echo

  # Hash the entered password to compare with stored hash
  hashed_password=$(echo -n "$password" | sha256sum | awk '{print $1}')
  
  # Check if credentials match
  stored_credentials=$(cat $CREDENTIALS_FILE)
  stored_username=$(echo $stored_credentials | cut -d':' -f1)
  stored_hashed_password=$(echo $stored_credentials | cut -d':' -f2)

  if [[ "$username" == "$stored_username" && "$hashed_password" == "$stored_hashed_password" ]]; then
    echo "Authentication successful!"
  else
    echo "Error: Invalid username or password."
    exit 1
  fi
}

# Function to check for an existing signature
check_existing_signature() {
  if grep -q "-----BEGIN PGP SIGNATURE-----" "$SCRIPT_TO_SIGN"; then
    echo "Warning: The script '$SCRIPT_TO_SIGN' is already signed."
    read -p "Do you want to re-sign it? (y/n): " response
    if [[ "$response" != "y" ]]; then
      echo "Exiting without re-signing."
      exit 1
    fi
    # Remove the old signature and any existing timestamp/auth code block
    sed -i '/# ---- Timestamp:/,/-----END PGP SIGNATURE-----/d' "$SCRIPT_TO_SIGN"
    echo "Old signature removed."
  fi
}

# Handle setup mode for setting credentials
if [[ "$1" == "--setup" ]]; then
  setup_credentials
fi

# Authenticate the user before proceeding
authenticate_user

# Prompt the user for the script to sign
read -p "Enter the script to sign: " SCRIPT_TO_SIGN

# Check if the script exists
if [[ ! -f $SCRIPT_TO_SIGN ]]; then
  echo "Error: File '$SCRIPT_TO_SIGN' not found!"
  exit 1
fi

# Ensure the script has write permissions
if [[ ! -w $SCRIPT_TO_SIGN ]]; then
  echo "Error: Permission denied to modify '$SCRIPT_TO_SIGN'."
  chmod +w "$SCRIPT_TO_SIGN"
  echo "Write permission temporarily granted to '$SCRIPT_TO_SIGN'."
fi

# Check for existing signature
check_existing_signature

# Get the hostname of the device
DEVICE_NAME=$(hostname)

# GPG key to use (change this to the key you want to use)
GPG_KEY=$(gpg --list-secret-keys --with-colons | grep '^sec' | head -n 1 | cut -d: -f5)

# Check if a key was found
if [[ -z "$GPG_KEY" ]]; then
  echo "Error: No GPG key found!"
  exit 1
fi

# Timestamp for the log
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Generate a random authentication code (SHA256 hash based on timestamp and device name)
AUTH_CODE=$(echo -n "${TIMESTAMP}${DEVICE_NAME}${SCRIPT_TO_SIGN}" | sha256sum | awk '{print $1}')

# Log file to store signing info
LOG_FILE="signing_log.txt"

# Create a temporary copy of the script for signing (to avoid modifying the original)
TEMP_SIGN_SCRIPT=$(mktemp)
cp "$SCRIPT_TO_SIGN" "$TEMP_SIGN_SCRIPT"

# Disable passphrase caching for the GPG agent for this session
export GPG_TTY=$(tty)
gpgconf --kill gpg-agent
gpg --yes --pinentry-mode loopback --default-key "$GPG_KEY" --clearsign --output "${TEMP_SIGN_SCRIPT}_signed" "$TEMP_SIGN_SCRIPT"

# Check if signing was successful
if [[ $? -ne 0 ]]; then
  echo "Error: GPG signing failed!"
  rm "$TEMP_SIGN_SCRIPT"  # Clean up temporary file
  exit 1
fi

# Append only the signature to the original script, not the whole script contents again
gpg_signature=$(sed -n '/-----BEGIN PGP SIGNATURE-----/,$p' "${TEMP_SIGN_SCRIPT}_signed")

# Append the timestamp and auth code to the script as comments, followed by the GPG signature
{
  echo ""
  echo "# ---- Timestamp: $TIMESTAMP ----"
  echo "# ---- Auth Code: $AUTH_CODE ----"
  echo "$gpg_signature"
} >> "$SCRIPT_TO_SIGN"

# Clean up temporary files
rm "$TEMP_SIGN_SCRIPT" "${TEMP_SIGN_SCRIPT}_signed"

# Restore execute permissions and make the script read-only (for the owner)
chmod 544 "$SCRIPT_TO_SIGN"  # Read and execute permissions for owner, read-only for others

# Log the signing information with timestamp, device name, and auth code
{
  echo "[$TIMESTAMP] Signed script: $SCRIPT_TO_SIGN"
  echo "Auth Code: $AUTH_CODE"
  echo "GPG Key: $GPG_KEY"
  echo "Device: $DEVICE_NAME"
  echo "-----------------------------"
} >> "$LOG_FILE"

# Output success message
echo "Script '$SCRIPT_TO_SIGN' has been signed, timestamped, and the signature appended."
echo "Authentication Code: $AUTH_CODE"
echo "Log updated in '$LOG_FILE'."
