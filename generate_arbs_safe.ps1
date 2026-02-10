$languages = @(
    "fr", "de", "it", "pt", "ru", "zh", "ja", "ko", "ar", "tr", "vi", "th", "id", "nl", "pl", "uk", "sv", "cs", "el", "ro", "hu", "da", "fi", "no", "he", "ms", "bn", "ur"
)

$template = @'
{
    "@@locale": "LOCALE_CODE",
    "appTitle": "Ringo Ringtones",
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

foreach ($lang in $languages) {
    if ($lang -eq "zh") { $code = "zh" } else { $code = $lang }
    $content = $template -replace "LOCALE_CODE", $code
    $path = "lib/l10n/arb/app_$lang.arb"
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "Created $path"
}
