import sys  # library bawaan Python untuk menerima argumen dari Bash

# ==============================================================================
# MESIN KALKULATOR SUHU
# file python ini bertugas menghitung konversi dan mengecek validitas angka.
# ==============================================================================

# Tabel rumus konversi suhu.
# Setiap unit memiliki dua rumus:
#   1. ke_celsius   : mengubah suhu awal menjadi Celsius (sebagai jembatan)
#   2. dari_celsius : mengubah suhu dari Celsius ke unit akhir
KONVERSI = {
    "Celsius":    {
        "ke_celsius":   lambda x: x,
        "dari_celsius": lambda x: x
    },
    "Fahrenheit": {
        "ke_celsius":   lambda x: (x - 32) * 5 / 9,
        "dari_celsius": lambda x: (x * 9 / 5) + 32
    },
    "Reamur":     {
        "ke_celsius":   lambda x: x * 5 / 4,
        "dari_celsius": lambda x: x * 4 / 5
    },
    "Kelvin":     {
        "ke_celsius":   lambda x: x - 273.15,
        "dari_celsius": lambda x: x + 273.15
    },
}

# Batas suhu terendah di alam semesta (nol mutlak).
# Suhu di bawah ini tidak mungkin ada secara hukum fisika.
BATAS_BAWAH = {
    "Celsius":    -273.15,
    "Fahrenheit": -459.67,
    "Reamur":     -218.52,
    "Kelvin":     0
}

def cek_suhu_valid(angka_suhu, nama_unit):
    if nama_unit not in BATAS_BAWAH:
        return "Error|Unit suhu tidak dikenal sistem."

    # Cek nilai apakah NaN atau infinity tidak pernah sama dengan dirinya sendiri
    if angka_suhu != angka_suhu or angka_suhu == float('inf') or angka_suhu == float('-inf'):
        return "Error|Angka tidak valid."

    if abs(angka_suhu) > 1000000000000000:
        return "Error|Angka terlalu besar (maks 1 Kuadriliun)."

    # Toleransi desimal (0.000000001)
    # ini untuk memastikan konversi aman dari pembulatan otomatis komputer
    batas = BATAS_BAWAH[nama_unit]
    if angka_suhu < (batas - 0.000000001):
        huruf_awal = nama_unit[0]
        # False berarti nilainya di bawah nol mutlak
        return "False|" + str(batas) + " " + huruf_awal

    return "True|"

if __name__ == "__main__":
    # Hanya jalan jika Bash mengirimkan data yang cukup
    if len(sys.argv) >= 3:
        perintah = sys.argv[1]
        teks_nilai = sys.argv[2]

        # Ubah teks menjadi angka desimal
        try:
            nilai_desimal = float(teks_nilai)
            angka_valid = True
        except ValueError:
            print("InvalidFloat|")
            sys.exit(1)

    # ----------------------------------------------------------------------
    # Perintah: validate (Mengecek apakah angka suhunya wajar)
    # ----------------------------------------------------------------------
        if perintah == "validate":
            unit = sys.argv[3]
            print(cek_suhu_valid(nilai_desimal, unit))

    # ----------------------------------------------------------------------
    # Perintah: format (Merapikan angka dengan 2 digit di belakang koma)
    # ----------------------------------------------------------------------
        elif perintah == "format":
            # Bulatkan ke 2 angka di belakang koma
            angka_bulat = round(nilai_desimal, 2)
    
            # Jika angka tidak punya nilai pecahan (misal 36.0), jadikan integer (36)
            if angka_bulat.is_integer():
                print(int(angka_bulat))
            else:
                print(angka_bulat)

    # ----------------------------------------------------------------------
    # Perintah: convert (Melakukan perhitungan konversi suhu)
    # ----------------------------------------------------------------------
        elif perintah == "convert":
            unit_asal = sys.argv[3]
            unit_tujuan = sys.argv[4]

            # Cek apakah unit yang dikirim dari Bash valid
            if unit_asal not in KONVERSI or unit_tujuan not in KONVERSI:
                print("Error|Unit konversi tidak valid.")
            else:
                # Cek validitas suhu awal sebelum konversi
                status_awal = cek_suhu_valid(nilai_desimal, unit_asal)
    
                if status_awal == "True|":
                    # Hitung dalam 2 langkah: Asal -> Celsius -> Tujuan
                    suhu_celsius = KONVERSI[unit_asal]["ke_celsius"](nilai_desimal)
                    suhu_akhir = KONVERSI[unit_tujuan]["dari_celsius"](suhu_celsius)
                    print(suhu_akhir)
                else:
                    print(status_awal)
