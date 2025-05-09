@echo off
chcp 65001 >nul
set IP={IP}
set LOG=%USERPROFILE%\Desktop\ping_alert.log

echo Surveillance avancée de l'adresse %IP%...
echo Journaux enregistrés dans : %LOG%

:loop
:: Exécute le ping et capture la sortie dans un fichier temporaire
ping -n 1 %IP% > ping_result.tmp

:: Recherche les erreurs
findstr /C:"Impossible de joindre" ping_result.tmp >nul
if %errorlevel%==0 (
    echo [%date% %time%] ⚠ ALERTE : %IP% ne répond plus ! >> "%LOG%"
    echo ⚠ ALERTE : %IP% ne répond plus !
    powershell -Command "Add-Type -AssemblyName System.Media; (New-Object System.Media.SoundPlayer 'C:\Windows\Media\Tada.wav').PlaySync()"
) else (
    echo [%date% %time%] ✅ OK : %IP% répond.
)

timeout /t 5 >nul
goto loop


