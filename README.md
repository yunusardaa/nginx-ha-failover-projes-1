# Ubuntu Üzerinde Nginx için Yüksek Erişilebilirlikli (HA) Sunucu Kurulumu

Bu proje, `Nginx` web sunucusu için `keepalived` kullanarak "Aktif-Pasif" bir yüksek erişilebilirlik mimarisi kurar. Ana sunucu (`MASTER`) çöktüğünde, yedek sunucu (`BACKUP`) sanal bir IP'yi devralarak hizmetin kesintisiz sürmesini sağlar.

Bu depo, mimariyi kurmak için gereken tüm yapılandırma dosyalarını ve betikleri içerir.

## Proje Mimarisi

* **MASTER Sunucu (`websunucu1`):** `192.168.126.129` (Priority 101)
* **BACKUP Sunucu (`websunucu2`):** `192.168.126.130` (Priority 100)
* **Sanal IP (Floating IP):** `192.168.126.200` (Kullanıcının eriştiği IP)

---

## Kurulum Kılavuzu

### 1. Adım: Nginx Kurulumu (İKİ Sunucuda da)

```bash
# Nginx'i kur
sudo apt update
sudo apt install nginx -y

# Sunucuları ayırt etmek için index sayfalarını değiştir
# --- SADECE websunucu1'de:
echo "<h1>Burası WEBSUNUCU-1 (MASTER)</h1>" | sudo tee /var/www/html/index.html

# --- SADECE websunucu2'de:
echo "<h1>Burası WEBSUNUCU-2 (BACKUP)</h1>" | sudo tee /var/www/html/index.html
