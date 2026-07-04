#!/bin/bash

# Lokasi skrip Python yang menangani semua perhitungan
SCRIPT_PYTHON="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/25.11.6401_kalkulator-suhu.py"

# Lokasi skrip yang khusus menangani tampilan interface (visual)
VISUAL_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/visual/ui.sh"

# ------------------------------------------------------------------------------
# Pastikan Python dan Script Lainnya Tersedia sebelum melanjutkan
# ------------------------------------------------------------------------------
if ! command -v python3 &>/dev/null; then
    echo -e "\033[91mERROR: python3 tidak ditemukan.\033[0m"
    exit 1
fi
if [ ! -f "$SCRIPT_PYTHON" ]; then
    echo -e "\033[91mERROR: File $SCRIPT_PYTHON tidak ditemukan.\033[0m"
    exit 1
fi
if [ ! -f "$VISUAL_SCRIPT" ]; then
    echo -e "\033[91mERROR: File UI $VISUAL_SCRIPT tidak ditemukan.\033[0m"
    exit 1
fi

# Variabel global untuk menampung nilai dari fungsi UI (karena bash tidak punya return string)
HASIL_KEMBALI=""

# Muat fungsi-fungsi tampilan UI (memasukkan warna dan fungsi seperti pilih_unit, dll)
source "$VISUAL_SCRIPT"


# ==============================================================================
# Fungsi: jalankan
# Merupakan fungsi utama yang mengatur alur program secara keseluruhan.
# ==============================================================================
jalankan() {
    while true; do

        # ----------------------------------------------------------------------
        # Input Suhu Asal : Memilih satuan unit asal (memanggil fungsi dari ui.sh)
        # ----------------------------------------------------------------------
        pilih_unit "Pilih Unit ASAL" "tidak" ""
        local unit_asal="$HASIL_KEMBALI"
        if [[ "$unit_asal" == "KEMBALI" || -z "$unit_asal" ]]; then continue; fi

        # ----------------------------------------------------------------------
        # Input Suhu Tujuan : Memilih satuan unit tujuan (tidak boleh sama dengan asal)
        # ----------------------------------------------------------------------
        pilih_unit "Pilih Unit TUJUAN" "ya" "$unit_asal"
        local unit_tujuan="$HASIL_KEMBALI"
        if [[ "$unit_tujuan" == "KEMBALI" || -z "$unit_tujuan" ]]; then continue; fi

        # ----------------------------------------------------------------------
        # Input Nilai Suhu : Meminta nilai suhu yang ingin dikonversi
        # ----------------------------------------------------------------------
        input_nilai "$unit_asal"
        local nilai_input="$HASIL_KEMBALI"
        if [[ "$nilai_input" == "KEMBALI" || -z "$nilai_input" ]]; then continue; fi

        # ----------------------------------------------------------------------
        # Penanda apakah unit baru saja ditukar (untuk menampilkan notifikasi)
        # ----------------------------------------------------------------------
        local status_tukar="tidak"

        # ----------------------------------------------------------------------
        # Loop dalam: menampilkan hasil dan menunggu aksi lanjutan
        # ----------------------------------------------------------------------
        while true; do

            # Kirim permintaan konversi ke skrip Python
            local hasil_python
            hasil_python=$(python3 "$SCRIPT_PYTHON" convert "$nilai_input" "$unit_asal" "$unit_tujuan" 2>/dev/null)

            # Tampilkan error jika terjadi kesalahan dari skrip Python
            if [[ -z "$hasil_python" || "$hasil_python" == Error* || "$hasil_python" == False* || "$hasil_python" == InvalidFloat* ]]; then
                local pesan_error="Terjadi kesalahan tak terduga."
                # Jika Error adalah pesan kesalahan umum dari Python
                if [[ "$hasil_python" == Error* ]]; then
                    pesan_error=$(echo "$hasil_python" | cut -d'|' -f2)
                fi
                # Jika False adalah kesalahan suhu di bawah nol mutlak
                if [[ "$hasil_python" == False* ]]; then
                    pesan_error="Suhu di bawah nol mutlak."
                fi
                # Jika InvalidFloat adalah kesalahan format angka
                if [[ "$hasil_python" == InvalidFloat* ]]; then
                    pesan_error="Format angka tidak valid."
                fi

                echo -e "  ${W_MERAH}ERROR: Sistem error: $pesan_error${W_RESET}\n  ${W_TEBAL}» Tekan Enter untuk lanjut...${W_RESET}"
                if ! read _; then exit 0; fi
                break
            fi

            # ----------------------------------------------------------------------
            # Loop tampil hasil: akan terus berulang jika pilihan aksi tidak valid
            # ----------------------------------------------------------------------
            local input_error=""
            while true; do
                gambar_header # Tampilkan judul program

                # Tampilkan notifikasi jika satuan unit baru saja ditukar
                if [[ "$status_tukar" == "ya" ]]; then
                    echo -e "  ${W_KUNING}> Unit ditukar: $unit_asal ➔  $unit_tujuan${W_RESET}\n"
                fi

                # Tampilkan hasil konversi
                tampil_hasil "$nilai_input" "$unit_asal" "$hasil_python" "$unit_tujuan"
                
                # Tampilkan menu selanjutnya
                tindakan_lanjut "$input_error" # Tampilkan pilihan selanjutnya (tukar, baru, keluar)
                local aksi_lanjut="$HASIL_KEMBALI" # Simpan pilihan

                # Keluar dari perulangan tampil jika pilihan valid
                if [[ "$aksi_lanjut" != "invalid" ]]; then
                    status_tukar="tidak" # Reset status tukar
                    break
                fi

                input_error="${W_MERAH}ERROR: Pilihan tidak valid.${W_RESET}" # Tampilkan pesan error
            done

            # ----------------------------------------------------------------------
            # Proses aksi yang dipilih pengguna
            # ----------------------------------------------------------------------
            if [[ "$aksi_lanjut" == "keluar" ]]; then
                echo -e "\n  ${W_CYAN}Terima kasih.${W_RESET}\n" # Tampilkan pesan terima kasih
                exit 0 # Keluar dari program

            # ----------------------------------------------------------------------
            # Proses aksi tukar: menukar posisi unit asal dan tujuan
            # ----------------------------------------------------------------------
            elif [[ "$aksi_lanjut" == "tukar" ]]; then
                # Sebelum menukar, pastikan nilai masih valid di skala tujuan (tidak di bawah nol mutlak)
                local cek_validasi
                cek_validasi=$(python3 "$SCRIPT_PYTHON" validate "$nilai_input" "$unit_tujuan" 2>/dev/null)
                if [[ "$cek_validasi" == False* ]]; then
                    echo -e "    ${W_MERAH}ERROR: Angka di bawah nol mutlak skala $unit_tujuan.${W_RESET}\n  ${W_TEBAL}» Tekan Enter...${W_RESET}"
                    if ! read _; then exit 0; fi
                    continue
                fi

                # --------------------------------------------------------------
                # Proses tukar posisi unit asal dan tujuan
                # --------------------------------------------------------------
                local temp_unit="$unit_asal"
                unit_asal="$unit_tujuan"
                unit_tujuan="$temp_unit"
                status_tukar="ya" # Atur status tukar menjadi ya untuk menampilkan notifikasi

            # ----------------------------------------------------------------------
            # Proses aksi baru: kembali ke awal (pilih unit asal baru)
            # ----------------------------------------------------------------------
            elif [[ "$aksi_lanjut" == "baru" ]]; then
                break  # Kembali ke awal (pilih unit asal baru)
            fi

        done
    done
}

# Mulai program
jalankan