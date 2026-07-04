#!/bin/bash

# ==============================================================================
# VISUAL UI
# File ini berfungsi khusus untuk mengatur tampilan program
# dalam bentuk visual (kotak, teks berwarna, dll) menggunakan kode warna ANSI.
# ==============================================================================

# ------------------------------------------------------------------------------
# Variabel kode warna ANSI untuk terminal
# ------------------------------------------------------------------------------
W_KUNING=$'\033[93m'
W_BIRU=$'\033[94m'
W_CYAN=$'\033[96m'
W_HIJAU=$'\033[92m'
W_MERAH=$'\033[91m'
W_RESET=$'\033[0m'
W_TEBAL=$'\033[1m'


# ==============================================================================
# FUNGSI KHUSUS MENGGAMBAR TAMPILAN UI
# ==============================================================================

# ------------------------------------------------------------------------------
# Fungsi: gambar_header
# Fungsi untuk menggambar judul program
# ------------------------------------------------------------------------------
gambar_header() {
    clear
    echo -e "${W_KUNING}${W_TEBAL}╔══════════════════════════════════════════════════════╗"
    echo -e "║               KALKULATOR KONVERSI SUHU               ║"
    echo -e "╚══════════════════════════════════════════════════════╝${W_RESET}\n"
}

# ------------------------------------------------------------------------------
# Fungsi: gambar_kotak_pilih_unit
# Fungsi untuk menggambar kotak bingkai pilihan unit satuan suhu
# ------------------------------------------------------------------------------
gambar_kotak_pilih_unit() {
    local judul="$1"
    local unit_asal="$2"
    local bisa_kembali="$3"

    gambar_header

    # Gambar Judul Kotak
    if [[ "$judul" == "Pilih Unit ASAL" ]]; then
        echo -e "${W_BIRU}┌─${W_CYAN} Pilih Unit ASAL ${W_BIRU}────────────────────────────────────┐${W_RESET}"
    else
        echo -e "${W_BIRU}┌─${W_CYAN} Pilih Unit TUJUAN ${W_BIRU}──────────────────────────────────┐${W_RESET}"
    fi

    echo -e "${W_BIRU}│                                                      │${W_RESET}"

    # Tampilkan informasi unit asal jika sudah dipilih
    if [[ "$unit_asal" != "" ]]; then
        printf "${W_BIRU}│${W_KUNING} %-52s ${W_BIRU}│${W_RESET}\n" "- Unit Asal: $unit_asal"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
    fi

    # Menandai warna merah pada unit yang sudah dipilih sebelumnya
    local warna_c="${W_CYAN}"; local warna_f="${W_CYAN}"
    local warna_r="${W_CYAN}"; local warna_k="${W_CYAN}"

    if [[ "$unit_asal" == "Celsius" ]];    then warna_c="${W_MERAH}"; fi
    if [[ "$unit_asal" == "Fahrenheit" ]]; then warna_f="${W_MERAH}"; fi
    if [[ "$unit_asal" == "Reamur" ]];     then warna_r="${W_MERAH}"; fi
    if [[ "$unit_asal" == "Kelvin" ]];     then warna_k="${W_MERAH}"; fi

    # Gambar Menu Pilihan
    echo -e "${W_BIRU}│${warna_c} 1. Celsius (C)                                       ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${warna_f} 2. Fahrenheit (F)                                    ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${warna_r} 3. Reamur (R)                                        ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${warna_k} 4. Kelvin (K)                                        ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"

    if [[ "$bisa_kembali" == "ya" ]]; then
        printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "Ketik 'q' untuk kembali"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
    fi

    printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "5. Keluar"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
}

# ------------------------------------------------------------------------------
# Fungsi: gambar_kotak_input_nilai
# Fungsi untuk menggambar kotak untuk meminta input nilai suhu
# ------------------------------------------------------------------------------
gambar_kotak_input_nilai() {
    local unit_suhu="$1"

    gambar_header
    echo -e "${W_BIRU}┌─${W_CYAN} Masukkan Nilai ${W_BIRU}─────────────────────────────────────┐${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    printf "${W_BIRU}│${W_KUNING} %-52s ${W_BIRU}│${W_RESET}\n" "Unit : $unit_suhu"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN} Aturan Penulisan Angka:                              ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN}  - Gunakan titik/koma untuk nilai desimal.           ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN}  - Jangan gunakan tanda pemisah ribuan.              ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN}  - Contoh benar: 36.5 atau -10                       ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "Ketik 'q' untuk kembali"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
}

# ------------------------------------------------------------------------------
# Fungsi: gambar_kotak_hasil
# Fungsi untuk menggambar kotak hasil konversi
# ------------------------------------------------------------------------------
gambar_kotak_hasil() {
    local baris_atas="$1"
    local baris_bawah="$2"

    echo -e "${W_HIJAU}┌─ HASIL KONVERSI ─────────────────────────────────────┐${W_RESET}"
    echo -e "${W_HIJAU}│                                                      │${W_RESET}"
    
    # Jika hasil konversi terlalu panjang, dibagi menjadi 2 baris (atas dan bawah)
    if [[ "$baris_bawah" != "" ]]; then
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$baris_atas"
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$baris_bawah"
    else
        # Jika muat dalam 1 baris
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$baris_atas"
    fi

    echo -e "${W_HIJAU}│                                                      │${W_RESET}"
    echo -e "${W_HIJAU}└──────────────────────────────────────────────────────┘${W_RESET}"
    echo ""
}

