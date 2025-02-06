# QB-Job Silah Kaçakçılığı Sistemi

Bu script, QBCore framework için geliştirilmiş kapsamlı bir silah kaçakçılığı sistemidir.

## 🌟 Özellikler

### 💪 Üretim Sistemi
- Farklı silah tipleri (Tabanca, Hafif Makineli)
- Kalite sistemi (Mükemmel, İyi, Normal, Kötü)
- Malzeme gereksinimleri
- Üretim süresi ve maliyeti
- Kalite şansını etkileyen itibar sistemi

### 📦 Depo Sistemi
- Üretilen silahların depolanması
- Envanter yönetimi
- Detaylı silah bilgileri (Kalite, Üretim tarihi)
- Aktif siparişlerin takibi

### 👥 NPC Müşteri Sistemi
- Farklı müşteri tipleri (Çete Üyesi, Profesyonel, Mafya Babası)
- Dinamik sipariş sistemi
- Risk bazlı fiyatlandırma
- İtibar gereksinimi

### 🚗 Teslimat Sistemi
- Farklı risk seviyeleri
- Polis bildirimi sistemi
- Kaçış noktaları
- Araç tipleri (Gizli, Hızlı, Kargo)
- Kılık değiştirme sistemi

### 💰 İtibar ve Ekonomi
- İtibar seviyeleri
- Seviye bazlı bonuslar
- Dinamik fiyatlandırma
- Risk bazlı ödüller

## ⚙️ Gereksinimler
- QBCore Framework
- oxmysql
- qb-target
- qb-menu

## 📥 Kurulum

1. Scripti `[qb]` klasörüne indirin
2. `qb-job` klasörünü `resources` klasörüne taşıyın
3. `server.cfg` dosyasına şu satırı ekleyin:
```cfg
ensure qb-job
```
4. SQL dosyasını veritabanınıza import edin
5. Gerekli item resimlerini `inventory/html/images/` klasörüne ekleyin:
   - steel.png
   - aluminum.png
   - plastic.png
   - weapon_pistol.png
   - weapon_smg.png

## 🛠️ Konfigürasyon

`config.lua` dosyasından şu ayarları özelleştirebilirsiniz:
- Lokasyonlar
- Silah özellikleri ve gereksinimleri
- NPC müşteri ayarları
- Risk ve ödül oranları
- Teslimat sistemi ayarları

## 📋 Kullanım

### Silah Üretimi
1. Atölyeye gidin
2. Üretim menüsünü açın
3. Üretmek istediğiniz silahı seçin
4. Gerekli malzemeleri ve parayı kontrol edin
5. Üretimi başlatın

### Teslimat
1. NPC müşteriden sipariş alın
2. Risk seviyesini değerlendirin
3. Uygun araç ve kılık seçin
4. Teslimatı gerçekleştirin
5. Polisten kaçının

### İtibar Kazanma
- Kaliteli silah üretin
- Başarılı teslimatlar yapın
- Riskli siparişleri tamamlayın

## 🚫 Bilinen Hatalar
- Bazı NPC'ler nadir durumlarda spawn olmayabilir
- Yüksek sunucu yükünde teslimat sistemi gecikmeli çalışabilir

## 🔄 Güncellemeler
- v1.0.0: İlk sürüm
- v1.0.1: Hata düzeltmeleri ve optimizasyonlar

## 📞 Destek
- Discord: [Discord Sunucumuz](yakında...)
- GitHub Issues üzerinden hata bildirebilirsiniz

## 📜 Lisans
Bu proje MIT lisansı altında lisanslanmıştır. 