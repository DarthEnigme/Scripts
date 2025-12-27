# ==============================================================================
# Nano Winget Manager | Fixed UI I think
# ==============================================================================

try {
    $sig = '[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();'
    $type = Add-Type -MemberDefinition $sig -Name DPIAware -PassThru
    $type::SetProcessDPIAware() | Out-Null
} catch {}

$ThemeSig = '[DllImport("uxtheme.dll", ExactSpelling=true, CharSet=CharSet.Unicode)] public static extern int SetWindowTheme(IntPtr hWnd, string pszSubAppName, string pszSubIdList);'
$Win32 = Add-Type -MemberDefinition $ThemeSig -Name Win32Theme -PassThru

Add-Type -AssemblyName System.Windows.Forms, System.Drawing, Microsoft.VisualBasic
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Directories ---
$SafeFolder = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WingetManager_Data"
if (!(Test-Path $SafeFolder)) { New-Item -ItemType Directory -Path $SafeFolder -Force | Out-Null }
$LogFolder = Join-Path $SafeFolder "Logs"
$JsonPath = Join-Path $SafeFolder "apps_config.json"
$DownloadsPath = Join-Path $env:USERPROFILE "Downloads"

# --- List ---
[System.Collections.ArrayList]$AppsList = @()
if (Test-Path $JsonPath) {
    try {
        $RawData = Get-Content $JsonPath -Raw | ConvertFrom-Json
        foreach ($item in $RawData) { if ($item.App) { [void]$AppsList.Add($item.App) } }
    } catch {}
}
if ($AppsList.Count -eq 0) { 
    $Essentials = @("7zip.7zip","Google.Chrome","VideoLAN.VLC","Microsoft.VisualStudioCode","Spotify.Spotify","Discord.Discord")
    foreach ($app in $Essentials) { [void]$AppsList.Add($app) }
}
$AppsList.Sort()

# --- Palette ---
$Palette = @{ Accent=[System.Drawing.Color]::FromArgb(0,120,215); Danger=[System.Drawing.Color]::FromArgb(231,76,60); Success=[System.Drawing.Color]::LimeGreen; Info=[System.Drawing.Color]::DeepSkyBlue; Term=[System.Drawing.Color]::Black }

# --- Functions ---
function Save-Config {
    $Export = foreach ($id in $AppsList) { [PSCustomObject]@{ App=$id; Date=(Get-Date -Format "u") } }
    $Export | ConvertTo-Json | Out-File $JsonPath -Encoding utf8 -Force
}

function Write-GuiLog($Msg, $Color = [System.Drawing.Color]::White) {
    $dt = Get-Date -Format "HH:mm:ss"
    $LogBox.SelectionStart = $LogBox.TextLength ; $LogBox.SelectionColor = $Color
    $LogBox.AppendText("[$dt] $Msg`n") ; $LogBox.ScrollToCaret()
    if ($CheckLog.Checked -and $script:SessionLogFile) { "[$dt] $Msg" | Out-File $script:SessionLogFile -Append -Encoding utf8 }
    [System.Windows.Forms.Application]::DoEvents()
}

# --- UI ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Nano Winget Manager v12.1" ; $Form.Size = "600, 960" ; $Form.StartPosition = "CenterScreen" ; $Form.BackColor = "White" ; $Form.FormBorderStyle = "FixedSingle"

$Y = 15
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    $Header = New-Object System.Windows.Forms.Label ; $Header.Text = "ADMINISTRATOR MODE ACTIVE" ; $Header.ForeColor = $Palette.Danger ; $Header.BackColor = [System.Drawing.Color]::FromArgb(255,242,242) ; $Header.Size = "600, 45" ; $Header.Location = "0,0" ; $Header.TextAlign = "MiddleCenter" ; $Header.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $Form.Controls.Add($Header) ; $Y = 65
}

$AddInput = New-Object System.Windows.Forms.TextBox ; $AddInput.Location = "25, $Y" ; $AddInput.Width = 200
$AddBtn = New-Object System.Windows.Forms.Button ; $AddBtn.Text = "Search ID" ; $AddBtn.Location = "235, $($Y-1)" ; $AddBtn.Size = "100, 26" ; $AddBtn.FlatStyle = "Flat"
$ScanBtn = New-Object System.Windows.Forms.Button ; $ScanBtn.Text = "Scan Updates" ; $ScanBtn.Location = "345, $($Y-1)" ; $ScanBtn.Size = "100, 26" ; $ScanBtn.FlatStyle = "Flat"
$FolderBtn = New-Object System.Windows.Forms.Button ; $FolderBtn.Text = "Data" ; $FolderBtn.Location = "455, $($Y-1)" ; $FolderBtn.Size = "90, 26" ; $FolderBtn.FlatStyle = "Flat"
$Form.Controls.AddRange(@($AddInput, $AddBtn, $ScanBtn, $FolderBtn))

