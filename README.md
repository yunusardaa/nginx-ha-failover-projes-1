# Ubuntu Üzerinde Yüksek Erişilebilirlikli (HA) Nginx Sunucu Mimarisi

Bu proje, iki Ubuntu sunucusu üzerinde `Nginx` web sunucusunu kullanarak yüksek erişilebilirlikli (High Availability) bir mimarinin nasıl kurulacağını anlatan bir ödev çalışmasıdır.

Sistemin amacı, tek bir Sanal IP (Floating IP) adresi üzerinden hizmet vermek ve sunuculardan biri (MASTER) çöktüğünde, yedek sunucunun (BACKUP) "minimum kesintiyle" trafiği devralmasını sağlamaktır.

## Proje Özellikleri

* **Aktif-Pasif (Master-Backup) Mimarisi:** İki adet Nginx web sunucusu (`websunucu1` ve `websunucu2`).
* **Otomatik Yük Devretme (Failover):** `keepalived` servisi, ana sunucunun sağlığını izler ve bir sorun anında Sanal IP'yi yedek sunucuya devreder.
* **Tek Erişim Noktası (Sanal IP):** Kullanıcılar sisteme her zaman `192.168.126.200` olan tek bir Sanal IP üzerinden erişir.
* **Otomatik Yedekleme:** Ana sunucu, her gece 02:00'de web sitesi dosyalarını yedekler.
* **Otomatik Temizleme:** 7 günden eski yedekler sistemden otomatik olarak silinir.

## Kullanılan Teknolojiler

* **Sanallaştırma:** VMware Workstation
* **İşletim Sistemi:** Ubuntu (2 adet)
* **Web Sunucu:** Nginx
* **Yüksek Erişilebilirlik (HA):** Keepalived
* **Zamanlanmış Görevler:** Cron
* **Scripting:** Bash (Yedekleme script'i için)

## Mimari ve IP Yapılandırması

Bu projede 3 adet IP adresi bulunmaktadır:

| Sunucu / Rol | Hostname | Fiziksel IP Adresi | Rol |
| :--- | :--- | :--- | :--- |
| **Ana Sunucu** | `websunucu1` | `192.168.126.129` | MASTER (Priority 101) |
| **Yedek Sunucu** | `websunucu2` | `192.168.126.130` | BACKUP (Priority 100) |
| **Sanal IP** | - | `192.168.126.200` | Floating IP (Kullanıcının eriştiği IP) |

## Kurulum ve Yapılandırma Adımları

Bu mimariyi yeniden oluşturmak için aşağıdaki adımlar izlenmiştir.

### 1. Adım: Sunucu Hazırlığı (VMware)

1.  VMware üzerine `Ubuntu` işletim sistemi ile bir sanal makine kuruldu (`websunucu1`).
2.  Bu sanal makine `Clone` (Klonla) özelliği kullanılarak çoğaltıldı ve `websunucu2` oluşturuldu.
3.  Hostname'ler (`websunucu1`, `websunucu2`) ve IP adresleri (`.129`, `.130`) çakışmayacak şekilde ayarlandı.
4.  Kopyala-yapıştır için `open-vm-tools-desktop` kuruldu.

### 2. Adım: Nginx Kurulumu (İki Sunucuda da)

1.  Nginx web sunucusu kuruldu:
    ```bash
    sudo apt update
    sudo apt install nginx -y
    ```
2.  Test için `index.html` dosyaları sunucuları ayırt edecek şekilde değiştirildi:
    
    * **`websunucu1` üzerinde:**
        ```bash
        echo "<h1>Burası WEBSUNUCU-1</h1>" | sudo tee /var/www/html/index.html
        ```
    * **`websunucu2` üzerinde:**
        ```bash
        echo "<h1>Burası WEBSUNUCU-2</h1>" | sudo tee /var/www/html/index.html
        ```

### 3. Adım: Keepalived (Failover) Kurulumu

1.  `keepalived` servisi **iki sunucuya da** kuruldu:
    ```bash
    sudo apt install keepalived -y
    ```
2.  Sanal IP'nin çalışması için IP yönlendirme aktifleştirildi (iki sunucuda da):
    ```bash
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    ```
3.  **`websunucu1` (MASTER) Yapılandırması** (`/etc/keepalived/keepalived.conf`):
    ```conf
    vrrp_script chk_nginx {
        script "/usr/bin/pgrep nginx"  # Nginx çalışıyor mu diye kontrol et
        interval 2
        weight 50
