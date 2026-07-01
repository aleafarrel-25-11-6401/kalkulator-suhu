#!/bin/bash
# ==============================================================================
# UI Kalkulator Suhu - Versi Paling Dasar & Stabil
# ==============================================================================

# Definisikan kode warna untuk mempercantik tata letak teks pada terminal
W_KUNING=$'\033[93m' W_BIRU=$'\033[94m' W_CYAN=$'\033[96m' 
W_HIJAU=$'\033[92m' W_MERAH=$'\033[91m' 
W_RESET=$'\033[0m' W_TEBAL=$'\033[1m'

# Menentukan lokasi direktori skrip python pemroses (berada sejajar dengan skrip bash ini)
PY_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kalkulator_suhu.py"

# Memastikan ketersediaan modul python3 sebelum menjalankan fungsionalitas inti
if ! command -v python3 &>/dev/null; then echo -e "${W_MERAH}ERROR: python3 tidak ditemukan.${W_RESET}"; exit 1; fi
if [ ! -f "$PY_SCRIPT" ]; then echo -e "${W_MERAH}ERROR: $PY_SCRIPT hilang.${W_RESET}"; exit 1; fi

# Menampung nilai balikan (return value) fungsi internal karena Bash tidak mendukung pengembalian nilai berbasis string
HASIL_KEMBALI="" 

tampil_tajuk() {
    clear # Membersihkan layar secara berkala untuk menjaga area kerja tetap rapi
    echo -e "${W_KUNING}${W_TEBAL}╔══════════════════════════════════════════════════════╗"
    echo -e "║               KALKULATOR KONVERSI SUHU               ║"
    echo -e "╚══════════════════════════════════════════════════════╝${W_RESET}\n"
}

pilih_unit() {
    local jdl="$1" b_kbl="$2" drng="$3" err=""
    while true; do
        tampil_tajuk
        
        # Menyesuaikan penulisan judul bingkai atas sesuai tahapan pengguna
        if [[ "$jdl" == "Pilih Unit ASAL" ]]; then
            echo -e "${W_BIRU}┌─${W_CYAN} Pilih Unit ASAL ${W_BIRU}────────────────────────────────────┐${W_RESET}"
        else
            echo -e "${W_BIRU}┌─${W_CYAN} Pilih Unit TUJUAN ${W_BIRU}──────────────────────────────────┐${W_RESET}"
        fi
        
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        
        # Menampilkan informasi unit dasar yang sebelumnya telah dipilih untuk memberikan kejelasan
        if [[ -n "$drng" ]]; then
            printf "${W_BIRU}│${W_KUNING} %-52s ${W_BIRU}│${W_RESET}\n" "- Unit Asal: $drng"
            echo -e "${W_BIRU}│                                                      │${W_RESET}"
        fi
        
        # Penyorotan opsi menu secara interaktif melalui variabel pewarnaan
        local c1="${W_CYAN}" c2="${W_CYAN}" c3="${W_CYAN}" c4="${W_CYAN}" 
        if [[ "$drng" == "Celsius" ]]; then c1="${W_MERAH}"; fi # Mengaplikasikan indikator visual peringatan jika opsi telah ditempati
        if [[ "$drng" == "Fahrenheit" ]]; then c2="${W_MERAH}"; fi
        if [[ "$drng" == "Reamur" ]]; then c3="${W_MERAH}"; fi
        if [[ "$drng" == "Kelvin" ]]; then c4="${W_MERAH}"; fi
        
        echo -e "${W_BIRU}│${c1} 1. Celsius (C)                                       ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${c2} 2. Fahrenheit (F)                                    ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${c3} 3. Reamur (R)                                        ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${c4} 4. Kelvin (K)                                        ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        
        # Menyediakan fitur mundur satu tahap navigasi jika parameter tombol kembali diizinkan
        if [[ "$b_kbl" == "ya" ]]; then
            printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "Ketik 'q' untuk kembali"
            echo -e "${W_BIRU}│                                                      │${W_RESET}"
        fi
        
        printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "5. Keluar"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
        
        # Menampilkan pemberitahuan error bila sesi sebelumnya meninggalkan riwayat pengecualian
        if [[ -n "$err" ]]; then echo -e "    $err\n"; err=""; fi 
        
        local prm="  ${W_TEBAL}» Pilihan (1-5): ${W_RESET}"
        if [[ "$b_kbl" == "ya" ]]; then prm="  ${W_TEBAL}» Pilihan (1-5/q): ${W_RESET}"; fi 
        echo -ne "$prm"
        
        # Menghindari perulangan tak terbatas yang diakibatkan oleh interupsi koneksi masukan (misal: EOF / Ctrl+D)
        if ! read pil; then exit 0; fi 
        
        # Membersihkan masukan teks dan menyeragamkannya menjadi satu ukuran standar (huruf kecil)
        pil=$(echo "$pil" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n') 
        
        if [[ "$b_kbl" == "ya" && "$pil" =~ ^(q|kembali|back|exit|keluar)$ ]]; then
            HASIL_KEMBALI="KEMBALI" # Menugaskan identitas kembali agar ditangkap oleh metode utama
            return
        fi
        
        local u=""
        case "$pil" in
            1) u="Celsius" ;; 2) u="Fahrenheit" ;; 3) u="Reamur" ;; 4) u="Kelvin" ;;
            5) echo -e "\n  ${W_CYAN}Selesai.${W_RESET}\n"; exit 0 ;; # Menjalankan prosedur pengakhiran saat diminta
            *) err="${W_MERAH}ERROR: Pilihan tidak valid.${W_RESET}"; continue ;; 
        esac
        
        if [[ "$u" == "$drng" ]]; then
            err="${W_MERAH}ERROR: Tujuan tidak boleh sama dengan asal.${W_RESET}" # Membatasi alur konversi antara titik ukur yang berulang
            continue
        fi
        
        echo -e "    ${W_HIJAU}> Terpilih: $u${W_RESET}\n"
        HASIL_KEMBALI="$u"
        return
    done
}