$WebBtn = New-Object System.Windows.Forms.Button ; $WebBtn.Text = "Add Direct Web URL (.exe / .msi)" ; $WebBtn.Location = "25, $($Y+40)" ; $WebBtn.Size = "520, 35" ; $WebBtn.FlatStyle = "Flat" ; $WebBtn.BackColor = [System.Drawing.Color]::WhiteSmoke
$Form.Controls.Add($WebBtn)

$ProgressBar = New-Object System.Windows.Forms.ProgressBar ; $ProgressBar.Location = "25, $($Y+85)" ; $ProgressBar.Size = "520, 20" ; $ProgressBar.Style = "Continuous" ; $ProgressBar.Visible = $false
$Form.Add_Load({ $Win32::SetWindowTheme($ProgressBar.Handle, "", "") })
$ProgressBar.ForeColor = $Palette.Success
$ProgressBar.BackColor = [System.Drawing.Color]::White
$Form.Controls.Add($ProgressBar)

$CheckedListBox = New-Object System.Windows.Forms.CheckedListBox ; $CheckedListBox.Location = "25, $($Y+115)" ; $CheckedListBox.Size = "520, 250" ; $CheckedListBox.BorderStyle = "FixedSingle" ; $CheckedListBox.CheckOnClick = $true
$Form.Controls.Add($CheckedListBox)

$BtnAll = New-Object System.Windows.Forms.Button ; $BtnAll.Text = "Select All" ; $BtnAll.Location = "25, $($Y+375)" ; $BtnAll.Size = "165, 30" ; $BtnAll.FlatStyle = "Flat"
$BtnNone = New-Object System.Windows.Forms.Button ; $BtnNone.Text = "Select None" ; $BtnNone.Location = "200, $($Y+375)" ; $BtnNone.Size = "165, 30" ; $BtnNone.FlatStyle = "Flat"
$BtnRem = New-Object System.Windows.Forms.Button ; $BtnRem.Text = "Remove" ; $BtnRem.Location = "375, $($Y+375)" ; $BtnRem.Size = "170, 30" ; $BtnRem.FlatStyle = "Flat" ; $BtnRem.ForeColor = $Palette.Danger
$Form.Controls.AddRange(@($BtnAll, $BtnNone, $BtnRem))

$LogBox = New-Object System.Windows.Forms.RichTextBox ; $LogBox.Location = "25, $($Y+420)" ; $LogBox.Size = "520, 200" ; $LogBox.BackColor = $Palette.Term ; $LogBox.ForeColor = $Palette.Success ; $LogBox.BorderStyle = "None" ; $LogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$Form.Controls.Add($LogBox)

$CheckLog = New-Object System.Windows.Forms.CheckBox ; $CheckLog.Text = "Save Logs" ; $CheckLog.Location = "25, $($Y+635)" ; $CheckLog.Checked = $true ; $CheckLog.Width = 90
$RadioDry = New-Object System.Windows.Forms.RadioButton ; $RadioDry.Text = "Simulation" ; $RadioDry.Location = "125, $($Y+635)" ; $RadioDry.Checked = $true ; $RadioDry.Width = 100
$RadioUpd = New-Object System.Windows.Forms.RadioButton ; $RadioUpd.Text = "Update" ; $RadioUpd.Location = "235, $($Y+635)" ; $RadioUpd.Width = 100
$RadioIns = New-Object System.Windows.Forms.RadioButton ; $RadioIns.Text = "Install" ; $RadioIns.Location = "345, $($Y+635)" ; $RadioIns.Width = 100
$Form.Controls.AddRange(@($CheckLog, $RadioDry, $RadioUpd, $RadioIns))

$StartBtn = New-Object System.Windows.Forms.Button ; $StartBtn.Text = "EXECUTE OPERATION" ; $StartBtn.Location = "25, $($Y+675)" ; $StartBtn.Size = "520, 65" ; $StartBtn.BackColor = $Palette.Accent ; $StartBtn.ForeColor = "White" ; $StartBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold) ; $StartBtn.FlatStyle = "Flat"
$Form.Controls.Add($StartBtn)

# --- Handlers ---
$UpdateUI = { $CheckedListBox.Items.Clear(); foreach($a in $AppsList){ [void]$CheckedListBox.Items.Add($a, $false) } }
&$UpdateUI

