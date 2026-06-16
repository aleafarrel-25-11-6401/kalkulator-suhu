#!/usr/bin/env python3
"""!
@file kalkulator_suhu.py
@brief Aplikasi CLI Kalkulator Konversi Suhu.
@details Menyediakan fitur konversi suhu antar satuan Celsius, Fahrenheit, Reamur, dan Kelvin.
         Diperlengkapi dengan validasi input, pengecekan batas nol mutlak, dan fitur tukar unit.

@author Alea Farrel
@note NIM: 25.11.6401
"""

import sys
import os
import re
import math
from typing import Optional, Tuple

# --- Konstanta ---
CELSIUS = "Celsius"
FAHRENHEIT = "Fahrenheit"
REAMUR = "Reamur"
KELVIN = "Kelvin"

class WarnaTerminal:
    """!
    @brief Kode escape ANSI untuk pewarnaan teks di terminal.
    """
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def bersihkan_layar() -> None:
    """!
    @brief Membersihkan layar terminal.
    """
    os.system('cls' if os.name == 'nt' else 'clear')

def hapus_kode_ansi(teks: str) -> str:
    """!
    @brief Menghapus kode escape ANSI dari teks.
    @param teks String yang mengandung kode ANSI.
    @return String bersih tanpa kode ANSI.
    """
    escape_ansi = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return escape_ansi.sub('', teks)

def format_angka(angka: float, presisi: int = 3) -> str:
    """!
    @brief Memformat angka desimal agar rapi tanpa nol berlebih di belakang koma.
    @details Menghindari notasi ilmiah yang membingungkan, menambahkan pemisah ribuan, dan mengatasi hilangnya presisi (sig-fig bug) pada angka besar.
    @param angka Nilai float yang akan diformat.
    @param presisi Jumlah maksimal digit di belakang koma.
    @return String representasi angka yang rapi dan presisi.
    """
    if math.isnan(angka) or math.isinf(angka):
        return str(angka)
        
    angka_dibulatkan = round(angka, presisi)
    if angka_dibulatkan.is_integer():
        return f"{int(angka_dibulatkan):,}"
    else:
        return f"{angka_dibulatkan:,.{presisi}f}".rstrip('0').rstrip('.')

def cetak_kotak_ui(judul: str, baris_teks: list, warna: str, batas_lebar_minimal: int = 56) -> None:
    """!
    @brief Mencetak kotak antarmuka pengguna (UI) di terminal.
    @details Menghitung lebar dinamis berdasarkan teks terpanjang agar teks tidak keluar batas.
    @param judul Teks judul untuk bagian atas kotak.
    @param baris_teks Daftar string yang akan ditampilkan di dalam kotak.
    @param warna Kode warna ANSI untuk garis batas kotak.
    @param batas_lebar_minimal Lebar karakter minimal untuk kotak.
    """
    panjang_maksimal = max([len(hapus_kode_ansi(baris)) for baris in baris_teks] + [len(judul) + 2]) if baris_teks else len(judul) + 2
    lebar = max(batas_lebar_minimal, panjang_maksimal + 4)

    teks_judul = f" {judul} "
    jarak_atas = lebar - 3 - len(teks_judul)
    garis_atas = f"┌─{teks_judul}" + "─" * max(0, jarak_atas) + "┐"
    print(f"{warna}{garis_atas}{WarnaTerminal.ENDC}")
    
    # Menambahkan jarak vertikal atas (padding)
    print(f"{warna}│{' ' * (lebar - 2)}│{WarnaTerminal.ENDC}")
    
    for baris in baris_teks:
        baris_murni = hapus_kode_ansi(baris)
        jarak_isi = lebar - 4 - len(baris_murni)
        print(f"{warna}│{WarnaTerminal.ENDC} {baris}{' ' * max(0, jarak_isi)} {warna}│{WarnaTerminal.ENDC}")
        
    # Menambahkan jarak vertikal bawah (padding)
    print(f"{warna}│{' ' * (lebar - 2)}│{WarnaTerminal.ENDC}")
        
    garis_bawah = "└" + "─" * (lebar - 2) + "┘"
    print(f"{warna}{garis_bawah}{WarnaTerminal.ENDC}")

