#!/bin/bash

set -e

# Install jq
sudo apt update
sudo apt install -y jq

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

  # Meminta konfirmasi untuk membuat snapshot Timeshift
  read -p "Apakah Anda ingin membuat snapshot Timeshift untuk memungkinkan uninstall di kemudian hari? (y/n): " CREATE_SNAPSHOT
  if [ "$CREATE_SNAPSHOT" == "y" ]; then
    sudo apt update
    sudo apt install -y timeshift
    SNAPSHOT_NAME="chiwa_snapshot_$(date +%Y%m%d_%H%M%S)"
    sudo timeshift --create --comments "Backup sebelum instalasi tema" --tags D --snapshot-name "$SNAPSHOT_NAME"

    # Menyimpan nama snapshot ke file
    echo "$SNAPSHOT_NAME" > "$SNAPSHOT_FILE"
  fi

  # Memilih tema
  echo "Pilih tema untuk diinstall:"
  echo "1. Stellar"
  echo "2. Enigma"
  read -p "Masukkan pilihan (1 atau 2): " THEME_CHOICE

  case "$THEME_CHOICE" in
    1)
      THEME_URL="https://github.com/aiprojectchiwa/pterodactylthemeautoinstaller/raw/main/stellaredited.zip"
      ;;
    2)
      THEME_URL="https://example.com/enigma_theme.zip" # Ganti dengan URL tema Enigma yang sebenarnya
      ;;
    *)
      echo "Pilihan tidak valid, keluar dari skrip."
      exit 1
      ;;
  esac

  # Memastikan tidak ada file atau direktori bernama pterodactyl sebelum mengekstrak
  if [ -e /root/pterodactyl ]; then
    sudo rm -rf /root/pterodactyl
  fi

  # Mengunduh dan mengekstrak tema
  wget -q "$THEME_URL"
  sudo unzip -o "$(basename "$THEME_URL")"

  if [ "$THEME_CHOICE" -eq 2 ]; then
    # Menanyakan informasi kepada pengguna untuk tema Enigma
    read -p "Masukkan link untuk 'LINK_BC_BOT': " LINK_BC_BOT
    read -p "Masukkan nama untuk 'NAMA_OWNER_PANEL': " NAMA_OWNER_PANEL
    read -p "Masukkan link untuk 'LINK_GC_INFO': " LINK_GC_INFO
    read -p "Masukkan link untuk 'LINKTREE_KALIAN': " LINKTREE_KALIAN

    # Mengganti placeholder dengan nilai dari pengguna
    sudo sed -i "s|LINK_BC_BOT|$LINK_BC_BOT|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|NAMA_OWNER_PANEL|$NAMA_OWNER_PANEL|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINK_GC_INFO|$LINK_GC_INFO|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINKTREE_KALIAN|$LINKTREE_KALIAN|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
  fi

  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
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
    echo "Anda belum menginstall tema atau tidak membuat snapshot."
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
