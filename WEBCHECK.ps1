$url = "test.com"
$lastHash = ""

while ($true) {
    try {
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
        $hash = [System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($content.Content))) -replace "-", ""

        if ($lastHash -ne "" -and $hash -ne $lastHash) {
            Write-Host "⚠️ Change detected on the website!"
            [console]::beep(800, 500) 
        } else {
            Write-Host "No change detected. ($((Get-Date)))"
        }

        $lastHash = $hash
    } catch {
        Write-Host "Error fetching the URL: $_"
    }

    Start-Sleep -Seconds 300  # wait 5 minutes
}