def konversi_ke_celsius(nilai: float, unit_asal: str) -> float:
    """!
    @brief Mengonversi suhu dari unit asal menjadi Celsius.
    @param nilai Nilai suhu yang akan dikonversi.
    @param unit_asal Unit suhu asli (asal).
    @return Hasil nilai suhu dalam skala Celsius.
    @exception ValueError Jika unit_asal tidak dikenali.
    """
    if unit_asal == CELSIUS:
        return nilai
    elif unit_asal == FAHRENHEIT:
        return (nilai - 32.0) * 5.0 / 9.0
    elif unit_asal == REAMUR:
        return nilai * 5.0 / 4.0
    elif unit_asal == KELVIN:
        return nilai - 273.15
    else:
        raise ValueError("Unit suhu asal tidak dikenali.")

def konversi_dari_celsius(nilai_celsius: float, unit_tujuan: str) -> float:
    """!
    @brief Mengonversi suhu dari skala Celsius ke unit yang dituju.
    @param nilai_celsius Nilai suhu dalam skala Celsius.
    @param unit_tujuan Unit suhu yang diinginkan (tujuan).
    @return Hasil nilai suhu dalam unit yang dituju.
    @exception ValueError Jika unit_tujuan tidak dikenali.
    """
    if unit_tujuan == CELSIUS:
        return nilai_celsius
    elif unit_tujuan == FAHRENHEIT:
        return (nilai_celsius * 9.0 / 5.0) + 32.0
    elif unit_tujuan == REAMUR:
        return nilai_celsius * 4.0 / 5.0
    elif unit_tujuan == KELVIN:
        return nilai_celsius + 273.15
    else:
        raise ValueError("Unit suhu tujuan tidak dikenali.")

def hitung_konversi(nilai: float, unit_asal: str, unit_tujuan: str) -> float:
    """!
    @brief Melakukan perhitungan konversi antara dua unit suhu secara penuh.
    @param nilai Nilai suhu awal.
    @param unit_asal Satuan suhu awal.
    @param unit_tujuan Satuan suhu yang ingin dicapai.
    @return Hasil perhitungan suhu dalam unit tujuan.
    """
    nilai_celsius = konversi_ke_celsius(nilai, unit_asal)
    return konversi_dari_celsius(nilai_celsius, unit_tujuan)

def tampilkan_tajuk() -> None:
    """!
    @brief Menampilkan tajuk (header) utama dari aplikasi.
    """
    print(f"{WarnaTerminal.OKCYAN}{WarnaTerminal.BOLD}╔══════════════════════════════════════════════════════╗{WarnaTerminal.ENDC}")
    print(f"{WarnaTerminal.OKCYAN}{WarnaTerminal.BOLD}║               KALKULATOR KONVERSI SUHU               ║{WarnaTerminal.ENDC}")
    print(f"{WarnaTerminal.OKCYAN}{WarnaTerminal.BOLD}╚══════════════════════════════════════════════════════╝{WarnaTerminal.ENDC}")
    print()

def validasi_nol_mutlak(nilai: float, unit: str) -> Tuple[bool, str]:
    """!
    @brief Memvalidasi nilai suhu agar tidak berada di bawah titik nol mutlak sesuai hukum fisika.
    @param nilai Angka suhu.
    @param unit Satuan suhu.
    @return Tuple (bool validitas, string batas minimum).
    """
    if unit == CELSIUS and nilai < -273.15:
        return False, "-273.15 °C"
    elif unit == FAHRENHEIT and nilai < -459.67:
        return False, "-459.67 °F"
    elif unit == REAMUR and nilai < -218.52:
        return False, "-218.52 °R"
    elif unit == KELVIN and nilai < 0:
        return False, "0 K"
    return True, ""

