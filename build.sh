#!/usr/bin/env bash
# Construiește APK-ul semnat fără Gradle, doar cu uneltele Android de bază:
#   aapt2 (resurse) → javac (cod) → d8/dx (dex) → zipalign → apksigner (semnare)
#
# Folosire:  ANDROID_JAR=/cale/platforms/android-34/android.jar ./build.sh
# Rezultat:  out/ZileDeNastere.apk
set -euo pipefail
cd "$(dirname "$0")"

PKG=md.prieteni.zilenastere
MIN_SDK=26
TARGET_SDK=34
VERSION_CODE=1
VERSION_NAME=1.0
ANDROID_JAR="${ANDROID_JAR:?Setează ANDROID_JAR spre platforms/android-34/android.jar}"
KEYSTORE=keystore/release.jks
KEY_ALIAS=zile
OUT=out

if [ ! -f "$KEYSTORE" ] || [ ! -f keystore/password.txt ]; then
  echo "Lipsește cheia de semnare: $KEYSTORE și keystore/password.txt (nu sunt pe GitHub, intenționat)." >&2
  echo "Pune-ți cheia în keystore/ sau creează una nouă (APK-ul nu se va mai instala peste cel vechi):" >&2
  echo "  mkdir -p keystore && printf 'o-parola-lunga' > keystore/password.txt" >&2
  echo "  keytool -genkeypair -keystore $KEYSTORE -alias $KEY_ALIAS -keyalg RSA -keysize 3072 -validity 12000 \\" >&2
  echo "          -storepass:file keystore/password.txt -dname CN=ZileDeNastere" >&2
  exit 1
fi

rm -rf "$OUT"
mkdir -p "$OUT/gen" "$OUT/classes" "$OUT/dex"

echo "1/6 Testele logicii (date, texte)…"
mkdir -p "$OUT/test-classes"
javac -encoding UTF-8 -proc:none -d "$OUT/test-classes" \
  app/src/main/java/md/prieteni/zilenastere/{Friend,BirthdayLogic,Texts}.java tests/LogicTest.java
java -ea -cp "$OUT/test-classes" md.prieteni.zilenastere.LogicTest

echo "2/6 Resurse (aapt2)…"
# Manifestul din sursă nu are atributul package (stil Gradle/AGP 8); îl adăugăm pentru aapt2.
sed "s|<manifest |<manifest package=\"$PKG\" |" app/src/main/AndroidManifest.xml > "$OUT/AndroidManifest.xml"
aapt2 compile --dir app/src/main/res -o "$OUT/res.zip"
aapt2 link -o "$OUT/base.apk" -I "$ANDROID_JAR" \
  --manifest "$OUT/AndroidManifest.xml" --java "$OUT/gen" \
  --min-sdk-version $MIN_SDK --target-sdk-version $TARGET_SDK \
  --version-code $VERSION_CODE --version-name $VERSION_NAME \
  "$OUT/res.zip"

echo "3/6 Cod Java (javac)…"
javac -encoding UTF-8 -source 8 -target 8 -Xlint:-options -Xlint:unchecked -proc:none \
  -bootclasspath "$ANDROID_JAR" -d "$OUT/classes" \
  $(find app/src/main/java "$OUT/gen" -name '*.java')

echo "4/6 Dex…"
if command -v d8 >/dev/null; then
  d8 --min-api $MIN_SDK --lib "$ANDROID_JAR" --output "$OUT/dex" $(find "$OUT/classes" -name '*.class')
elif command -v dx >/dev/null; then
  dx --dex --min-sdk-version=$MIN_SDK --output="$OUT/dex/classes.dex" "$OUT/classes"
else
  dalvik-exchange --dex --min-sdk-version=$MIN_SDK --output="$OUT/dex/classes.dex" "$OUT/classes"
fi

echo "5/6 Împachetare + aliniere…"
cp "$OUT/base.apk" "$OUT/unsigned.apk"
(cd "$OUT/dex" && zip -q -X ../unsigned.apk classes.dex)
zipalign -p -f 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"

echo "6/6 Semnare…"
apksigner sign --ks "$KEYSTORE" --ks-key-alias "$KEY_ALIAS" --ks-pass file:keystore/password.txt \
  --out "$OUT/ZileDeNastere.apk" "$OUT/aligned.apk"
apksigner verify "$OUT/ZileDeNastere.apk"
echo "Gata: $OUT/ZileDeNastere.apk"