# ------------------------------------------------------------------------------
# Fungsi: gambar_kotak_selanjutnya
# Fungsi untuk menggambar kotak menu pilihan selanjutnya
# ------------------------------------------------------------------------------
gambar_kotak_selanjutnya() {
    echo -e "${W_BIRU}┌─${W_KUNING} Selanjutnya ${W_BIRU}────────────────────────────────────────┐${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN} 1. Tukar unit (Swap)                                 ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN} 2. Konversi baru                                     ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "3. Keluar (Ketik '3' atau 'q')"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
}


# ==============================================================================
# FUNGSI KHUSUS MENGATUR LOGIKA ANTARMUKA
# ==============================================================================

# ------------------------------------------------------------------------------
# Fungsi: pilih_unit
# Meminta pengguna untuk memilih unit suhu asal atau tujuan
# ------------------------------------------------------------------------------
pilih_unit() {
    local judul="$1"
    local bisa_kembali="$2"
    local unit_asal="$3"
    local pesan_error=""

    while true; do
        # Gambar kotak unit suhu
        gambar_kotak_pilih_unit "$judul" "$unit_asal" "$bisa_kembali"

        # Tampilkan pesan jika ada error
        if [[ "$pesan_error" != "" ]]; then
            echo -e "    $pesan_error\n"
            pesan_error=""
        fi

        # Buat teks pertanyaan untuk user
        local teks_prompt="  ${W_TEBAL}» Pilihan (1-5): ${W_RESET}"
        if [[ "$bisa_kembali" == "ya" ]]; then
            teks_prompt="  ${W_TEBAL}» Pilihan (1-5/q): ${W_RESET}"
        fi
        echo -ne "$teks_prompt"

        # Ambil jawaban user
        if ! read jawaban; then exit 0; fi

        # Normalisasi: ubah huruf besar ke kecil & hapus spasi
        jawaban=$(echo "$jawaban" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n')

        # Cek apakah user ingin kembali
        if [[ "$bisa_kembali" == "ya" && "$jawaban" =~ ^(q|kembali|back|exit|keluar)$ ]]; then
            HASIL_KEMBALI="KEMBALI"
            return
        fi

        # Terjemahkan nomor pilihan ke nama unit
        local unit_terpilih=""
        case "$jawaban" in
            1) unit_terpilih="Celsius"    ;;
            2) unit_terpilih="Fahrenheit" ;;
            3) unit_terpilih="Reamur"     ;;
            4) unit_terpilih="Kelvin"     ;;
            5) echo -e "\n  ${W_CYAN}Selesai.${W_RESET}\n"; exit 0 ;;
            *) pesan_error="${W_MERAH}ERROR: Pilihan tidak valid.${W_RESET}"; continue ;;
        esac

        # Pastikan tidak memilih unit yang sama dengan unit asal
        if [[ "$unit_terpilih" == "$unit_asal" ]]; then
            pesan_error="${W_MERAH}ERROR: Tujuan tidak boleh sama dengan asal.${W_RESET}"
            continue
        fi

        echo -e "    ${W_HIJAU}> Terpilih: $unit_terpilih${W_RESET}\n"
        HASIL_KEMBALI="$unit_terpilih"
        return
    done
}


