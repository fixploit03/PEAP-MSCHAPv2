# PEAP-MSCHAPv2
Script Bash sederhana untuk melakukan simulasi serangan pada jaringan Wi-Fi WPA/WPA2-Enterprise (802.1X) yang menggunakan metode autentikasi EAP-PEAP (PEAP-MSCHAPv2).

> [!WARNING]
> ## Disclaimer
> Script ini dibuat hanya untuk tujuan edukasi, penelitian, dan pengujian keamanan (security testing). Penggunaan script ini hanya diperbolehkan pada jaringan yang Anda miliki atau jaringan yang telah memberikan izin tertulis secara resmi.
> 
> Segala bentuk penyalahgunaan, aktivitas ilegal, atau penggunaan tanpa izin yang melanggar hukum sepenuhnya menjadi tanggung jawab pengguna. Penulis tidak bertanggung jawab atas kerusakan sistem, kehilangan data, atau konsekuensi hukum yang timbul akibat penggunaan script ini.

## Instalasi
```
sudo apt-get update
sudo apt-get install hostapd-wpe openssl git iw xterm mdk4 aircrack-ng
git clone https://github.com/fixploit03/PEAP-MSCHAPv2.git
cd PEAP-MSCHAPv2/src
chmod +x *
```

## Cara Menggunakan

1. Bikin sertifikat palsu Self-Signed:

   ```
   ./bikin-sertifikat.sh
   ```
2. Jalankan script utama:

   ```
   sudo ./run.sh
   ```
3. Restore network:

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

## Screeshot

![](https://github.com/fixploit03/PEAP-MSCHAPv2/blob/main/img/hasil.png)

Semoga bermanfaat ^_^
