import sys, math

# ==============================================================================
# ENGINE PYTHON: KALKULATOR SUHU
# ==============================================================================

# Rumus perhitungan untuk konversi suhu. Keterangan:
# k: mengubah suhu yang dipilih menjadi standar Celsius.
# d: mengubah standar Celsius menjadi suhu tujuan.
KONVERSI = {
    "Celsius":    {"k": lambda x: x,         "d": lambda x: x},
    "Fahrenheit": {"k": lambda x: (x-32)*5/9,"d": lambda x: (x*9/5)+32},
    "Reamur":     {"k": lambda x: x*5/4,     "d": lambda x: x*4/5},
    "Kelvin":     {"k": lambda x: x-273.15,  "d": lambda x: x+273.15}
}

# Nilai BATAS mewakili suhu nol mutlak, yaitu suhu teoritis terendah yang mungkin dicapai.
BATAS = {"Celsius": -273.15, "Fahrenheit": -459.67, "Reamur": -218.52, "Kelvin": 0} 

def validasi(n: float, u: str) -> str:
    # Memastikan tipe skala unit terdaftar di dalam sistem sebelum diproses
    if u not in BATAS: return "Error|Unit skala tidak dikenal." 
    
    # Mencegah program memproses nilai tak wajar (Not a Number) atau nilai tak terhingga (Infinity)
    if math.isnan(n) or math.isinf(n): return "Error|Angka tidak valid (NaN/Inf)." 
    
    # Membatasi rentang angka perhitungan untuk menghindari overflow tipe data desimal pada kalkulasi
    if abs(n) > 1e15: return "Error|Batas maksimal perhitungan 1 Kuadriliun." 
    
    # Memberikan toleransi epsilon 1e-9 pada kondisi pembulatan batas bawah (nol mutlak)
    # Ini sangat penting agar nilai konversi tidak dianggap cacat saat menukar unit (swap).
    if n < (BATAS[u] - 1e-9): return f"False|{BATAS[u]} {u[0]}" 
    
    return "True|" # Menandakan data aman untuk diproses lebih lanjut

if __name__ == "__main__":
    # Menghentikan eksekusi secara otomatis jika jumlah parameter tidak memadai
    if len(sys.argv) < 3: sys.exit() 
    perintah, args = sys.argv[1], sys.argv[2:]
    
    # Mengonversi dan menangkap input teks berbasis string menjadi bilangan tipe float
    try: nilai = float(args[0]) 
    except ValueError: sys.exit(print("InvalidFloat|")) # Memberi pesan kesalahan format dan keluar jika input gagal diparsing
    
    if perintah == "validate": 
        # Mengembalikan status aman atau tidaknya nilai suhu yang diinput
        print(validasi(nilai, args[1])) 
    
    elif perintah == "format":
        # Membulatkan nilai desimal ke presisi yang standar
        r = round(nilai, 2) 
        # Mengonversi format kembali menjadi integer (misal 36.0 -> 36) jika tidak ada pecahan bilangan
        print(int(r) if r.is_integer() else r) 
    
    elif perintah == "convert":
        asal, tujuan = args[1], args[2]
        
        # Perlindungan validasi tambahan saat melakukan penukaran maupun proses perhitungan inti
        if asal not in KONVERSI or tujuan not in KONVERSI:
            sys.exit(print("Error|Unit konversi tidak valid.")) 
            
        # Metode konversi ganda berantai:
        # Menjadikan Celsius sebagai skala penengah (base scale), kemudian menerjemahkannya ke skala akhir.
        status = validasi(nilai, asal)
        if status.startswith("True"): 
            print(KONVERSI[tujuan]["d"](KONVERSI[asal]["k"](nilai))) 
        else: 
            print(status)
