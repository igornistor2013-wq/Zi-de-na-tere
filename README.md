<p align="center"><img src="docs/icon.png" width="112" alt="Iconița aplicației"></p>

<h1 align="center">Zile de naștere</h1>

<p align="center">Aplicație Android care îți amintește de zilele de naștere ale celor mai apropiați prieteni.<br>
În fiecare dimineață la <b>08:00</b> primești o notificare dacă cineva își serbează ziua.</p>

## Ce face

- Lista prietenilor, ordonată după cine urmează; sus apare ziua de naștere de azi sau următoarea.
- Adaugi un prieten cu numele, ziua și luna; anul e opțional (dacă îl pui, vezi câți ani împlinește).
- Notificare la 08:00 în ziua respectivă, cu butonul **„Trimite urare”** — deschide WhatsApp, Viber,
  Telegram, SMS… cu „La mulți ani!” deja scris.
- Opțional, reamintire și cu o zi / o săptămână înainte.
- Ora notificării se schimbă din **Setări**; tot acolo e și o **notificare de test**.
- Dacă telefonul a fost închis la ora notificării, notificarea vine imediat ce pornește telefonul.
- 29 februarie se sărbătorește pe 28 în anii nebisecți.
- Temă deschisă și întunecată. Datele rămân doar pe telefon, fără internet și fără cont.

Funcționează pe Android 8.0 și mai nou.

## Instalare

1. Descarcă `ZileDeNastere.apk` din pagina **Releases** a acestui proiect, direct pe telefon.
2. Deschide fișierul. Dacă Android cere, permite **„Instalează aplicații necunoscute”** pentru
   aplicația din care îl deschizi (Fișiere, Chrome etc.).
3. Dacă apare Google Play Protect, alege **„Instalează oricum”** (aplicația nu e din Magazin Play).
4. La prima pornire permite notificările.

## Structura proiectului

```
app/src/main/AndroidManifest.xml
app/src/main/java/md/prieteni/zilenastere/
    MainActivity.java          ecranul principal, adăugare / editare / ștergere
    SettingsActivity.java      ora notificării, reamintiri din timp, test, stare
    Reminders.java             alarma zilnică și notificările
    AlarmReceiver.java         pornit de alarmă la ora aleasă
    SystemEventsReceiver.java  reprogramare după repornire / schimbarea orei / actualizare
    BirthdayLogic.java         calculele cu date (fără Android, testat)
    Texts.java                 textele în română (fără Android, testat)
    Friend.java, FriendStore.java, Prefs.java
app/src/main/res/              ecrane, culori, iconițe vectoriale
tests/LogicTest.java           teste pentru date și texte
build.sh                       construire fără Gradle
```

Doar componente Android standard, fără biblioteci externe. APK-ul are în jur de 60 KB.

## Construire

**Cu Android Studio:** deschide folderul proiectului și rulează configurația `app`.

**Din linia de comandă, fără Gradle:**

```bash
# necesită: JDK 17+, aapt2, d8 (sau dx), zipalign, apksigner și android.jar pentru API 34
ANDROID_JAR=/cale/Android/Sdk/platforms/android-34/android.jar ./build.sh
# → out/ZileDeNastere.apk
```

Scriptul rulează mai întâi testele din `tests/LogicTest.java`.

## Cheia de semnare

Cheia cu care e semnat APK-ul (`keystore/release.jks` și `keystore/password.txt`) **nu** e în acest
repository, intenționat. Pune-o local în folderul `keystore/` ca să construiești o versiune care se
instalează peste cea existentă, fără să pierzi lista de prieteni. Fără ea, `build.sh` îți arată cum
să creezi o cheie nouă.
