#!/bin/bash
#-------------------------------------------------------------------------
#
# Script Bash sederhana untuk bikin sertifikat digital X.509 (self-signed)
# yang digunakan dalam simulasi serangan terhadap EAP-PEAP (PEAP-MSCHAPv2)
#
# For educational purposes only!
#
#-------------------------------------------------------------------------
# Dibuat oleh: Rofi (Fixploit03)

function banner(){
        echo ""
        echo "+--------------------------------------------------------------------------+"
        echo "|                                                                          |"
        echo "| Script Bash sederhana untuk bikin sertifikat digital X.509 (self-signed) |"
        echo "|                                                                          |"
        echo "+--------------------------------------------------------------------------+"
        echo ""
        echo "Daftar ukuran kunci RSA yang tersedia:"
        echo ""
        echo "[1] 1024"
        echo "[2] 2048"
        echo "[3] 3072"
        echo "[4] 4096"
        echo ""
}

function input_data_sertifikat(){
        # Input pilih ukuran kunci RSA
        while true; do
                read -p "[?] Pilih ukuran kunci RSA (default: 2048): " ukuran_kunci
                if [[ -z "${ukuran_kunci}" ]]; then
                        ukuran_kunci="2048"
                        break
                else
                        if [[ "${ukuran_kunci}" == "1" ]]; then
                                ukuran_kunci="1024"
                                break
                        elif [[ "${ukuran_kunci}" == "2" ]]; then
                                ukuran_kunci="2048"
                                break
                        elif [[ "${ukuran_kunci}" == "3" ]]; then
                                ukuran_kunci="3072"
                                break
                        elif [[ "${ukuran_kunci}" == "4" ]]; then
                                ukuran_kunci="4096"
                                break
                        else
                                echo "[-] Ukuran kunci '${ukuran_kunci}' tidak tersedia. Harap pilih antara '1/2/3/4'."
                                continue
                        fi
                fi
        done

        # Input nama file output untuk private key
        read -p "[?] Nama file output untuk private key (default: server.key): " private_key
        if [[ -z "${private_key}" ]]; then
                private_key="server.key"
        else
                private_key="${private_key}.key"
        fi

        # Input nama file output untuk public key
        read -p "[?] Nama file output untuk public key (default: server.pem): " public_key
        if [[ -z "${public_key}" ]]; then
                public_key="server.pem"
        else
                public_key="${public_key}.pem"
        fi
}

function input_data_subject(){
        # Input nama negara
        while true; do
                read -p "[?] Nama Negara (contoh: ID): " negara
                if [[ -z "${negara}" ]]; then
                        negara="ID"
                        break
                else
                        if [[ "${#negara}" -eq 2 ]]; then
                                break
                        else
                                echo "[-] Masukan harus berupa dua huruf kode negara."
                                continue
                        fi
                fi
        done

        # Input nama provinsi
        read -p "[?] Nama Provinsi (contoh: Jawa Barat): " provinsi
        if [[ -z "${provinsi}" ]]; then
                provinsi="Jawa Barat"
        fi

        # Input nama kota
        read -p "[?] Nama Kota (contoh: Bekasi): " kota
        if [[ -z "${kota}" ]]; then
                kota="Bekasi"
        fi

        # Input nama organisai
        read -p "[?] Nama Organisasi (contoh: PT Surya Makmur Abadi): " organisasi
        if [[ -z "${organisasi}" ]]; then
                organisasi="PT Surya Makmur Abadi"
        fi

        # Input nama unit organisai
        read -p "[?] Nama Unit Organisasi (contoh: Departemen IT PT Surya Makmur Abadi): " unit_organisasi
        if [[ -z "${unit_organisasi}" ]]; then
                unit_organisasi="Departemen IT PT Surya Makmur Abadi"
        fi

        # Input nama unum (CN)
        read -p "[?] Nama Umum (contoh: server FQDN): " cn
        if [[ -z "${cn}" ]]; then
                cn=$(hostname)
        fi

        # Input alamat E-mail
        while true; do
                read -p "[?] Alamat E-mail (contoh: admin@ptsuryamakmurabadi.co.id): " email
                if [[ -z "${email}" ]]; then
                        email="admin@ptsuryamakmurabadi.co.id"
                        break
                else
                        if [[ "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                                break
                        else
                                echo "[-] Format alamat E-mail tidak valid."
                                continue
                        fi
                fi
        done

        # Konfirmasi
        while true; do
                read -p "[?] Apakah semua data yang dimasukkan di atas sudah benar (Y/n): " konfirmasi

                if [[ "${konfirmasi}" == "y" || "${konfirmasi}" == "Y" ]]; then
                        subject="/C=${negara}/ST=${provinsi}/L=${kota}/O=${organisasi}/OU=${unit_organisasi}/CN=${cn}/emailAddress=${email}"
                        break
                elif [[ "${konfirmasi}" == "n" || "${konfirmasi}" == "N" ]]; then
                        input_data
                        break
                else
                        echo "[-] Masukkan tidak valid. Harap masukkan 'Y/n'."
                        continue
                fi
        done
}

function bikin_sertifikat(){
        # Lokasi direktori saat ini
        dir=$(pwd)

        # Bikin private key server
        echo "[*] Membuat private key server..."
        if openssl genrsa -out "${private_key}" "${ukuran_kunci}"; then
                echo "[+] Berhasil membuat private key server."
        else
                echo "[-] Gagal membuat private key server."
                exit 1
        fi

        # Bikin sertifikat server
        echo "[*] Membuat sertifikat server (Self-Signed)..."
        if openssl req -new -x509 -key "${private_key}" -out "${public_key}" -days 365 -subj "${subject}"; then
                echo "[+] Berhasil membuat sertifikat server (Self-Signed)."
        else
                echo "[-] Gagal membuat sertifikat server (Self-Signed)."
                exit 1
        fi

        # Hasil
        echo ""
        echo "[+] Private key server disimpan di: ${dir}/${private_key}"
        echo "[+] Sertifikat server (Self-Signed) disimpan di: ${dir}/${public_key}"
        exit 0
}

# Panggil semua fungsi
banner
input_data_sertifikat
input_data_subject
bikin_sertifikat
