# Medigram

Medigram; hekimlerin tıbbi bilgiye hızlı ve akıcı biçimde ulaşması için TikTok benzeri kaydırmalı bir mobil deneyim sunar. Rivaan Ranawat'ın açık kaynak TikTok klonundan çatallanarak Flutter + GetX mimarisiyle yeniden tasarlandı ve Stripe tabanlı premium üyelik yapısına hazırlanacak şekilde düzenlendi.

## Özellikler
- **Kart Bazlı Tıbbi Akış:** Dikey kaydırma ile kategorize edilmiş medikal kartlar, görseller, kaynaklar ve etkileşim butonları.
- **Filtreler ve Arama:** Uzmanlık kategorileri ve anahtar kelime filtreleri.
- **Premium İçerik Kilidi:** Stripe entegrasyonuna hazır ödeme servisi ile premium kart uyarıları.
- **AI Sohbet Yer Tutucusu:** Gerçek AI entegrasyonu için uyarı veren demo sohbet ekranı.
- **Admin Paneli:** Kart yönetimi, AI üretimi, kategori düzenleme ve Stripe plan kartları.
- **Profil Ekranı:** Hekim profili, ilgi alanları, kaydedilen kartlar ve takip metrikleri.

## Mimari
- **İstemci:** Flutter + GetX, koyu tema.
- **Veri Katmanı:** `MockDataService` ile MedicalCard ve Category modelleri (Firestore bağı kaldırıldı).
- **Ödeme:** `PaymentService` içinde Stripe Checkout / PaymentIntent entegrasyonu için mock akış.
- **Test:** Widget testi ve `flutter analyze` temiz.

## Kurulum
```bash
flutter pub get
flutter run
```
Flutter SDK `>=2.15.1 <3.0.0`. Android paket kimliği `com.medigram.app`, iOS bundle adı `medigram` olarak güncellendi.

## Stripe Entegrasyon Planı
1. Backend üzerinde Stripe Checkout/PaymentIntent endpoint'i oluşturun.
2. `PaymentService.startPremiumCheckout` içinde backend çağrısı yaparak oturum linkini alın.
3. `AuthController` üzerinde ödeme sonrası `user.isPremium` değerini güncelleyin.
4. Premium kart kilitleri otomatik olarak kaldırılır.

## Özelleştirme
- `MockDataService` yerine REST/Firestore/Supabase bağlanabilir.
- `AiChatScreen` içindeki `Future.delayed` bölümü gerçek AI servisine yönlendirilebilir.
- Admin panelindeki TODO kartları backend end-point'lerine bağlayın.
- Analitik için Firebase/Amplitude gibi çözümlerle `MedicalCardController` aksiyonlarını loglayın.

## Testler
```bash
flutter analyze
flutter test
```

## Katkı
Pull request açarken mimari değişiklikleri ve olası backend ihtiyaçlarını README üzerinden belgeleyin.
