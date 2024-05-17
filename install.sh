#!/bin/bash

set -e

# URL JSON untuk mendapatkan token
TOKEN_URL="https://getpantry.cloud/apiv1/pantry/c4a7d113-85fe-48c7-a60a-6949d946f7c0/basket/themetoken"

# Mendapatkan token dari URL JSON
TOKEN=$(curl -s "$TOKEN_URL" | jq -r .token)

# Meminta pengguna untuk memasukkan token
read -p "Tokennya apaa hayyooooo~~~~~: " USER_TOKEN

# Memverifikasi token
if [ "$USER_TOKEN" != "$TOKEN" ]; then
  echo "Yahhhh,tokennya salaahhh, sayonaraa~~~~~"
  exit 1
else
  echo "Yeyyy tokennya bener >_< Irasheimase~~~~~"
fi

# Menampilkan menu
echo "Pilih opsi:"
echo "1. Install tema"
echo "2. Uninstall tema"
read -p "Masukkan pilihan (1 atau 2): " MENU_CHOICE

# File untuk menyimpan nama snapshot
SNAPSHOT_FILE="/var/tmp/chiwa_snapshot_name"

# Fungsi untuk instalasi tema
install_tema() {
  if [ ! -d /var/www/pterodactyl ]; then
    echo "Silahkan install panel terlebih dahulu."
    exit 1
  fi

  # Menginstall timeshift dan membuat backup
  sudo apt install unzip
  sudo apt update
  sudo apt install -y timeshift
  SNAPSHOT_NAME="chiwa_snapshot_$(date +%Y%m%d_%H%M%S)"
  sudo timeshift --create --comments "Backup sebelum instalasi tema" --tags D --snapshot-name "$SNAPSHOT_NAME"

  # Menyimpan nama snapshot ke file
  echo "$SNAPSHOT_NAME" > "$SNAPSHOT_FILE"

  # Melakukan langkah-langkah instalasi tema
  wget -q https://github.com/aiprojectchiwa/pterodactylthemeautoinstaller/raw/main/pterodactyl%20fix%20variable%20box%20eror.zip
  sudo unzip -q pterodactyl%20fix%20variable%20box%20eror.zip -d /var/www/pterodactyl
  curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo npm i -g yarn
  cd /var/www/pterodactyl
  yarn add react-feather
  php artisan migrate
  yes | php artisan migrate
  yarn build:production
  php artisan view:clear

  echo "Tema telah terinstall, makaciih udah pake script chiwa ><"
  exit 0
}

# Fungsi untuk uninstalasi tema
uninstall_tema() {
  if [ ! -f "$SNAPSHOT_FILE" ]; then
    echo "Anda belum menginstall tema."
    exit 1
  fi

  SNAPSHOT_NAME=$(cat "$SNAPSHOT_FILE")

  # Merestore snapshot
  sudo timeshift --restore --snapshot "$SNAPSHOT_NAME"

  echo "Tema telah diuninstall."
  exit 0
}

# Menjalankan fungsi berdasarkan pilihan pengguna
case "$MENU_CHOICE" in
  1)
    install_tema
    ;;
  2)
    uninstall_tema
    ;;
  *)
    echo "Pilihan tidak valid, keluar dari skrip."
    exit 1
    ;;
esac