input_nilai() {
    local u="$1" err=""
    while true; do
        tampil_tajuk
        echo -e "${W_BIRU}┌─${W_CYAN} Masukkan Nilai ${W_BIRU}─────────────────────────────────────┐${W_RESET}"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        
        # Menonjolkan elemen teks dengan penegasan warna sebagai panduan antarmuka bagi pengguna
        printf "${W_BIRU}│${W_KUNING} %-52s ${W_BIRU}│${W_RESET}\n" "Unit : $u"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        
        # Menulis teks struktural ini secara manual menghindari isu rendering format karakter (UTF-8) di lingkungan sistem operasi tertentu
        echo -e "${W_BIRU}│${W_CYAN} Aturan Penulisan Angka:                              ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${W_CYAN}  • Gunakan titik/koma untuk nilai desimal.           ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${W_CYAN}  • Jangan gunakan tanda pemisah ribuan.              ${W_BIRU}│${W_RESET}"
        echo -e "${W_BIRU}│${W_CYAN}  • Contoh benar: 36.5 atau -10                       ${W_BIRU}│${W_RESET}"
        
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "Ketik 'q' untuk kembali"
        echo -e "${W_BIRU}│                                                      │${W_RESET}"
        echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
        
        if [[ -n "$err" ]]; then echo -e "    $err\n"; err=""; fi
        echo -ne "  ${W_TEBAL}» Nilai: ${W_RESET}"
        
        if ! read inp; then exit 0; fi # Mengendalikan pemutusan proses data tak terencana
        inp=$(echo "$inp" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n')
        
        if [[ "$inp" =~ ^(q|kembali|back|exit|keluar)$ ]]; then
            HASIL_KEMBALI="KEMBALI"
            return
        fi
        
        # Menerjemahkan sistem tanda baca lokal (koma) menjadi sistem tanda baca standar global (titik)
        local bsh="${inp//,/.}" 
        
        # ======================================================================
        # VERIFIKASI KEAMANAN STRING:
        # ^[+-]?     => Memperbolehkan keberadaan simbol plus dan minus opsional di awal
        # [0-9]+     => Harus memuat urutan karakter numerik dasar
        # (\.[0-9]+)?=> Mengizinkan formasi tambahan untuk desimal pecahan
        # |\.[0-9]+  => Mendukung langsung penulisan pecahan rasional
        # Memisahkan bilangan numerik nyata (real) dan menolak segala bentuk anomali sintaksis (misalnya huruf atau lokasi folder)
        # ======================================================================
        if [[ ! "$bsh" =~ ^[+-]?([0-9]+(\.[0-9]+)?|\.[0-9]+)$ ]]; then 
            err="${W_MERAH}ERROR: Format salah! Ikuti aturan penulisan angka di atas.${W_RESET}"
            continue
        fi

        # Mendelegasikan beban verifikasi matematis lanjutan kepada lingkungan yang lebih sesuai (Python)
        local val=$(python3 "$PY_SCRIPT" validate "$bsh" "$u" 2>/dev/null) 
        
        # Mengevaluasi instruksi kesalahan (exceptions) dari umpan balik python
        if [[ "$val" == "InvalidFloat|" ]]; then err="${W_MERAH}ERROR: Input harus angka.${W_RESET}"; continue
        elif [[ "$val" == Error* ]]; then err="${W_MERAH}ERROR: $(echo "$val" | cut -d'|' -f2)${W_RESET}"; continue 
        elif [[ "$val" == False* ]]; then err="${W_MERAH}ERROR: Di bawah 0 mutlak ($(echo "$val" | cut -d'|' -f2)).${W_RESET}"; continue; fi
        
        local fn=$(python3 "$PY_SCRIPT" format "$bsh" 2>/dev/null)
        echo -e "    ${W_HIJAU}> Diterima: $fn $u${W_RESET}\n"
        HASIL_KEMBALI="$bsh"
        return
    done
}

tampil_hasil() {
    local n=$1 a=$2 h=$3 t=$4
    local fn=$(python3 "$PY_SCRIPT" format "$n" 2>/dev/null)
    local fh=$(python3 "$PY_SCRIPT" format "$h" 2>/dev/null)
    
    # Mengakumulasikan gabungan seluruh data proses menjadi satu format laporan pelengkap
    local res="$fn $a  =  $fh $t" 
    
    if (( ${#res} > 52 )); then
        # Penyesuaian Ruang Teks: Mereduksi dampak kelebihan panjang karakter (overflow) dengan pembelahan dimensi baris
        local line1="$fn $a"
        local line2="=  $fh $t"
        
        local pad1=$(( (52 - ${#line1}) / 2 )); (( pad1 < 0 )) && pad1=0
        local pad1_str=""; for ((i=0; i<pad1; i++)); do pad1_str+=" "; done
        local l1="${pad1_str}${line1}"
        
        local pad2=$(( (52 - ${#line2}) / 2 )); (( pad2 < 0 )) && pad2=0
        local pad2_str=""; for ((i=0; i<pad2; i++)); do pad2_str+=" "; done
        local l2="${pad2_str}${line2}"
        
        echo -e "${W_HIJAU}┌─ HASIL KONVERSI ─────────────────────────────────────┐${W_RESET}"
        echo -e "${W_HIJAU}│                                                      │${W_RESET}"
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$l1"
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$l2"
        echo -e "${W_HIJAU}│                                                      │${W_RESET}"
        echo -e "${W_HIJAU}└──────────────────────────────────────────────────────┘${W_RESET}"
        echo ""
    else
        # Pemerataan Posisi Tengah: Memperkirakan ketersediaan sisi kiri/kanan matriks kotak secara proporsional
        local pad=$(( (52 - ${#res}) / 2 )) 
        if (( pad < 0 )); then pad=0; fi
        
        local pad_str=""
        for ((i=0; i<pad; i++)); do pad_str+=" "; done 
        
        # Mengeksekusi penempatan jeda teks melalui formasi variabel terpisah
        local line="${pad_str}${res}"
        
        # Penegasan area pembingkaian teks dilakukan untuk menonjolkan batas pembacaan visual bagi pengguna 
        echo -e "${W_HIJAU}┌─ HASIL KONVERSI ─────────────────────────────────────┐${W_RESET}"
        echo -e "${W_HIJAU}│                                                      │${W_RESET}"
        printf "${W_HIJAU}│${W_TEBAL}${W_CYAN} %-52s ${W_HIJAU}│${W_RESET}\n" "$line"
        echo -e "${W_HIJAU}│                                                      │${W_RESET}"
        echo -e "${W_HIJAU}└──────────────────────────────────────────────────────┘${W_RESET}"
        echo ""
    fi
}

tindakan_lanjut() {
    echo -e "${W_BIRU}┌─${W_KUNING} Selanjutnya ${W_BIRU}────────────────────────────────────────┐${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN} 1. Tukar unit (Swap)                                 ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│${W_CYAN} 2. Konversi baru                                     ${W_BIRU}│${W_RESET}"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    printf "${W_BIRU}│${W_MERAH} %-52s ${W_BIRU}│${W_RESET}\n" "3. Keluar (Ketik '3' atau 'q')"
    echo -e "${W_BIRU}│                                                      │${W_RESET}"
    echo -e "${W_BIRU}└──────────────────────────────────────────────────────┘${W_RESET}"
    
    if [[ -n "$1" ]]; then echo -e "    $1\n"; fi
    echo -ne "  ${W_TEBAL}» Pilihan (1/2/3/q): ${W_RESET}"
    
    if ! read p; then exit 0; fi
    p=$(echo "$p" | tr '[:upper:]' '[:lower:]' | tr -d ' \r\n')
    
    case "$p" in
        1|tukar|swap) HASIL_KEMBALI="tukar" ;; 
        2|baru) HASIL_KEMBALI="baru" ;;
        3|q|keluar|exit) HASIL_KEMBALI="keluar" ;; 
        *) HASIL_KEMBALI="invalid" ;;
    esac
}

jalankan() {
    # Perulangan Skema Induk: Berfungsi melestarikan rotasi prosedur sistem hingga pengguna mengakhiri eksekusi
    while true; do
        pilih_unit "Pilih Unit ASAL" "tidak" ""
        local a="$HASIL_KEMBALI"
        if [[ "$a" == "KEMBALI" || -z "$a" ]]; then continue; fi
        
        pilih_unit "Pilih Unit TUJUAN" "ya" "$a"
        local t="$HASIL_KEMBALI"
        if [[ "$t" == "KEMBALI" || -z "$t" ]]; then continue; fi
        
        input_nilai "$a"
        local n="$HASIL_KEMBALI"
        if [[ "$n" == "KEMBALI" || -z "$n" ]]; then continue; fi
        
        local swap="tidak" # Flag operasional guna memantau permohonan pembalikan arah konversi
        
        # Perulangan Eksekusi: Merancang peninjauan ulang perhitungan bila terdapat permohonan modifikasi pertukaran status parameter
        while true; do
            # Melimpahkan proses sinkronisasi parameter konversi ke modul eksternal demi meminimalisasi kompleksitas shell
            local h=$(python3 "$PY_SCRIPT" convert "$n" "$a" "$t" 2>/dev/null) 
            
            # Pengontrolan Eksepsi Kritis: Mendeteksi kesalahan struktural internal maupun kelainan memori komputasi
            if [[ -z "$h" || "$h" == Error* || "$h" == False* || "$h" == InvalidFloat* ]]; then 
                local e="Terjadi kesalahan tak terduga."
                if [[ "$h" == Error* ]]; then e=$(echo "$h" | cut -d'|' -f2); fi
                if [[ "$h" == False* ]]; then e="Suhu di bawah nol mutlak."; fi
                
                echo -e "  ${W_MERAH}ERROR: Sistem error: $e${W_RESET}\n  ${W_TEBAL}» Tekan Enter untuk lanjut...${W_RESET}"
                if ! read _; then exit 0; fi
                break
            fi
            
            local err=""
            while true; do
                tampil_tajuk
                if [[ "$swap" == "ya" ]]; then 
                    echo -e "  ${W_KUNING}> Unit ditukar: $a ➔  $t${W_RESET}\n" # Mentransmisikan pembaruan visual kepada pengguna
                fi
                
                tampil_hasil "$n" "$a" "$h" "$t"
                tindakan_lanjut "$err"
                local aksi="$HASIL_KEMBALI"
                
                if [[ "$aksi" != "invalid" ]]; then
                    swap="tidak" # Melakukan proses penetralan memori state sementara
                    break
                fi
                err="${W_MERAH}ERROR: Pilihan tidak valid.${W_RESET}"
            done
            
            if [[ "$aksi" == "keluar" ]]; then 
                echo -e "\n  ${W_CYAN}Terima kasih.${W_RESET}\n" # Menghentikan jalannya operasional aplikasi dengan pesan konklusi
                exit 0
            
            elif [[ "$aksi" == "tukar" ]]; then
                # Evaluasi ulang saat menukar skala; untuk menghindari pelanggaran limit terendah fisika yang berlaku pada skala spesifik yang baru
                local v=$(python3 "$PY_SCRIPT" validate "$n" "$t" 2>/dev/null) 
                if [[ "$v" == False* ]]; then
                    echo -e "    ${W_MERAH}ERROR: Angka di bawah nol mutlak skala $t.${W_RESET}\n  ${W_TEBAL}» Tekan Enter...${W_RESET}"
                    if ! read _; then exit 0; fi
                    continue
                fi
                # Melakukan mekanisme substitusi variabel secara timbal balik
                local tmp=$a; a=$t; t=$tmp; swap="ya" 
                
            elif [[ "$aksi" == "baru" ]]; then 
                break # Melompat ke tahap perulangan siklus paling awal
            fi
        done
    done
}

jalankan
