# PEAP-MSCHAPv2
Script Bash sederhana yang dirancang untuk melakukan simulasi serangan pada jaringan Wi-Fi WPA/WPA2-Enterprise (802.1X) yang menggunakan metode autentikasi EAP-PEAP (PEAP-MSCHAPv2).

> [!WARNING]
> ## Disclaimer
> Script ini dibuat hanya untuk tujuan edukasi, penelitian, dan pengujian keamanan (security testing). Penggunaan script ini hanya diperbolehkan pada jaringan yang Anda miliki atau jaringan yang telah memberikan izin tertulis secara resmi.
> 
> Segala bentuk penyalahgunaan, aktivitas ilegal, atau penggunaan tanpa izin yang melanggar hukum sepenuhnya menjadi tanggung jawab pengguna. Penulis tidak bertanggung jawab atas kerusakan sistem, kehilangan data, atau konsekuensi hukum yang timbul akibat penggunaan script ini.

## 📋 Persyaratan
- Sistem operasi Linux
- Hak akses root
- Dua buah adapter Wi-Fi
- Koneksi internet

> Untuk adapter Wi-Fi harus support mode monitor dan mode AP.

## 🔧 Instalasi
```
sudo apt-get update
sudo apt-get install hostapd-wpe openssl git iw xterm aircrack-ng
git clone https://github.com/fixploit03/PEAP-MSCHAPv2.git
cd PEAP-MSCHAPv2/src
chmod +x *
```

## 📂 Struktur Proyek
```
PEAP-MSCHAPv2/
├── img/
│   ├── crack hash (hashcat).png
│   ├── crack hash (john).png
│   ├── evil twin.png
│   ├── hasil.png
│   └── proses.png
│
├── src/                    
│   ├── bikin-sertifikat.sh  
│   └── run.sh            
│
├── LICENSE
└── README.md
```

Fungsi script yang terdapat pada direktori `src/`:
- `bikin-sertifikat.sh`: Membuat sertifikat self-signed palsu yang nantinya digunakan oleh Rogue AP.
- `run.sh`: Menangkap username dan challenge‑response MSCHAPv2.

## 🏗️ Cara Kerja

![Gambar 1](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/evil%20twin.png)

<p align="center">[ Gambar 1 - Ilustrasi Evil Twin Attack ]</p>

1. Proses serangan dimulai saat penyerang menjalankan script `bikin-sertifikat.sh`. Script ini memanfaatkan `openssl` untuk menerbitkan sertifikat digital X.509 yang ditandatangani sendiri (self-signed), yang di dalamnya terdapat kunci privat dan publik dengan identitas organisasi palsu guna mengelabui target.
1. Selanjutnya, penyerang menjalankan script `run.sh` menggunakan sertifikat tersebut untuk membangun Rogue AP menggunakan `hostapd-wpe`, dengan meniru SSID serta konfigurasi jaringan Wi-Fi WPA/WPA2-Enterprise target. Tahap berikutnya adalah penyerang melancarkan serangan deauthentication menggunakan `aireplay-ng` untuk memutuskan koneksi klien dari AP yang sah, sehingga memaksa klien tersebut terhubung ke Rogue AP yang telah disiapkan oleh penyerang.
1. Jika klien melakukan autentikasi EAP-PEAP tanpa memverifikasi sertifikat server, maka kredensial autentikasi berupa username serta challenge-response MSCHAPv2 dapat disadap oleh penyerang. Data tersebut selanjutnya dapat di-crack secara offline menggunakan alat seperti `john` atau `hashcat` untuk mendapatkan kata sandi asli milik pengguna.

## 👨🏻‍💻 Cara Menggunakan

> [!NOTE]
> Script ini hanya berfungsi jika pengguna tidak melakukan validasi terhadap sertifikat server.

1. Buat sertifikat self-signed palsu:

   ```
   ./bikin-sertifikat.sh
   ```
1. Jalankan script utama:

   ```
   sudo ./run.sh
   ```
1. Crack challenge-response MSCHAPv2:
   ```
   # Menggunakan John the Ripper
   john --format=netntlm [file_hash]

   # Menggunakan Hashcat
   hashcat -a 0 -m 5500 [file_hash] [file_wordlist]
   ```

   Jika ingin menggunakan wordlist kustom di John the Ripper, gunakan opsi `--wordlist=[file_wordlist]`.
1. Restore network:

   ```
   # Mengembalikan interface Rogue AP ke mode managed
   sudo ip link set [interface_rogue] down
   sudo iw dev [interface_rogue] set type managed
   sudo ip link set [interface_rogue] up

   # Mengembalikan interface deauthentication ke mode managed
   sudo ip link set [interface_deauth] down
   sudo iw dev [interface_deauth] set type managed
   sudo ip link set [interface_deauth] up

   # Merestart NetworkManager agar konfigurasi jaringan kembali normal
   sudo systemctl restart NetworkManager
   ```

## 📸 Screenshot
![Gambar 2](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/proses.png)

<p align="center">[ Gambar 2 - Penangkapan username dan challenge-response MSCHAPv2 ]</p>

![Gambar 3](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/hasil.png)

<p align="center">[ Gambar 3 - Hasil penangkapan username dan challenge-response MSCHAPv2 ]</p>

![Gambar 4](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/crack%20hash%20(john).png)

<p align="center">[ Gambar 4 - Crack challenge-response MSCHAPv2 menggunakan John the Ripper ]</p>

![Gambar 5](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/crack%20hash%20(hashcat).png)

<p align="center">[ Gambar 5 - Crack challenge-response MSCHAPv2 menggunakan Hashcat ]</p>

## 🛡️ Mitigasi
- Aktifkan validasi sertifikat server pada perangkat klien dan pastikan hanya menerima sertifikat dari Certificate Authority (CA) terpercaya.
- Pertimbangkan menggunakan metode autentikasi yang lebih aman seperti EAP-TLS yang memerlukan sertifikat klien.
- Terapkan kebijakan password yang kuat (minimal 12 karakter, kompleks) untuk autentikasi.
- Implementasikan Wireless Intrusion Detection System (WIDS) untuk mendeteksi Rogue AP dan serangan deauthentication.

## 📜 Lisensi

Proyek ini dirilis di bawah lisensi [MIT](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/LICENSE).

## © Credits
- Hostapd-wpe - [https://github.com/OpenSecurityResearch/hostapd-wpe](https://github.com/OpenSecurityResearch/hostapd-wpe)
- OpenSSL - [https://www.openssl.org/](https://www.openssl.org/)
- Aircrack-NG - [https://www.aircrack-ng.org](https://www.aircrack-ng.org)
- John the Ripper - [https://www.openwall.com/john](https://www.openwall.com/john)
- Hashcat - [https://hashcat.net/hashcat/](https://hashcat.net/hashcat/)
- XTerm - [https://github.com/xterm-x11](https://github.com/xterm-x11)
- Fixploit03 - [https://github.com/fixploit03](https://github.com/fixploit03)

Dan semua orang yang mungkin menggunakan atau berkontribusi dalam bentuk apa pun. Terima kasih!