def minta_pilihan_unit(judul_permintaan: str, bisa_kembali: bool = False, unit_dilarang: Optional[str] = None) -> Optional[str]:
    """!
    @brief Meminta pengguna untuk memilih satuan suhu dari menu.
    @details Terus mengulang hingga pengguna memberikan angka yang valid (1-5). Menyediakan opsi keluar langsung dan kembali.
             Layar akan dibersihkan tiap iterasi agar terminal tidak kotor.
             Menampilkan unit asal yang telah dipilih jika parameter unit_dilarang disertakan.
    @param judul_permintaan Teks yang ditampilkan sebagai petunjuk pemilihan.
    @param bisa_kembali Boolean yang menentukan apakah ada opsi untuk kembali ke awal.
    @param unit_dilarang Nama unit yang tidak boleh dipilih (untuk mencegah unit asal dan tujuan sama).
    @return Nama unit suhu yang dipilih, atau None jika mundur.
    """
    daftar_unit = {
        "1": CELSIUS,
        "2": FAHRENHEIT,
        "3": REAMUR,
        "4": KELVIN,
        "5": "KELUAR"
    }
    
    opsi = []
    if unit_dilarang:
        opsi.append(f"{WarnaTerminal.OKCYAN}✦ Unit Asal yang dipilih: {WarnaTerminal.BOLD}{unit_dilarang}{WarnaTerminal.ENDC}")
        opsi.append("")
        
    opsi.extend([
        "1. Celsius (C)",
        "2. Fahrenheit (F)",
        "3. Reamur (R)",
        "4. Kelvin (K)",
        ""
    ])
    
    if bisa_kembali:
        opsi.append(f"{WarnaTerminal.WARNING}Kembali   : Ketik 'q' untuk pilih ulang suhu asal{WarnaTerminal.ENDC}")
        opsi.append("")
        
    opsi.append(f"{WarnaTerminal.FAIL}5. Keluar dari Aplikasi{WarnaTerminal.ENDC}")
    
    teks_input = f"  {WarnaTerminal.BOLD}▶ Pilihan Anda (1-5/q): {WarnaTerminal.ENDC}" if bisa_kembali else f"  {WarnaTerminal.BOLD}▶ Pilihan Anda (1-5): {WarnaTerminal.ENDC}"
    
    pesan_error = ""
    while True:
        bersihkan_layar()
        tampilkan_tajuk()
        cetak_kotak_ui(judul_permintaan, opsi, WarnaTerminal.OKBLUE)
        
        if pesan_error:
            print(f"    {pesan_error}\n")
            pesan_error = ""
            
        pilihan = input(teks_input).strip().lower()
        
        if bisa_kembali and pilihan in ['q', 'kembali', 'menu', 'back']:
            return None
        
        if pilihan in daftar_unit:
            if pilihan == "5":
                print(f"\n  {WarnaTerminal.OKCYAN}Program selesai. Terima kasih.{WarnaTerminal.ENDC}\n")
                sys.exit(0)
                
            unit_terpilih = daftar_unit[pilihan]
            if unit_dilarang and unit_terpilih == unit_dilarang:
                pesan_error = f"{WarnaTerminal.FAIL}❌ Unit tujuan tidak boleh sama dengan unit asal ({unit_dilarang}). Silakan pilih unit yang berbeda.{WarnaTerminal.ENDC}"
                continue
                
            print(f"    {WarnaTerminal.OKGREEN}✓ Terpilih: {unit_terpilih}{WarnaTerminal.ENDC}\n")
            return unit_terpilih
        else:
            pesan_error = f"{WarnaTerminal.FAIL}❌ Pilihan tidak valid. Silakan coba lagi.{WarnaTerminal.ENDC}"

