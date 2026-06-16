#!/bin/bash

# ==============================================================================
# @file kalkulator_suhu.sh
# @brief Skrip wrapper Bash untuk aplikasi Kalkulator Suhu.
# @author Alea Farrel
# @note NIM: 25.11.6401
# ==============================================================================

# Kode Warna ANSI
MERAH='\033[0;31m'
NC='\033[0m' # Tanpa Warna

# Memeriksa apakah python3 tersedia di sistem
if ! command -v python3 &> /dev/null; then
    echo -e "${MERAH}❌ Error: python3 tidak ditemukan.${NC}"
    echo -e "Program ini membutuhkan Python 3.x untuk berjalan."
    exit 1
fi

# Menentukan lokasi path absolut dari direktori file bash ini berada
DIREKTORI_SKRIP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKRIP_PYTHON="$DIREKTORI_SKRIP/kalkulator_suhu.py"

# Memverifikasi bahwa file python utama ada di direktori
if [ ! -f "$SKRIP_PYTHON" ]; then
    echo -e "${MERAH}❌ Error: File utama '$SKRIP_PYTHON' tidak ditemukan.${NC}"
    exit 1
fi

# Menjalankan skrip python tanpa meneruskan parameter yang tidak perlu
python3 "$SKRIP_PYTHON"
