#!/bin/bash

# =============================================
# Sistem Manajemen Perpustakaan Sederhana
# File: app.sh
# Penulis: Assistant AI
# Deskripsi: Aplikasi bash untuk mengelola koleksi buku perpustakaan
# =============================================

# Variabel global
declare -a books
data_file="library.txt"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================
# Fungsi-fungsi utama
# =============================================

# Function 1: Memuat data dari file
load_data() {
    if [ -f "$data_file" ]; then
        readarray -t books < "$data_file"
        echo -e "${GREEN}Data berhasil dimuat.${NC}"
    else
        echo -e "${YELLOW}File data tidak ditemukan. Membuat yang baru.${NC}"
        touch "$data_file"
    fi
}

# Function 2: Menyimpan data ke file
save_data() {
    printf "%s\n" "${books[@]}" > "$data_file"
    echo -e "${GREEN}Data berhasil disimpan.${NC}"
}

# Function 3: Menampilkan menu utama
show_menu() {
    echo -e "\n${BLUE}=== SISTEM MANAJEMEN PERPUSTAKAAN ===${NC}"
    echo -e "1. Tambah Buku"
    echo -e "2. Lihat Semua Buku"
    echo -e "3. Cari Buku"
    echo -e "4. Hapus Buku"
    echo -e "5. Statistik Perpustakaan"
    echo -e "6. Keluar"
    echo -n -e "${YELLOW}Pilih menu [1-6]: ${NC}"
}