def minta_nilai_suhu(unit: str) -> Optional[float]:
    """!
    @brief Meminta pengguna memasukkan nilai suhu dalam bentuk angka desimal.
    @details Memverifikasi input agar di atas nilai nol mutlak sesuai dengan hukum fisika, mendeteksi perintah kembali ke menu, dan membatasi input suhu ekstrem.
             Mendukung koma atau titik sebagai desimal untuk melayani konvensi lokal, serta anti penumpukan terminal UI.
    @param unit Satuan suhu tempat angka tersebut dimasukkan.
    @return Nilai suhu dalam format desimal (float), atau None jika pengguna ingin kembali ke menu.
    """
    baris_teks = [
        f"Unit suhu : {unit}",
        "Format    : Desimal bisa pakai titik atau koma (cth: 36.5 / 36,5)",
        "            Mohon JANGAN gunakan pemisah ribuan.",
        "",
        f"{WarnaTerminal.FAIL}Kembali   : Ketik 'q' atau 'kembali'{WarnaTerminal.ENDC}"
    ]
    
    pesan_error = ""
    while True:
        bersihkan_layar()
        tampilkan_tajuk()
        cetak_kotak_ui("Masukkan Nilai Suhu", baris_teks, WarnaTerminal.OKBLUE)
        
        if pesan_error:
            print(f"    {pesan_error}\n")
            pesan_error = ""
            
        input_pengguna = input(f"  {WarnaTerminal.BOLD}▶ Nilai: {WarnaTerminal.ENDC}").strip().lower()
        
        if input_pengguna in ['q', 'kembali', 'menu', 'back']:
            return None
            
        # Perbaikan UX: Mengubah koma menjadi titik untuk mengakomodasi format desimal lokal
        input_bersih = input_pengguna.replace(',', '.')
            
        try:
            nilai = float(input_bersih)
            
            if math.isnan(nilai) or math.isinf(nilai):
                pesan_error = f"{WarnaTerminal.FAIL}❌ Input tidak valid. Harap masukkan angka yang wajar.{WarnaTerminal.ENDC}"
                continue
                
            if abs(nilai) > 1e15:
                pesan_error = f"{WarnaTerminal.FAIL}❌ Suhu terlalu ekstrem. Batas maksimum kalkulasi adalah 1 Kuadriliun derajat.{WarnaTerminal.ENDC}"
                continue
            
            # Validasi fisika
            valid, batas_min = validasi_nol_mutlak(nilai, unit)
            if not valid:
                pesan_error = f"{WarnaTerminal.FAIL}❌ Suhu tidak boleh kurang dari nol mutlak ({batas_min}).{WarnaTerminal.ENDC}"
                continue

            print(f"    {WarnaTerminal.OKGREEN}✓ Nilai diterima: {format_angka(nilai)} {unit}{WarnaTerminal.ENDC}\n")
            return nilai
        except ValueError:
            pesan_error = f"{WarnaTerminal.FAIL}❌ Input tidak valid. Pastikan hanya memasukkan angka (contoh: -10 atau 36.5).{WarnaTerminal.ENDC}"

def tampilkan_hasil(nilai: float, unit_asal: str, hasil: float, unit_tujuan: str) -> None:
    """!
    @brief Merender dan menampilkan hasil perhitungan konversi ke layar.
    @param nilai Angka suhu awal yang diinput pengguna.
    @param unit_asal Satuan suhu awal.
    @param hasil Angka hasil perhitungan konversi.
    @param unit_tujuan Satuan suhu akhir yang dituju.
    """
    teks_hasil = f"{format_angka(nilai)} {unit_asal}  =  {format_angka(hasil)} {unit_tujuan}"
    
    baris_teks = [
        f"{WarnaTerminal.BOLD}{WarnaTerminal.OKCYAN}{teks_hasil.center(52)}{WarnaTerminal.ENDC}"
    ]
    cetak_kotak_ui("HASIL KONVERSI", baris_teks, WarnaTerminal.OKGREEN)
    print()

def minta_tindakan_lanjutan(pesan_error: str = "") -> str:
    """!
    @brief Meminta instruksi selanjutnya dari pengguna setelah konversi selesai.
    @param pesan_error Teks error jika input sebelumnya tidak valid.
    @return String yang mendefinisikan tindakan selanjutnya ('tukar', 'baru', 'keluar').
    """
    opsi = [
        "1. Tukar unit (Swap) dan hitung ulang",
        "2. Konversi baru",
        "",
        f"{WarnaTerminal.FAIL}3. Keluar (Ketik '3' atau 'q'){WarnaTerminal.ENDC}"
    ]
    cetak_kotak_ui("Tindakan Selanjutnya", opsi, WarnaTerminal.HEADER)
    
    if pesan_error:
        print(f"    {pesan_error}\n")
        
    pilihan = input(f"  {WarnaTerminal.BOLD}▶ Pilihan Anda (1/2/3/q): {WarnaTerminal.ENDC}").strip().lower()
    
    if pilihan in ["1", "tukar", "swap"]:
        return "tukar"
    elif pilihan in ["2", "baru"]:
        return "baru"
    elif pilihan in ["3", "q", "keluar", "quit", "exit"]:
        return "keluar"
    else:
        return "invalid"

