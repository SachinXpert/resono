$languages = @{
    "fr" = "Ringo Ringtones";
    "de" = "Ringo Klingeltöne";
    "it" = "Suonerie Ringo";
    "pt" = "Toques Ringo";
    "ru" = "Рингтоны Ringo";
    "zh" = "Ringo 铃声";
    "ja" = "Ringo 着信音";
    "ko" = "Ringo 벨소리";
    "ar" = "رिंगو نغمات";
    "tr" = "Ringo Zil Sesleri";
    "vi" = "Nhạc chuông Ringo";
    "th" = "เสียงเรียกเข้า Ringo";
    "id" = "Nada Dering Ringo";
    "nl" = "Ringo Ringtones";
    "pl" = "Dzwonki Ringo";
    "uk" = "Рінгтони Ringo";
    "sv" = "Ringo Ringsignaler";
    "cs" = "Vyzvánění Ringo";
    "el" = "Ringo Ringtones";
    "ro" = "Tonuri de apel Ringo";
    "hu" = "Ringo Csengőhangok";
    "da" = "Ringo Ringetoner";
    "fi" = "Ringo Soittoäänet";
    "no" = "Ringo Ringetoner";
    "he" = "רינגו רינגטונים";
    "ms" = "Ringo Ringtones";
    "bn" = "Ringo Ringtones";
    "ur" = "Ringo Ringtones"
}

$template = @'
{
    "@@locale": "LOCALE_CODE",
    "appTitle": "APP_TITLE",
    "homeTab": "Home",
    "searchTab": "Search",
    "settingsTab": "Settings",
    "premiumTitle": "Ringo Premium",
    "premiumSubtitle": "Unlock all ringtones & features",
    "appearanceHeader": "Appearance",
    "darkMode": "Dark Mode",
    "dynamicColor": "Dynamic Color",
    "toolsHeader": "Tools",
    "ringtoneEditor": "Ringtone Editor",
    "generalHeader": "General",
    "language": "Language",
    "storage": "Storage",
    "legalHeader": "Legal & Support",
    "privacyPolicy": "Privacy Policy",
    "aboutUs": "About Us",
    "version": "Version"
}
'@

foreach ($lang in $languages.Keys) {
    $title = $languages[$lang]
    $content = $template -replace "LOCALE_CODE", $lang -replace "APP_TITLE", $title
    $path = "lib/l10n/arb/app_$lang.arb"
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "Created $path"
}
