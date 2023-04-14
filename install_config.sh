#!/bin/bash

# Check if dependencies are installed
command -v ssmtp >/dev/null 2>&1 || SSMTP_INSTALLED=false
command -v mail >/dev/null 2>&1 || MAILUTILS_INSTALLED=false
command -v mutt >/dev/null 2>&1 || MUTT_INSTALLED=false

if [ "$SSMTP_INSTALLED" = false ] || [ "$MAILUTILS_INSTALLED" = false ] || [ "$MUTT_INSTALLED" = false ]; then
  echo "ssmptp, mailutils, or mutt are not installed."
  read -p "Do you want to install them? (y/n): " choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    sudo apt update
    sudo apt install ssmtp mailutils mutt
  else
    echo "Exiting without installation."
    exit 1
  fi
fi

echo

# Configure ssmtp
read -p "Enter your Gmail email address: " GMAIL_EMAIL
read -p "Enter your Gmail app password: " GMAIL_APP_PASSWORD

SSMTP_CONFIG="/etc/ssmtp/ssmtp.conf"

#backup
sudo cp "$SSMTP_CONFIG" "$SSMTP_CONFIG.bak"

sudo tee "$SSMTP_CONFIG" > /dev/null <<EOL
root=$GMAIL_EMAIL
mailhub=smtp.gmail.com:587
AuthUser=$GMAIL_EMAIL
AuthPass=$GMAIL_APP_PASSWORD
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
EOL

echo
echo "SSMTP has been configured with your Gmail account."
echo "You can now send emails from the command line."