$AddBtn.Add_Click({
    if ([string]::IsNullOrWhiteSpace($AddInput.Text)) { return }
    Write-GuiLog "Searching winget for: $($AddInput.Text)..." $Palette.Info
    $raw = winget search $AddInput.Text --source winget --accept-source-agreements | Out-String
    if ($raw -match '(?m)^.*?\s+([a-zA-Z0-9]+\.[a-zA-Z0-9\.]+)\s+') {
        $foundId = $Matches[1].Trim()
        if (-not $AppsList.Contains($foundId)) { 
            $null = $AppsList.Add($foundId) ; $AppsList.Sort() ; &$UpdateUI ; Save-Config 
            Write-GuiLog "Found and added: $foundId" $Palette.Success
        } else { Write-GuiLog "ID $foundId is already in your list." $Palette.Info }
    } else { Write-GuiLog "No exact Winget ID found for '$($AddInput.Text)'." $Palette.Danger }
    $AddInput.Clear()
})

$WebBtn.Add_Click({
    $url = [Microsoft.VisualBasic.Interaction]::InputBox("Paste URL:", "Direct Web Installer", "https://")
    if ($url -like "http*") { 
        $item = "URL:$url"
        if (-not $AppsList.Contains($item)) { 
            $null = $AppsList.Add($item); &$UpdateUI; Save-Config 
            Write-GuiLog "Added URL Installer." $Palette.Success
        }
    }
})

$BtnRem.Add_Click({
    $toRemove = @($CheckedListBox.CheckedItems)
    foreach($i in $toRemove) { [void]$AppsList.Remove($i) }
    &$UpdateUI ; Save-Config ; Write-GuiLog "Selected items removed." $Palette.Danger
})

$ScanBtn.Add_Click({
    $ProgressBar.Visible = $true ; Write-GuiLog "Scanning Winget for updates..." $Palette.Info
    $upgrades = winget upgrade --no-upgrade-availability-summary | Out-String
    $count = 0
    for ($i=0;$i -lt $CheckedListBox.Items.Count;$i++) { 
        if ($upgrades -like "*$($CheckedListBox.Items[$i])*") { 
            $CheckedListBox.SetItemChecked($i, $true) ; $count++ 
        } 
    }
    Write-GuiLog "Scan complete: $count updates found." $Palette.Success
    $ProgressBar.Value = 100 ; Start-Sleep -Milliseconds 400 ; $ProgressBar.Visible = $false
})

$StartBtn.Add_Click({
    $selected = @($CheckedListBox.CheckedItems) ; if ($selected.Count -eq 0) { return }
    if ($CheckLog.Checked) { $script:SessionLogFile = Join-Path $LogFolder "Log_$((Get-Date).ToString('yyyyMMdd_HHmm')).txt" }
    
    $StartBtn.Enabled = $false ; $ProgressBar.Value = 0 ; $ProgressBar.Visible = $true
    foreach ($item in $selected) {
        Write-GuiLog "Processing: $item" $Palette.Info
        $status = "Success"
        if ($item -like "URL:*") {
            if ($RadioDry.Checked) { $status = "Simulated" } else {
                try { 
                    $t = Join-Path $DownloadsPath "temp_install.exe"
                    (New-Object System.Net.WebClient).DownloadFile($item.Replace("URL:",""), $t)
                    Start-Process $t -Wait ; if (Test-Path $t) { Remove-Item $t -Force }
                } catch { $status = "Failed" }
            }
        } else {
            if ($RadioDry.Checked) { $status = "Simulated"; Start-Sleep -Milliseconds 400 } else {
                $cmd = if($RadioUpd.Checked){"upgrade"}else{"install"}
                $p = Start-Process winget -ArgumentList "$cmd --id $item -e --silent --accept-package-agreements" -NoNewWindow -Wait -PassThru
                if ($p.ExitCode -ne 0) { $status = "Failed" }
            }
        }
        $ProgressBar.Value += [Math]::Floor(100 / $selected.Count)
        $resColor = if($status -eq "Failed"){$Palette.Danger}else{$Palette.Success}
        Write-GuiLog "Result: $status" $resColor
    }
    $ProgressBar.Value = 100 ; $StartBtn.Enabled = $true ; Write-GuiLog "All tasks completed." $Palette.Success
})

$BtnAll.Add_Click({ for($i=0;$i -lt $CheckedListBox.Items.Count;$i++){ $CheckedListBox.SetItemChecked($i, $true) } })
$BtnNone.Add_Click({ for($i=0;$i -lt $CheckedListBox.Items.Count;$i++){ $CheckedListBox.SetItemChecked($i, $false) } })
$FolderBtn.Add_Click({ explorer $SafeFolder })

[void]$Form.ShowDialog()