# ------------------------------------------------------------------------------
# Fungsi: input_nilai
# Meminta pengguna untuk memasukkan nilai suhu yang akan dikonversi
# ------------------------------------------------------------------------------
input_nilai() {
    local unit_suhu="$1"
    local pesan_error=""

    while true; do
        # Gambar kotak input nilai suhu
        gambar_kotak_input_nilai "$unit_suhu"

        # Tampilkan error jika ada
        if [[ "$pesan_error" != "" ]]; then
            echo -e "    $pesan_error\n"
            pesan_error=""
        fi
        echo -ne "  ${W_TEBAL}» Nilai: ${W_RESET}"

        # Baca jawaban user
        if ! read teks_input; then exit 0; fi
        teks_input=$(echo "$teks_input" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n')

        # Cek perintah kembali
        if [[ "$teks_input" =~ ^(q|kembali|back|exit|keluar)$ ]]; then
            HASIL_KEMBALI="KEMBALI"
            return
        fi

        # Ganti tanda koma (,) menjadi titik (.) agar dikenali mesin (sanitasi)
        local angka_bersih="${teks_input//,/.}"

        # Cek Format Angka (menggunakan regex)
        # ^[+-]?        -> boleh pakai plus/minus di awal
        # [0-9]+        -> harus ada angka
        # (\.[0-9]+)?   -> boleh ada titik desimal di akhir
        if [[ ! "$angka_bersih" =~ ^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$ ]]; then
            pesan_error="${W_MERAH}ERROR: Format salah! Ikuti aturan di atas.${W_RESET}"
            continue
        fi

        # Menggunakan Python untuk memvalidasi limit logika (sanitasi)
        local status_validasi
        status_validasi=$(python3 "$SCRIPT_PYTHON" validate "$angka_bersih" "$unit_suhu" 2>/dev/null)

        # Cek status validasi & tampilkan pesan error jika ada (sanitasi)
        if [[ "$status_validasi" == "InvalidFloat|" ]]; then
            pesan_error="${W_MERAH}ERROR: Input harus angka.${W_RESET}"; continue
        elif [[ "$status_validasi" == Error* ]]; then
            pesan_error="${W_MERAH}ERROR: $(echo "$status_validasi" | cut -d'|' -f2)${W_RESET}"; continue
        elif [[ "$status_validasi" == False* ]]; then
            pesan_error="${W_MERAH}ERROR: Di bawah 0 mutlak ($(echo "$status_validasi" | cut -d'|' -f2)).${W_RESET}"; continue
        fi

        # Menggunakan Python untuk merapikan angka agar enak dibaca (sanitasi)
        local nilai_diformat
        nilai_diformat=$(python3 "$SCRIPT_PYTHON" format "$angka_bersih" 2>/dev/null)

        # Tampilkan hasil input angka (sanitasi)
        echo -e "    ${W_HIJAU}> Diterima: $nilai_diformat $unit_suhu${W_RESET}\n"
        HASIL_KEMBALI="$angka_bersih"
        return
    done
}


# ------------------------------------------------------------------------------
# Fungsi: tampil_hasil
# Menampilkan hasil konversi di dalam kotak hasil
# ------------------------------------------------------------------------------
tampil_hasil() {
    local nilai_awal="$1"
    local unit_asal="$2"
    local hasil_konversi="$3"
    local unit_tujuan="$4"

    # Rapikan kedua angka menggunakan Python (sanitasi)
    local angka1
    local angka2
    angka1=$(python3 "$SCRIPT_PYTHON" format "$nilai_awal" 2>/dev/null)
    angka2=$(python3 "$SCRIPT_PYTHON" format "$hasil_konversi" 2>/dev/null)

    # Gabungkan menjadi satu kalimat pada tampilan
    local kalimat="$angka1 $unit_asal  =  $angka2 $unit_tujuan"

    # Jika kalimat terlalu panjang, pecah jadi 2 baris agar muat di kotak
    if (( ${#kalimat} > 52 )); then
        local teks1="$angka1 $unit_asal"
        local teks2="=  $angka2 $unit_tujuan"

        # Hitung jarak spasi agar tulisan berada di tengah
        local spasi1=$(( (52 - ${#teks1}) / 2 )); (( spasi1 < 0 )) && spasi1=0
        local spasi2=$(( (52 - ${#teks2}) / 2 )); (( spasi2 < 0 )) && spasi2=0
        
        local isi_spasi1=""; for ((i=0; i<spasi1; i++)); do isi_spasi1+=" "; done
        local isi_spasi2=""; for ((i=0; i<spasi2; i++)); do isi_spasi2+=" "; done
        
        # Kirim ke penggambar kotak hasil konversi (visual)
        gambar_kotak_hasil "${isi_spasi1}${teks1}" "${isi_spasi2}${teks2}"
    else
        # Jika muat di 1 baris, langsung tengahkan
        local spasi_tengah=$(( (52 - ${#kalimat}) / 2 )); (( spasi_tengah < 0 )) && spasi_tengah=0
        local isi_spasi=""; for ((i=0; i<spasi_tengah; i++)); do isi_spasi+=" "; done
        
        # Kirim ke penggambar visual (baris kedua dikosongkan)
        gambar_kotak_hasil "${isi_spasi}${kalimat}" ""
    fi
}


# ------------------------------------------------------------------------------
# Fungsi: tindakan_lanjut
# Meminta pengguna untuk memilih tindakan selanjutnya (tukar, baru, keluar)
# ------------------------------------------------------------------------------
tindakan_lanjut() {
    # Variabel untuk pesan error
    local pesan_error="$1"
    
    # Gambar kotak menu selanjutnya setelah konversi (visual)
    gambar_kotak_selanjutnya

    # Tampilkan error jika sebelumnya pilihan salah
    if [[ "$pesan_error" != "" ]]; then echo -e "    $pesan_error\n"; fi
    echo -ne "  ${W_TEBAL}» Pilihan (1/2/3/q): ${W_RESET}"

    # Baca jawaban user
    if ! read jawaban; then exit 0; fi
    jawaban=$(echo "$jawaban" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n')

    case "$jawaban" in
        1|tukar|swap)      HASIL_KEMBALI="tukar"   ;;
        2|baru)            HASIL_KEMBALI="baru"    ;;
        3|q|keluar|exit)   HASIL_KEMBALI="keluar"  ;;
        *)                 HASIL_KEMBALI="invalid" ;;
    esac
}