def jalankan_aplikasi() -> None:
    """!
    @brief Mengatur dan menjalankan seluruh alur utama aplikasi kalkulator.
    @details Mengkoordinasikan siklus mulai dari meminta unit hingga menampilkan hasil dan mereset ulang kondisi (state).
    """
    while True:
        unit_asal = minta_pilihan_unit("Pilih Unit Suhu ASAL")
        unit_tujuan = minta_pilihan_unit("Pilih Unit Suhu TUJUAN", bisa_kembali=True, unit_dilarang=unit_asal)
        
        if unit_tujuan is None:
            continue
            
        nilai = minta_nilai_suhu(unit_asal)
        
        if nilai is None:
            continue

        baru_ditukar = False

        while True:
            try:
                hasil = hitung_konversi(nilai, unit_asal, unit_tujuan)
                
                pesan_error_tindakan = ""
                # Loop untuk menangani validasi input tindakan lanjutan
                while True:
                    bersihkan_layar()
                    tampilkan_tajuk()
                    
                    if baru_ditukar:
                        print(f"  {WarnaTerminal.WARNING}✦ Unit telah ditukar: {unit_asal} ➔  {unit_tujuan}{WarnaTerminal.ENDC}\n")
                        
                    tampilkan_hasil(nilai, unit_asal, hasil, unit_tujuan)
                    
                    tindakan = minta_tindakan_lanjutan(pesan_error_tindakan)
                    
                    if tindakan != "invalid":
                        baru_ditukar = False # Reset flag peringatan swap
                        break
                    else:
                        pesan_error_tindakan = f"{WarnaTerminal.FAIL}❌ Pilihan tidak valid. Silakan ketik 1, 2, 3, atau q.{WarnaTerminal.ENDC}"
                        
            except Exception as e:
                print(f"  {WarnaTerminal.FAIL}❌ Terjadi kesalahan sistem: {e}{WarnaTerminal.ENDC}\n")
                input(f"  {WarnaTerminal.BOLD}▶ Tekan Enter untuk kembali ke menu utama...{WarnaTerminal.ENDC}")
                break

            if tindakan == "keluar":
                print(f"\n  {WarnaTerminal.OKCYAN}Program selesai. Terima kasih.{WarnaTerminal.ENDC}\n")
                return
            elif tindakan == "tukar":
                # Proteksi Bug Nol Mutlak: Validasi sebelum menukar
                valid, batas = validasi_nol_mutlak(nilai, unit_tujuan)
                if not valid:
                    # Jika tidak valid, tahan layar sejenak untuk peringatan
                    print(f"    {WarnaTerminal.FAIL}❌ PENOLAKAN SISTEM: Nilai {nilai} dilarang untuk skala {unit_tujuan}{WarnaTerminal.ENDC}")
                    print(f"    {WarnaTerminal.FAIL}   (Suhu tidak boleh kurang dari nol mutlak {batas}).{WarnaTerminal.ENDC}\n")
                    input(f"  {WarnaTerminal.BOLD}▶ Tekan Enter untuk mengulang...{WarnaTerminal.ENDC}")
                    # Kembali ke awal kalkulasi ulang tanpa menukar unit
                    continue
                
                # Pertukaran unit dilakukan jika lolos validasi fisika
                unit_asal, unit_tujuan = unit_tujuan, unit_asal
                baru_ditukar = True
            elif tindakan == "baru":
                break

def utama() -> None:
    """!
    @brief Titik masuk (entry point) eksekusi kode python.
    @details Membungkus aplikasi utama agar tahan terhadap interupsi (seperti Ctrl+C).
    """
    try:
        jalankan_aplikasi()
    except KeyboardInterrupt:
        print(f"\n\n  {WarnaTerminal.WARNING}Program dihentikan secara manual. Program selesai.{WarnaTerminal.ENDC}\n")
        sys.exit(0)

if __name__ == "__main__":
    utama()
