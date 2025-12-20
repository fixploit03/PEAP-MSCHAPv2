# PEAP-MSCHAPv2
Script Bash sederhana untuk melakukan simulasi serangan pada jaringan Wi-Fi WPA/WPA2-Enterprise (802.1X) yang menggunakan metode autentikasi EAP-PEAP (PEAP-MSCHAPv2).

> [!WARNING]
> ## Disclaimer
> Script ini dibuat hanya untuk tujuan edukasi, penelitian, dan pengujian keamanan (security testing). Penggunaan script ini hanya diperbolehkan pada jaringan yang Anda miliki atau jaringan yang telah memberikan izin tertulis secara resmi.
> 
> Segala bentuk penyalahgunaan, aktivitas ilegal, atau penggunaan tanpa izin yang melanggar hukum sepenuhnya menjadi tanggung jawab pengguna. Penulis tidak bertanggung jawab atas kerusakan sistem, kehilangan data, atau konsekuensi hukum yang timbul akibat penggunaan script ini.

## Persyaratan
- Sistem operasi Linux
- Hak akses root
- Dua buah adapter Wi-Fi
- Koneksi internet

> Untuk adapter Wi-Fi harus support mode monitor dan mode AP.

## Instalasi
```
sudo apt-get update
sudo apt-get install hostapd-wpe openssl git iw xterm aircrack-ng
git clone https://github.com/fixploit03/PEAP-MSCHAPv2.git
cd PEAP-MSCHAPv2/src
chmod +x *
```

## Cara Menggunakan
1. Bikin sertifikat palsu (self-signed):

   ```
   ./bikin-sertifikat.sh
   ```
1. Jalankan script utama:

   ```
   sudo ./run.sh
   ```
1. Crack hash NTLM:
   ```
   # Menggunakan John the Ripper
   john --format=netntlm-naive [file_hash]

   # Menggunakan Hashcat
   hashcat -a 0 -m 5500 [file_hash] [file_wordlist]
   ```

   Jika ingin menggunakan wordlist di John the Ripper, gunakan opsi `--wordlist=[file_wordlist]`.
1. Restore network:

   ```
   # Mengembalikan interface Rogue AP ke mode managed
   ip link set [interface_rogue] down
   iw dev [interface_rogue] set type managed
   ip link set [interface_rogue] up

   # Mengembalikan interface deauthentication ke mode managed
   ip link set [interface_deauth] down
   iw dev [interface_deauth] set type managed
   ip link set [interface_deauth] up

   # Merestart NetworkManager agar konfigurasi jaringan kembali normal
   systemctl restart NetworkManager
   ```

## Screenshot
![Gambar 1](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/proses.png)

<p align="center">[ Gambar 1 - Penangkapan challenge-response MSCHAPv2 ]</p>

![Gambar 2](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/hasil.png)

<p align="center">[ Gambar 2 - Hasil penangkapan challenge-response MSCHAPv2 ]</p>

![Gambar 3](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/crack%20hash%20(john).png)

<p align="center">[ Gambar 3 - Crack challenge-response MSCHAPv2 menggunakan John the Ripper ]</p>

![Gambar 4](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/crack%20hash%20(hashcat).png)

<p align="center">[ Gambar 4 - Crack challenge-response MSCHAPv2 menggunakan Hashcat ]</p>

## Lisensi

Proyek ini dirilis di bawah lisensi [MIT](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/LICENSE).

## Credits
- Hostapd-wpe - [https://github.com/OpenSecurityResearch/hostapd-wpe](https://github.com/OpenSecurityResearch/hostapd-wpe)
- OpenSSL - [https://www.openssl.org/](https://www.openssl.org/)
- Aircrack-NG - [https://www.aircrack-ng.org](https://www.aircrack-ng.org)
- John the Ripper - [https://www.openwall.com/john](https://www.openwall.com/john)
- Hashcat - [https://hashcat.net/hashcat/](https://hashcat.net/hashcat/)
- XTerm - [https://github.com/xterm-x11](https://github.com/xterm-x11)
- Fixploit03 - [https://github.com/fixploit03](https://github.com/fixploit03)

Dan semua orang yang mungkin menggunakan atau berkontribusi dalam bentuk apa pun. Terima kasih!