# Function 4: Menambahkan buku baru (dengan parameter)
add_book() {
    local title="$1"
    local author="$2"
    local year="$3"
    
    # Validasi input
    if [ -z "$title" ] || [ -z "$author" ] || [ -z "$year" ]; then
        echo -e "${RED}Error: Semua field harus diisi!${NC}"
        return 1
    fi
    
    # Validasi tahun harus angka
    if ! [[ "$year" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Tahun harus berupa angka!${NC}"
        return 1
    fi
    
    # Cek duplikasi berdasarkan judul
    for book in "${books[@]}"; do
        local existing_title=$(echo "$book" | cut -d '|' -f1)
        if [ "$existing_title" == "$title" ]; then
            echo -e "${RED}Buku dengan judul '$title' sudah ada!${NC}"
            return 1
        fi
    done
    
    # Tambahkan buku ke array
    books+=("$title|$author|$year")
    echo -e "${GREEN}Buku berhasil ditambahkan!${NC}"
    return 0
}

# Function 5: Menampilkan semua buku
display_books() {
    if [ ${#books[@]} -eq 0 ]; then
        echo -e "${YELLOW}Tidak ada buku dalam koleksi.${NC}"
        return
    fi
    
    echo -e "\n${BLUE}=== DAFTAR BUKU ===${NC}"
    echo -e "No.  Judul                   Penulis               Tahun"
    echo -e "-----------------------------------------------------------"
    
    local i=1
    for book in "${books[@]}"; do
        local title=$(echo "$book" | cut -d '|' -f1)
        local author=$(echo "$book" | cut -d '|' -f2)
        local year=$(echo "$book" | cut -d '|' -f3)
        
        printf "%-4d %-23s %-20s %-4s\n" "$i" "$title" "$author" "$year"
        ((i++))
    done
}

# Function 6: Mencari buku
search_books() {
    if [ ${#books[@]} -eq 0 ]; then
        echo -e "${YELLOW}Tidak ada buku dalam koleksi.${NC}"
        return
    fi
    
    echo -n -e "${YELLOW}Masukkan kata kunci pencarian: ${NC}"
    read keyword
    
    if [ -z "$keyword" ]; then
        echo -e "${RED}Kata kunci tidak boleh kosong!${NC}"
        return
    fi
    
    echo -e "\n${BLUE}=== HASIL PENCARIAN ===${NC}"
    echo -e "No.  Judul                   Penulis               Tahun"
    echo -e "-----------------------------------------------------------"
    
    local found=0
    local i=1
    for book in "${books[@]}"; do
        if echo "$book" | grep -i "$keyword" > /dev/null; then
            local title=$(echo "$book" | cut -d '|' -f1)
            local author=$(echo "$book" | cut -d '|' -f2)
            local year=$(echo "$book" | cut -d '|' -f3)
            
            printf "%-4d %-23s %-20s %-4s\n" "$i" "$title" "$author" "$year"
            found=1
        fi
        ((i++))
    done
    
    if [ $found -eq 0 ]; then
        echo -e "${YELLOW}Tidak ditemukan buku dengan kata kunci '$keyword'.${NC}"
    fi
}

# Function 7: Menghapus buku
delete_book() {
    if [ ${#books[@]} -eq 0 ]; then
        echo -e "${YELLOW}Tidak ada buku dalam koleksi.${NC}"
        return
    fi
    
    display_books
    echo -n -e "${YELLOW}Masukkan nomor buku yang akan dihapus: ${NC}"
    read index
    
    # Validasi input
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Input harus berupa angka!${NC}"
        return
    fi
    
    if [ "$index" -lt 1 ] || [ "$index" -gt ${#books[@]} ]; then
        echo -e "${RED}Error: Nomor buku tidak valid!${NC}"
        return
    fi
    
    # Konfirmasi penghapusan
    local book_to_delete=${books[$((index-1))]}
    local title=$(echo "$book_to_delete" | cut -d '|' -f1)
    
    echo -n -e "${RED}Apakah Anda yakin ingin menghapus '$title'? (y/n): ${NC}"
    read confirm
    
    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
        # Hapus buku dari array
        books=("${books[@]:0:$((index-1))}" "${books[@]:$index}")
        echo -e "${GREEN}Buku berhasil dihapus!${NC}"
    else
        echo -e "${YELLOW}Penghapusan dibatalkan.${NC}"
    fi
}

# Function 8: Menampilkan statistik
show_stats() {
    local total_books=${#books[@]}
    
    if [ $total_books -eq 0 ]; then
        echo -e "${YELLOW}Tidak ada buku dalam koleksi.${NC}"
        return
    fi
    
    # Hitung tahun tertua dan terbaru
    local oldest_year=9999
    local newest_year=0
    
    for book in "${books[@]}"; do
        local year=$(echo "$book" | cut -d '|' -f3)
        
        # Operator perbandingan
        if [ "$year" -lt "$oldest_year" ]; then
            oldest_year=$year
        fi
        
        if [ "$year" -gt "$newest_year" ]; then
            newest_year=$year
        fi
    done
    
    echo -e "\n${BLUE}=== STATISTIK PERPUSTAKAAN ===${NC}"
    echo -e "Total buku dalam koleksi: $total_books"
    echo -e "Tahun terbit tertua     : $oldest_year"
    echo -e "Tahun terbit terbaru    : $newest_year"
    
    # Operator aritmatika
    local range=$((newest_year - oldest_year))
    echo -e "Rentang tahun terbit    : $range tahun"
}

# =============================================
# Program utama
# =============================================

# Memuat data saat aplikasi dimulai
load_data

# Loop utama program
while true; do
    show_menu
    read choice
    
    case $choice in
        1) 
            echo -e "\n${BLUE}=== TAMBAH BUKU BARU ===${NC}"
            echo -n -e "${YELLOW}Judul buku: ${NC}"
            read title
            echo -n -e "${YELLOW}Penulis: ${NC}"
            read author
            echo -n -e "${YELLOW}Tahun terbit: ${NC}"
            read year
            
            # Memanggil fungsi dengan parameter
            add_book "$title" "$author" "$year"
            if [ $? -eq 0 ]; then
                save_data
            fi
            ;;
        2)
            display_books
            ;;
        3)
            search_books
            ;;
        4)
            delete_book
            if [ $? -eq 0 ]; then
                save_data
            fi
            ;;
        5)
            show_stats
            ;;
        6)
            echo -e "${GREEN}Terima kasih telah menggunakan sistem manajemen perpustakaan!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid! Silakan pilih menu 1-6.${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Tekan Enter untuk melanjutkan...${NC}"
    read -n 1 -s
    clear
done