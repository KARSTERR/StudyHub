# AI StudyHub

**AI StudyHub** - Yapay zeka destekli, gerçek zamanlı grup çalışma ve ders notu paylaşım platformu. Öğrencilerin daha etkili çalışabilmesi için çeşitli özellikler sunar: grup çalışma odaları, ders notları paylaşımı, AI destekli öğretmen, sınav hazırlığı modu ve daha fazlası!

## **Proje Tanımı**

AI StudyHub, öğrencilere ders çalışma sürecinde yardımcı olmayı amaçlayan bir platformdur. Bu platform, öğrencilere notlarını dijitalleştirme, grup halinde çalışarak ortak ders çalışmaları yapma, kişiselleştirilmiş AI öğretmeni ile derslerine destek alma ve gamification mekanizmaları ile motivasyonlarını artırma gibi bir dizi özellik sunar. Öğrencilerin sınavlara yönelik çalışma alışkanlıklarını daha verimli hale getirmek için AI destekli test oluşturma ve içerik önerileri gibi yenilikçi özellikler de bulunur.

## **Ana Özellikler**

- **Gerçek Zamanlı Grup Çalışma:** Ortak ders çalışma odaları ile iş birliği.
- **Ders Notları Paylaşımı:** Kullanıcıların not ekleyip paylaşabileceği bir sistem.
- **Yapay Zekâ Destekli Öğretmen:** Kişiselleştirilmiş öğretim sunan AI chatbot.
- **Sınav Hazırlık Modu:** Otomatik oluşturulan testler ve konu analizleri.
- **Gamification:** XP ve rozet sistemiyle motivasyonu artıran ödüllendirme mekanizması.
- **Özelleştirilmiş İçerik Önerileri:** Kullanıcının ilgi alanına göre öneriler sunan AI algoritmaları.
- **Kendi Notlarını Dijitalleştir:** Kullanıcılar, el yazısı notlarını tarayarak sisteme aktarabilir.

---

## **Teknoloji Seçimi**

**Backend:**
- Django + PostgreSQL
- FastAPI
- Redis
- WebSockets

**Mobil Uygulama:**
- Flutter veya React Native

**Yapay Zekâ:**
- OpenAI API veya Mistral/LLama
- LangChain
- Hugging Face Transformers

**Ekstra:**
- OCR (Optik Karakter Tanıma) teknolojisi ile not dijitalleştirme

---

## **Kurulum ve Çalıştırma**

### **1. Backend Kurulumu**

1. **Gerekli Paketlerin Yüklenmesi**  
   Projeye ait backend kısmının çalışabilmesi için öncelikle gerekli paketlerin yüklenmesi gerekmektedir. Aşağıdaki komut ile tüm bağımlılıkları yükleyebilirsiniz:
   ```bash
   pip install -r requirements.txt
   ```

2. **Veritabanı Yapılandırması**  
   PostgreSQL veritabanını kullanıyoruz. Veritabanı bağlantısını `config.py` dosyasından yapılandırabilirsiniz. Gerekli veritabanı tablolarını oluşturmak için aşağıdaki komutu çalıştırın:
   ```bash
   python manage.py migrate
   ```

3. **Server'ı Çalıştırma**  
   Django veya FastAPI ile API server'ınızı başlatabilirsiniz:
   ```bash
   python manage.py runserver
   ```

### **2. Mobil Uygulama Kurulumu**

1. **Flutter/React Native Kurulumu**  
   Flutter kullanıyorsanız aşağıdaki komutla bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
   React Native kullanıyorsanız:
   ```bash
   npm install
   ```

2. **Uygulamayı Çalıştırma**  
   Flutter için:
   ```bash
   flutter run
   ```
   React Native için:
   ```bash
   npm run android   # Android cihazı için
   npm run ios       # iOS cihazı için
   ```

---

## **Proje Yapısı**

### **Backend (FastAPI + PostgreSQL)**

```
backend/
│── api/
│   ├── auth.py      # Kullanıcı kimlik doğrulama
│   ├── notes.py     # Ders notları yönetimi
│   ├── groups.py    # Grup çalışma yönetimi
│   ├── ai.py        # Yapay zeka entegrasyonu
│   ├── analytics.py # Kullanıcı öğrenme istatistikleri
│── models/
│   ├── user.py      # Kullanıcı modeli
│   ├── note.py      # Ders notu modeli
│   ├── group.py     # Çalışma grubu modeli
│── services/
│   ├── ocr_service.py # OCR ile not dijitalleştirme
│   ├── ai_service.py  # Yapay zekâ servisleri
│── database.py      # Veritabanı bağlantısı
│── main.py          # API giriş noktası
```

### **Mobil Uygulama (Flutter)**

```
lib/
│── core/
│   ├── constants.dart
│   ├── services.dart
│── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── note_model.dart
│   ├── repositories/
│   │   ├── user_repository.dart
│── features/
│   ├── authentication/
│   ├── note_sharing/
│   ├── group_work/
│   ├── ai_assistant/
│   ├── analytics/
│── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── themes/
│── main.dart
```

---

## **Katkı Sağlamak**

Projemize katkı sağlamak isterseniz, lütfen aşağıdaki adımları takip edin:

1. Bu repository'yi kendi bilgisayarınıza kopyalayın:
   ```bash
   git clone https://github.com/username/ai-studyhub.git
   ```

2. Yeni bir **branch** oluşturun:
   ```bash
   git checkout -b feature/feature-name
   ```

3. Yaptığınız değişiklikleri commit edin:
   ```bash
   git commit -m "Add feature"
   ```

4. Değişiklikleri remote repository'ye gönderin:
   ```bash
   git push origin feature/feature-name
   ```

5. Pull request oluşturun ve katkınızı bize gönderin!

---

## **Lisans**

Bu proje **MIT Lisansı** altında lisanslanmıştır - [Lisans Detayları](LICENSE)