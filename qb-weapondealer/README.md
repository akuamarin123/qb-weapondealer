# QB-Job Silah Kaçakçılığı Sistemi

Bu script, QBCore framework için geliştirilmiş kapsamlı bir silah kaçakçılığı sistemidir.

## 💡 Özellikler

### 👊 Üretim Sistemi
- Silah ve mermi üretimi
- Kalite bazlı üretim sistemi (Mükemmel, İyi, Normal, Kötü)
- Malzeme gereksinimleri
- Üretim süresi ve animasyonlar
- Atölye seviye sistemi

### 📊 İtibar Sistemi
- Seviye bazlı itibar sistemi
- Her satışta itibar puanı kazanma
- Seviye atladıkça yeni silah türlerinin açılması
- Özel seviye etiketleri ve rozet sistemi

### 💰 Satış Sistemi
- F3 menüsünden NPC'lere satış yapabilme
- Kaliteye göre değişen satış fiyatları
- Silah ve mermi satışı
- Otomatik polis bildirimi:
  - Silah satışlarında %40 bildirim şansı
  - Mermi satışlarında %20 bildirim şansı
  - GPS'te işaretlenen satış konumu
  - Özel bildirim sesi ve ekran uyarısı

### 🎯 Mermi Sistemi
- Farklı silah türleri için mermi üretimi
- Kalite bazlı mermi özellikleri
- Özelleştirilebilir üretim süreleri
- Malzeme gereksinimleri

### 📱 Menü Sistemi
- Modern ve kullanıcı dostu arayüz
- Kategorize edilmiş üretim menüsü
  - Silah üretimi
  - Mermi üretimi
  - İstatistik görüntüleme
- Detaylı ürün bilgileri
- Anlık itibar ve seviye gösterimi

## ⚙️ Kurulum
1. Scripti resources klasörüne atın
2. server.cfg'ye ensure qb-weapondealer ekleyin
3. SQL dosyasını veritabanına import edin
4. Configden gerekli ayarlamaları yapın

## 📋 Gereksinimler
- QBCore Framework
- qb-target
- qb-menu
- qb-input

## 🔄 Güncellemeler
### v1.1.0
- Mermi üretim sistemi eklendi
- F3 menüsünden NPC'lere satış sistemi eklendi
- Otomatik polis bildirimi sistemi eklendi
- İstatistik menüsü güncellendi
- Performans iyileştirmeleri yapıldı

## 🤝 Destek
Herhangi bir sorun veya öneriniz için GitHub üzerinden issue açabilirsiniz.

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

## 📞 Destek
- Discord: [Discord Sunucumuz](yakında...)
- GitHub Issues üzerinden hata bildirebilirsiniz

## 📜 Lisans
Bu proje MIT lisansı altında lisanslanmıştır. 