#!/bin/bash

set -e

# Install jq jika belum terinstal
if ! command -v jq &> /dev/null; then
  echo "jq tidak ditemukan, menginstall jq..."
  sudo apt update
  sudo apt install -y jq
fi

# Menginisialisasi variabel dengan nilai obfuskasi
a=$(echo -e "\x74\x6f\x6b\x65\x6e")
b=$(echo -e "\x68\x74\x74\x70\x73\x3a\x2f\x2f\x67\x65\x74\x70\x61\x6e\x74\x72\x79\x2e\x63\x6c\x6f\x75\x64\x2f\x61\x70\x69\x76\x31\x2f\x70\x61\x6e\x74\x72\x79\x2f\x63\x34\x61\x37\x64\x31\x31\x33\x2d\x38\x35\x66\x65\x2d\x34\x38\x63\x37\x2d\x61\x36\x30\x61\x2d\x36\x39\x34\x39\x64\x39\x34\x36\x66\x37\x63\x30\x2f\x62\x61\x73\x6b\x65\x74\x2f\x74\x68\x65\x6d\x65\x74\x6f\x6b\x65\x6e")

# Mendapatkan token dari URL JSON
c=$(curl -s "$b" | jq -r .token)

# Meminta pengguna untuk memasukkan token
read -p "Tokennya apaa hayyooooo~~~~~: " d

# Memverifikasi token
if [ "$d" != "$c" ]; then
  echo "Yahhhh,tokennya salaahhh, sayonaraa~~~~~"
  exit 1
else
  echo "Yeyyy tokennya bener >_< Irasheimase~~~~~"
fi

e="/var/tmp/chiwa_snapshot_name"

f() {
  if [ ! -d /var/www/pterodactyl ]; then
    echo "Silahkan install panel terlebih dahulu."
    exit 1
  fi
  sudo apt update && sudo apt install -y unzip timeshift
  g="chiwa_snapshot_$(date +%Y%m%d_%H%M%S)"
  sudo timeshift --create --comments "Backup sebelum instalasi tema" --tags D --snapshot-name "$g"
  echo "$g" > "$e"
  wget -q https://github.com/aiprojectchiwa/pterodactylthemeautoinstaller/raw/main/ptero.zip
  sudo unzip ptero.zip
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

h() {
  if [ ! -f "$e" ]; then
    echo "Anda belum menginstall tema."
    exit 1
  fi
  g=$(cat "$e")
  sudo timeshift --restore --snapshot "$g"
  echo "Tema telah diuninstall."
  exit 0
}

echo "Pilih opsi:"; echo "1. Install tema"; echo "2. Uninstall tema"
read -p "Masukkan pilihan (1 atau 2): " i

case "$i" in
  1) f ;;
  2) h ;;
  *) echo "Pilihan tidak valid, keluar dari skrip."; exit 1 ;;
esac
