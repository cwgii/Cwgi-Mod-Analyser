[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MillerConsoleWindow {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
[MillerConsoleWindow]::ShowWindow([MillerConsoleWindow]::GetConsoleWindow(), 0) | Out-Null

$script:CwgiLogoPath = "C:\Users\Nigga\Downloads\generated-1778944232446.png"
$script:CwgiBrandName = "cwgi mod analyser"
$script:CwgiDiscord = "cwgii"
$script:CwgiTikTok = "cwgicuh"
$script:CwgiServer = "aucpvp.net"

function Get-CwgiLogoImage {
    if ($script:CwgiLogoCache) {
        return [System.Drawing.Bitmap]::new($script:CwgiLogoCache)
    }
    if (-not (Test-Path -LiteralPath $script:CwgiLogoPath -PathType Leaf)) { return $null }

    try {
        $bytes = [System.IO.File]::ReadAllBytes($script:CwgiLogoPath)
        $stream = [System.IO.MemoryStream]::new($bytes)
        $image = [System.Drawing.Image]::FromStream($stream)
        $bitmap = [System.Drawing.Bitmap]::new($image)
        $image.Dispose()
        $stream.Dispose()

        $bg = $bitmap.GetPixel(0, 0)
        $minX = $bitmap.Width
        $minY = $bitmap.Height
        $maxX = 0
        $maxY = 0
        for ($y = 0; $y -lt $bitmap.Height; $y += 3) {
            for ($x = 0; $x -lt $bitmap.Width; $x += 3) {
                $p = $bitmap.GetPixel($x, $y)
                $diff = [math]::Abs($p.R - $bg.R) + [math]::Abs($p.G - $bg.G) + [math]::Abs($p.B - $bg.B)
                if ($diff -gt 35) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }

        if ($maxX -gt $minX -and $maxY -gt $minY) {
            $margin = 24
            $minX = [math]::Max(0, $minX - $margin)
            $minY = [math]::Max(0, $minY - $margin)
            $maxX = [math]::Min($bitmap.Width - 1, $maxX + $margin)
            $maxY = [math]::Min($bitmap.Height - 1, $maxY + $margin)
            $cropRect = [System.Drawing.Rectangle]::new($minX, $minY, $maxX - $minX + 1, $maxY - $minY + 1)
            $script:CwgiLogoCache = $bitmap.Clone($cropRect, $bitmap.PixelFormat)
            $bitmap.Dispose()
        } else {
            $script:CwgiLogoCache = $bitmap
        }

        return [System.Drawing.Bitmap]::new($script:CwgiLogoCache)
    } catch {
        return $null
    }
}

function New-CwgiLogoBox {
    param(
        [int]$Width = 220,
        [int]$Height = 92
    )

    $box = [System.Windows.Forms.PictureBox]::new()
    $box.Size = [System.Drawing.Size]::new($Width, $Height)
    $box.SizeMode = "Zoom"
    $box.BackColor = [System.Drawing.Color]::Transparent
    $logo = Get-CwgiLogoImage
    if ($logo) { $box.Image = $logo }
    return $box
}

function Show-MillerInfoBox {
    param(
        [string]$Title,
        [string]$Message,
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )

    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $Icon) | Out-Null
}

function New-RoundedRectanglePath {
    param(
        [System.Drawing.Rectangle]$Bounds,
        [int]$Radius
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $Radius * 2
    $rect = [System.Drawing.Rectangle]::new($Bounds.X, $Bounds.Y, $Bounds.Width - 1, $Bounds.Height - 1)
    if ($diameter -le 0) {
        $path.AddRectangle($rect)
        return $path
    }

    $path.AddArc($rect.X, $rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Set-RoundedControl {
    param(
        [System.Windows.Forms.Control]$Control,
        [int]$Radius = 12
    )

    if ($Control.Width -le 0 -or $Control.Height -le 0) { return }
    $path = New-RoundedRectanglePath -Bounds ([System.Drawing.Rectangle]::new(0, 0, $Control.Width, $Control.Height)) -Radius $Radius
    $Control.Region = [System.Drawing.Region]::new($path)
    $path.Dispose()
}

function Enable-RoundedControl {
    param(
        [System.Windows.Forms.Control]$Control,
        [int]$Radius = 12
    )

    return
}

function Style-MillerButton {
    param(
        [System.Windows.Forms.Button]$Button,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$HoverColor
    )

    $Button.BackColor = $BackColor
    $Button.ForeColor = [System.Drawing.Color]::White
    $Button.FlatStyle = "Flat"
    $Button.FlatAppearance.BorderSize = 0
    $Button.FlatAppearance.MouseOverBackColor = $HoverColor
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(126, 146, 153)
    $Button.Font = [System.Drawing.Font]::new("Segoe UI Semibold", 9)
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
}

function Add-CwgiPlugLabels {
    param(
        [System.Windows.Forms.Control]$Parent,
        [int]$X,
        [int]$Y,
        [System.Drawing.Color]$Color,
        [int]$Spacing = 128
    )

    $font = [System.Drawing.Font]::new("Segoe UI Semibold", 9)
    $items = @(
        "Discord: $script:CwgiDiscord",
        "TikTok: $script:CwgiTikTok",
        "Server: $script:CwgiServer"
    )
    $currentX = $X
    foreach ($item in $items) {
        $label = [System.Windows.Forms.Label]::new()
        $label.Text = $item
        $label.ForeColor = $Color
        $label.Font = $font
        $label.AutoSize = $true
        $label.Location = [System.Drawing.Point]::new($currentX, $Y)
        $Parent.Controls.Add($label)
        $currentX += $Spacing
    }
}

function New-CwgiLine {
    param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [System.Drawing.Color]$Color
    )

    $line = [System.Windows.Forms.Panel]::new()
    $line.Location = [System.Drawing.Point]::new($X, $Y)
    $line.Size = [System.Drawing.Size]::new($Width, 2)
    $line.BackColor = $Color
    return $line
}

function Show-MillerProgressWindow {
    $bg = [System.Drawing.Color]::FromArgb(30, 31, 35)
    $panelBg = [System.Drawing.Color]::FromArgb(35, 45, 52)
    $muted = [System.Drawing.Color]::FromArgb(166, 184, 190)
    $text = [System.Drawing.Color]::White

    $form = [System.Windows.Forms.Form]::new()
    $form.Text = $script:CwgiBrandName
    $form.Size = [System.Drawing.Size]::new(660, 360)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $bg
    $form.Font = [System.Drawing.Font]::new("Calibri", 10)
    Enable-RoundedControl -Control $form -Radius 18

    $card = [System.Windows.Forms.Panel]::new()
    $card.Location = [System.Drawing.Point]::new(22, 22)
    $card.Size = [System.Drawing.Size]::new(600, 276)
    $card.BackColor = $panelBg
    Enable-RoundedControl -Control $card -Radius 18

    $logo = New-CwgiLogoBox -Width 210 -Height 86
    $logo.Location = [System.Drawing.Point]::new(24, 18)

    $title = [System.Windows.Forms.Label]::new()
    $title.Text = "Scanning Mods"
    $title.ForeColor = $text
    $title.Font = [System.Drawing.Font]::new("Segoe UI Semibold", 22)
    $title.AutoSize = $true
    $title.Location = [System.Drawing.Point]::new(258, 34)

    $phase = [System.Windows.Forms.Label]::new()
    $phase.Text = "Preparing scan..."
    $phase.ForeColor = $muted
    $phase.AutoEllipsis = $true
    $phase.Location = [System.Drawing.Point]::new(258, 78)
    $phase.Size = [System.Drawing.Size]::new(310, 24)

    $file = [System.Windows.Forms.Label]::new()
    $file.Text = ""
    $file.ForeColor = $muted
    $file.AutoEllipsis = $true
    $file.Location = [System.Drawing.Point]::new(34, 128)
    $file.Size = [System.Drawing.Size]::new(532, 24)

    $bar = [System.Windows.Forms.ProgressBar]::new()
    $bar.Location = [System.Drawing.Point]::new(34, 170)
    $bar.Size = [System.Drawing.Size]::new(532, 18)
    $bar.Style = "Continuous"

    $count = [System.Windows.Forms.Label]::new()
    $count.Text = "0 / 0"
    $count.ForeColor = $muted
    $count.Location = [System.Drawing.Point]::new(32, 200)
    $count.Size = [System.Drawing.Size]::new(534, 22)
    $count.TextAlign = "MiddleRight"

    $progressLine = New-CwgiLine -X 34 -Y 152 -Width 532 -Color $muted
    $plugLine = New-CwgiLine -X 34 -Y 226 -Width 410 -Color $muted
    $card.Controls.AddRange(@($logo, $title, $phase, $file, $progressLine, $bar, $count, $plugLine))
    Add-CwgiPlugLabels -Parent $card -X 32 -Y 236 -Color $muted -Spacing 126
    $form.Controls.Add($card)

    $script:MillerProgressForm = $form
    $script:MillerProgressPhase = $phase
    $script:MillerProgressFile = $file
    $script:MillerProgressBar = $bar
    $script:MillerProgressCount = $count
    $form.Show()
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-MillerProgress {
    param(
        [string]$Phase,
        [int]$Index,
        [int]$Total,
        [string]$FileName = ""
    )

    if (-not $script:MillerProgressForm) { return }
    $script:MillerProgressPhase.Text = $Phase
    $script:MillerProgressFile.Text = $FileName
    $script:MillerProgressBar.Maximum = [math]::Max($Total, 1)
    $script:MillerProgressBar.Value = [math]::Min([math]::Max($Index, 0), $script:MillerProgressBar.Maximum)
    $script:MillerProgressCount.Text = "$Index / $Total"
    [System.Windows.Forms.Application]::DoEvents()
}

function Close-MillerProgressWindow {
    if ($script:MillerProgressForm) {
        $script:MillerProgressForm.Close()
        $script:MillerProgressForm.Dispose()
        $script:MillerProgressForm = $null
    }
}

function Show-MillerFolderPicker {
    param([string]$DefaultPath)

    $script:selectedPath = $null
    $bg = [System.Drawing.Color]::FromArgb(30, 31, 35)
    $panelBg = [System.Drawing.Color]::FromArgb(35, 45, 52)
    $fieldBg = [System.Drawing.Color]::FromArgb(24, 25, 28)
    $muted = [System.Drawing.Color]::FromArgb(166, 184, 190)
    $text = [System.Drawing.Color]::White
    $accent = $muted

    $form = [System.Windows.Forms.Form]::new()
    $form.Text = $script:CwgiBrandName
    $form.Size = [System.Drawing.Size]::new(740, 390)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $bg
    $form.Font = [System.Drawing.Font]::new("Segoe UI", 10)
    Enable-RoundedControl -Control $form -Radius 18

    $card = [System.Windows.Forms.Panel]::new()
    $card.Location = [System.Drawing.Point]::new(22, 22)
    $card.Size = [System.Drawing.Size]::new(680, 300)
    $card.BackColor = $panelBg
    Enable-RoundedControl -Control $card -Radius 18

    $logo = New-CwgiLogoBox -Width 210 -Height 90
    $logo.Location = [System.Drawing.Point]::new(24, 18)

    $title = [System.Windows.Forms.Label]::new()
    $title.Text = $script:CwgiBrandName
    $title.ForeColor = $text
    $title.Font = [System.Drawing.Font]::new("Calibri", 24, [System.Drawing.FontStyle]::Bold)
    $title.AutoSize = $true
    $title.Location = [System.Drawing.Point]::new(268, 28)

    $subtitle = [System.Windows.Forms.Label]::new()
    $subtitle.Text = "Mods, hidden libraries, launcher args, and runtime checks."
    $subtitle.ForeColor = $muted
    $subtitle.AutoSize = $true
    $subtitle.Location = [System.Drawing.Point]::new(272, 72)

    $label = [System.Windows.Forms.Label]::new()
    $label.Text = "Mods folder"
    $label.ForeColor = $text
    $label.Font = [System.Drawing.Font]::new("Segoe UI Semibold", 9)
    $label.AutoSize = $true
    $label.Location = [System.Drawing.Point]::new(32, 124)

    $pathBox = [System.Windows.Forms.TextBox]::new()
    $pathBox.Text = $DefaultPath
    $pathBox.Location = [System.Drawing.Point]::new(35, 152)
    $pathBox.Size = [System.Drawing.Size]::new(500, 28)
    $pathBox.BackColor = $fieldBg
    $pathBox.ForeColor = $text
    $pathBox.BorderStyle = "None"
    $pathBox.Font = [System.Drawing.Font]::new("Segoe UI", 10)

    $browseButton = [System.Windows.Forms.Button]::new()
    $browseButton.Text = "Browse"
    $browseButton.Location = [System.Drawing.Point]::new(552, 150)
    $browseButton.Size = [System.Drawing.Size]::new(95, 32)
    Style-MillerButton -Button $browseButton -BackColor $muted -HoverColor ([System.Drawing.Color]::FromArgb(126, 146, 153))

    $hint = [System.Windows.Forms.Label]::new()
    $hint.Text = "Tip: The scanner now includes nested folders and hidden library jars."
    $hint.ForeColor = $accent
    $hint.AutoSize = $true
    $hint.Location = [System.Drawing.Point]::new(35, 196)

    $scanButton = [System.Windows.Forms.Button]::new()
    $scanButton.Text = "Start Scan"
    $scanButton.Location = [System.Drawing.Point]::new(426, 246)
    $scanButton.Size = [System.Drawing.Size]::new(105, 36)
    Style-MillerButton -Button $scanButton -BackColor $muted -HoverColor ([System.Drawing.Color]::FromArgb(126, 146, 153))

    $cancelButton = [System.Windows.Forms.Button]::new()
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = [System.Drawing.Point]::new(546, 246)
    $cancelButton.Size = [System.Drawing.Size]::new(105, 36)
    Style-MillerButton -Button $cancelButton -BackColor $panelBg -HoverColor ([System.Drawing.Color]::FromArgb(45, 58, 66))

    $selectedPath = $null

    $browseButton.Add_Click({
        $dialog = [System.Windows.Forms.OpenFileDialog]::new()
        $dialog.Title = "Choose your Minecraft mods folder"
        $dialog.ValidateNames = $false
        $dialog.CheckFileExists = $false
        $dialog.CheckPathExists = $true
        $dialog.FileName = "Select this folder"
        if (Test-Path $pathBox.Text -PathType Container) {
            $dialog.InitialDirectory = $pathBox.Text
        } elseif (Test-Path ([System.IO.Path]::GetDirectoryName($pathBox.Text)) -PathType Container) {
            $dialog.InitialDirectory = [System.IO.Path]::GetDirectoryName($pathBox.Text)
        }
        if ($dialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
            $pathBox.Text = [System.IO.Path]::GetDirectoryName($dialog.FileName)
        }
        $dialog.Dispose()
    })

    $scanButton.Add_Click({
        if ([string]::IsNullOrWhiteSpace($pathBox.Text)) {
            Show-MillerInfoBox -Title "Missing folder" -Message "Choose a mods folder first." -Icon Warning
            return
        }
        if (-not (Test-Path $pathBox.Text -PathType Container)) {
            Show-MillerInfoBox -Title "Invalid folder" -Message "That folder does not exist or cannot be accessed." -Icon Warning
            return
        }
        $script:selectedPath = $pathBox.Text
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })

    $cancelButton.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Close()
    })

    $headerLine = New-CwgiLine -X 272 -Y 106 -Width 300 -Color $muted
    $folderLine = New-CwgiLine -X 35 -Y 188 -Width 500 -Color $muted
    $plugLine = New-CwgiLine -X 35 -Y 232 -Width 360 -Color $muted
    $card.Controls.AddRange(@($logo, $title, $subtitle, $headerLine, $label, $pathBox, $browseButton, $folderLine, $hint, $plugLine, $scanButton, $cancelButton))
    Add-CwgiPlugLabels -Parent $card -X 32 -Y 216 -Color $muted -Spacing 126
    $form.Controls.Add($card)
    $null = $form.ShowDialog()
    $form.Dispose()

    return $script:selectedPath
}

function Show-MillerSummaryPopup {
    param(
        [int]$TotalFiles,
        [object[]]$VerifiedMods,
        [object[]]$UnknownMods,
        [object[]]$SuspiciousMods,
        [object[]]$BypassMods,
        [object[]]$ObfuscatedMods,
        [object[]]$JvmFlags
    )

    $VerifiedCount = @($VerifiedMods).Count
    $UnknownCount = @($UnknownMods).Count
    $SuspiciousCount = @($SuspiciousMods).Count
    $BypassCount = @($BypassMods).Count
    $ObfuscatedCount = @($ObfuscatedMods).Count
    $JvmCount = @($JvmFlags).Count
    $riskCount = $SuspiciousCount + $BypassCount + $ObfuscatedCount + $JvmCount
    $statusText = if ($riskCount -gt 0) { "Issues found" } else { "Looks clean" }
    $statusColor = if ($riskCount -gt 0) { [System.Drawing.Color]::FromArgb(248, 113, 113) } else { [System.Drawing.Color]::FromArgb(52, 211, 153) }
    $bg = [System.Drawing.Color]::FromArgb(30, 31, 35)
    $panelBg = $bg
    $surface = $bg
    $surface2 = $bg
    $muted = [System.Drawing.Color]::FromArgb(166, 184, 190)
    $text = [System.Drawing.Color]::White
    $accentBlue = $muted

    function New-ReportText {
        param([string[]]$Lines)
        return (($Lines | Where-Object { $_ -ne $null }) -join [Environment]::NewLine)
    }

    function Get-PlainEnglishRisk {
        param(
            [string[]]$Flags = @(),
            [string[]]$Patterns = @(),
            [string[]]$Strings = @(),
            [string[]]$Fullwidth = @(),
            [string]$Reason = ""
        )

        $notes = [System.Collections.Generic.List[string]]::new()
        if ($Reason -match "Dfabric\.addMods") {
            $notes.Add("This jar was loaded through Dfabric.addMods, which means it can be injected from launcher/JVM settings instead of sitting normally in the mods folder. That can be used to hide a mod from basic folder checks.") | Out-Null
        }

        foreach ($item in @($Patterns + $Strings + $Fullwidth + $Flags)) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }

            if ($item -match "AutoCrystal|Crystal|Anchor|AutoTotem|TriggerBot|AimAssist|SilentAim|Reach|HitCrystal") {
                $notes.Add("This mod mentions combat automation or crystal/anchor helpers. It could provide an unfair advantage by making attacks, crystals, anchors, or aim actions faster or more consistent than vanilla Minecraft allows.") | Out-Null
            } elseif ($item -match "Loaded through Dfabric\.addMods|Fabric addMods") {
                $notes.Add("This is tied to Dfabric.addMods, so the mod may be loaded from a hidden or unusual path instead of the normal mods folder.") | Out-Null
            } elseif ($item -match "Obfuscation|obfuscated|single-letter|Single-char|Numeric class|Unicode class|Gibberish|No-vowel|Confusion-char|Fullwidth") {
                $notes.Add("The code looks intentionally hard to read. That does not always prove cheating, but it makes it harder to verify what the mod actually does and is common in bypasses or hidden clients.") | Out-Null
            } elseif ($item -match "Runtime\.exec|arbitrary OS commands") {
                $notes.Add("This mod appears able to run commands on the computer. That is risky because a Minecraft mod normally should not need to start programs or execute system commands.") | Out-Null
            } elseif ($item -match "HTTP file download|fetches and writes files") {
                $notes.Add("This mod can download and write files while Minecraft is running. That could be used to fetch extra code after the scan or install hidden components.") | Out-Null
            } elseif ($item -match "HTTP POST|exfiltration|sends system data") {
                $notes.Add("This mod appears able to send data out to a remote server. That could be used to leak system, account, or session information.") | Out-Null
            } elseif ($item -match "Suspicious nested JAR|Hollow shell") {
                $notes.Add("This jar may be wrapping another jar inside it. That can be normal for libraries, but it is also a common way to hide the real mod payload from simple scans.") | Out-Null
            } elseif ($item -match "Fake mod identity") {
                $notes.Add("The mod claims to be a known/legit mod but contains suspicious behavior. That can mean it is pretending to be safe while doing something else.") | Out-Null
            } elseif ($item -match "javaagent|agentpath|agentlib|bootclasspath|JDWP") {
                $notes.Add("This runtime flag can inject code into Java/Minecraft from outside the normal mod loader. That can bypass normal mod checks.") | Out-Null
            }
        }

        if ($notes.Count -eq 0 -and (@($Patterns).Count -gt 0 -or @($Strings).Count -gt 0)) {
            $notes.Add("This mod contains names or strings that matched the suspicious database. That means it mentions features often found in cheat, macro, or bypass mods.") | Out-Null
        }
        if ($notes.Count -eq 0 -and @($Flags).Count -gt 0) {
            $notes.Add("This mod is different from a normal clean mod because one or more scanner rules were triggered. Read the technical flags below for the exact evidence.") | Out-Null
        }

        return @($notes | Select-Object -Unique)
    }

    function Get-ReportListName {
        param([string]$Name)
        if ([string]::IsNullOrWhiteSpace($Name)) { return "Unknown item" }
        if ($Name -match "^[A-Za-z]:\\") { return [System.IO.Path]::GetFileName($Name) }
        if ($Name.Length -gt 46) { return "..." + $Name.Substring($Name.Length - 43) }
        return $Name
    }

    function Add-ReportTab {
        param(
            [System.Windows.Forms.TabControl]$Tabs,
            [string]$Title,
            [object[]]$Items,
            [scriptblock]$NameScript,
            [scriptblock]$DetailScript,
            [System.Drawing.Color]$Accent
        )

        $tab = [System.Windows.Forms.TabPage]::new($Title)
        $tab.BackColor = $bg
        $tab.ForeColor = $text

        $list = [System.Windows.Forms.ListBox]::new()
        $list.Location = [System.Drawing.Point]::new(16, 20)
        $list.Size = [System.Drawing.Size]::new(315, 430)
        $list.BackColor = $panelBg
        $list.ForeColor = $text
        $list.BorderStyle = "None"
        $list.Font = [System.Drawing.Font]::new("Segoe UI", 9)
        $list.ItemHeight = 30
        $list.DrawMode = "OwnerDrawFixed"
        Enable-RoundedControl -Control $list -Radius 12
        $list.Add_DrawItem({
            param($sender, $eventArgs)
            if ($eventArgs.Index -lt 0) { return }

            $isSelected = (($eventArgs.State -band [System.Windows.Forms.DrawItemState]::Selected) -eq [System.Windows.Forms.DrawItemState]::Selected)
            $rowBack = if ($isSelected) { [System.Drawing.Color]::FromArgb(166, 184, 190) } else { [System.Drawing.Color]::FromArgb(24, 25, 28) }
            $rowText = [System.Drawing.Color]::White

            $brushBack = [System.Drawing.SolidBrush]::new($rowBack)
            $brushText = [System.Drawing.SolidBrush]::new($rowText)
            $eventArgs.Graphics.FillRectangle($brushBack, $eventArgs.Bounds)
            $item = [string]$sender.Items[$eventArgs.Index].Name
            $textRect = [System.Drawing.RectangleF]::new($eventArgs.Bounds.X + 10, $eventArgs.Bounds.Y + 6, $eventArgs.Bounds.Width - 16, $eventArgs.Bounds.Height - 8)
            $eventArgs.Graphics.DrawString($item, $sender.Font, $brushText, $textRect)
            $brushBack.Dispose()
            $brushText.Dispose()
        })

        $details = [System.Windows.Forms.TextBox]::new()
        $details.Location = [System.Drawing.Point]::new(350, 20)
        $details.Size = [System.Drawing.Size]::new(510, 430)
        $details.BackColor = $surface2
        $details.ForeColor = $text
        $details.BorderStyle = "None"
        $details.Multiline = $true
        $details.ReadOnly = $true
        $details.ScrollBars = "Vertical"
        $details.Font = [System.Drawing.Font]::new("Cascadia Mono", 9)
        Enable-RoundedControl -Control $details -Radius 12
        $list.Tag = $details

        $empty = [System.Windows.Forms.Label]::new()
        $empty.Text = "Nothing in this category."
        $empty.ForeColor = $muted
        $empty.AutoSize = $true
        $empty.Location = [System.Drawing.Point]::new(28, 34)
        $empty.Visible = (@($Items).Count -eq 0)

        foreach ($item in @($Items)) {
            $list.Items.Add([PSCustomObject]@{
                Name = (& $NameScript $item)
                Detail = (& $DetailScript $item)
            }) | Out-Null
        }
        $list.DisplayMember = "Name"

        $list.Add_SelectedIndexChanged({
            param($sender, $eventArgs)
            $clickedList = [System.Windows.Forms.ListBox]$sender
            $detailBox = [System.Windows.Forms.TextBox]$clickedList.Tag
            if ($null -ne $clickedList.SelectedItem -and $null -ne $detailBox) {
                $detailBox.Text = [string]$clickedList.SelectedItem.Detail
            }
        })

        if ($list.Items.Count -gt 0) {
            $list.SelectedIndex = 0
            $details.Text = [string]$list.SelectedItem.Detail
        }

        $tab.Controls.AddRange(@($list, $details, $empty))
        $Tabs.TabPages.Add($tab) | Out-Null
    }

    $suspiciousReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($SuspiciousMods)) {
        $lines = @("Category: Suspicious mod", "File: $($m.FileName)", "Path: $($m.FilePath)", "")
        $plain = Get-PlainEnglishRisk -Patterns @($m.Patterns) -Strings @($m.Strings) -Fullwidth @($m.Fullwidth) -Reason $m.Reason
        if ($plain.Count -gt 0) {
            $lines += "What this means:"
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
        }
        if ($m.Reason) { $lines += "Reason: $($m.Reason)"; $lines += "" }
        if ($m.Patterns.Count -gt 0) { $lines += "Pattern matches:"; foreach ($p in ($m.Patterns | Sort-Object)) { $lines += "  - $p" }; $lines += "" }
        if ($m.Strings.Count -gt 0) { $lines += "String matches:"; foreach ($s in ($m.Strings | Sort-Object)) { $lines += "  - $s" }; $lines += "" }
        if ($m.Fullwidth.Count -gt 0) { $lines += "Fullwidth / hidden text:"; foreach ($f in ($m.Fullwidth | Sort-Object)) { $lines += "  - $f" } }
        $suspiciousReportItems.Add([PSCustomObject]@{ Name = "SUS  $(Get-ReportListName $m.FileName)"; Detail = New-ReportText $lines }) | Out-Null
    }
    foreach ($m in @($BypassMods)) {
        $lines = @("Category: Bypass / injection", "File: $($m.FileName)", "Path: $($m.FilePath)", "", "Flags:")
        $plain = Get-PlainEnglishRisk -Flags @($m.Flags)
        if ($plain.Count -gt 0) {
            $lines = @("Category: Bypass / injection", "File: $($m.FileName)", "Path: $($m.FilePath)", "", "What this means:")
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
            $lines += "Flags:"
        }
        foreach ($flag in ($m.Flags | Sort-Object)) { $lines += "  - $flag" }
        $suspiciousReportItems.Add([PSCustomObject]@{ Name = "BYPASS  $(Get-ReportListName $m.FileName)"; Detail = New-ReportText $lines }) | Out-Null
    }
    foreach ($m in @($ObfuscatedMods)) {
        $lines = @("Category: Obfuscated / different from normal", "File: $($m.FileName)", "Path: $($m.FilePath)", "", "Flags:")
        $plain = Get-PlainEnglishRisk -Flags @($m.Flags)
        if ($plain.Count -gt 0) {
            $lines = @("Category: Obfuscated / different from normal", "File: $($m.FileName)", "Path: $($m.FilePath)", "", "What this means:")
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
            $lines += "Flags:"
        }
        foreach ($flag in ($m.Flags | Sort-Object)) { $lines += "  - $flag" }
        $suspiciousReportItems.Add([PSCustomObject]@{ Name = "OBF  $(Get-ReportListName $m.FileName)"; Detail = New-ReportText $lines }) | Out-Null
    }
    foreach ($flag in @($JvmFlags)) {
        $label = (($flag -split " — ")[0])
        $plain = Get-PlainEnglishRisk -Flags @($flag)
        $detail = @("Category: Runtime / launcher flag", "")
        if ($plain.Count -gt 0) {
            $detail += "What this means:"
            foreach ($note in $plain) { $detail += "  - $note" }
            $detail += ""
        }
        $detail += [string]$flag
        $suspiciousReportItems.Add([PSCustomObject]@{
            Name = "JVM  $label"
            Detail = New-ReportText $detail
        }) | Out-Null
    }
    $SuspiciousCount = $suspiciousReportItems.Count

    $form = [System.Windows.Forms.Form]::new()
    $form.Text = "$script:CwgiBrandName - Results"
    $form.Size = [System.Drawing.Size]::new(1040, 760)
    $form.StartPosition = "CenterScreen"
    $form.MinimumSize = [System.Drawing.Size]::new(900, 650)
    $form.FormBorderStyle = "None"
    $form.BackColor = $bg
    $form.Font = [System.Drawing.Font]::new("Segoe UI", 10)
    Enable-RoundedControl -Control $form -Radius 18
    $script:MillerDragActive = $false
    $script:MillerDragStart = [System.Drawing.Point]::Empty

    $dragStart = {
        param($sender, $eventArgs)
        if ($eventArgs.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $script:MillerDragActive = $true
            $script:MillerDragStart = $eventArgs.Location
        }
    }
    $dragMove = {
        param($sender, $eventArgs)
        if ($script:MillerDragActive) {
            $screenPoint = $sender.PointToScreen($eventArgs.Location)
            $form.Location = [System.Drawing.Point]::new($screenPoint.X - $script:MillerDragStart.X, $screenPoint.Y - $script:MillerDragStart.Y)
        }
    }
    $dragEnd = {
        $script:MillerDragActive = $false
    }
    $form.Add_MouseDown($dragStart)
    $form.Add_MouseMove($dragMove)
    $form.Add_MouseUp($dragEnd)

    $sidebar = [System.Windows.Forms.Panel]::new()
    $sidebar.Location = [System.Drawing.Point]::new(20, 20)
    $sidebar.Size = [System.Drawing.Size]::new(220, 700)
    $sidebar.Anchor = "Top,Bottom,Left"
    $sidebar.BackColor = $bg

    $logo = New-CwgiLogoBox -Width 180 -Height 76
    $logo.Location = [System.Drawing.Point]::new(20, 18)
    $logo.Add_MouseDown($dragStart)
    $logo.Add_MouseMove($dragMove)
    $logo.Add_MouseUp($dragEnd)

    $title = [System.Windows.Forms.Label]::new()
    $title.Text = "Scan Complete"
    $title.ForeColor = [System.Drawing.Color]::White
    $title.Font = [System.Drawing.Font]::new("Calibri", 26, [System.Drawing.FontStyle]::Bold)
    $title.AutoSize = $true
    $title.Location = [System.Drawing.Point]::new(260, 18)
    $title.Add_MouseDown($dragStart)
    $title.Add_MouseMove($dragMove)
    $title.Add_MouseUp($dragEnd)

    $status = [System.Windows.Forms.Label]::new()
    $status.Text = $statusText
    $status.ForeColor = $statusColor
    $status.Font = [System.Drawing.Font]::new("Calibri", 15, [System.Drawing.FontStyle]::Bold)
    $status.AutoSize = $true
    $status.Location = [System.Drawing.Point]::new(262, 72)
    $statusLine = New-CwgiLine -X 262 -Y 100 -Width 115 -Color $muted

    $plugPanel = [System.Windows.Forms.Panel]::new()
    $plugPanel.Location = [System.Drawing.Point]::new(20, 108)
    $plugPanel.Size = [System.Drawing.Size]::new(180, 86)
    $plugPanel.BackColor = $bg

    $discordLabel = [System.Windows.Forms.Label]::new()
    $discordLabel.Text = "Discord   $script:CwgiDiscord"
    $discordLabel.ForeColor = [System.Drawing.Color]::White
    $discordLabel.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
    $discordLabel.AutoSize = $true
    $discordLabel.Location = [System.Drawing.Point]::new(0, 0)

    $tiktokLabel = [System.Windows.Forms.Label]::new()
    $tiktokLabel.Text = "TikTok    $script:CwgiTikTok"
    $tiktokLabel.ForeColor = [System.Drawing.Color]::White
    $tiktokLabel.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
    $tiktokLabel.AutoSize = $true
    $tiktokLabel.Location = [System.Drawing.Point]::new(0, 28)

    $serverLabel = [System.Windows.Forms.Label]::new()
    $serverLabel.Text = "Server    $script:CwgiServer"
    $serverLabel.ForeColor = [System.Drawing.Color]::White
    $serverLabel.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
    $serverLabel.AutoSize = $true
    $serverLabel.Location = [System.Drawing.Point]::new(0, 56)
    $plugPanel.Controls.AddRange(@($discordLabel, $tiktokLabel, $serverLabel))

    $topCloseButton = [System.Windows.Forms.Button]::new()
    $topCloseButton.Text = "X"
    $topCloseButton.Location = [System.Drawing.Point]::new(984, 18)
    $topCloseButton.Size = [System.Drawing.Size]::new(40, 34)
    $topCloseButton.Anchor = "Top,Right"
    Style-MillerButton -Button $topCloseButton -BackColor $bg -HoverColor ([System.Drawing.Color]::FromArgb(86, 42, 46))
    $topCloseButton.Add_Click({ $form.Close() })

    $fullscreenButton = [System.Windows.Forms.Button]::new()
    $fullscreenButton.Text = "□"
    $fullscreenButton.Location = [System.Drawing.Point]::new(938, 18)
    $fullscreenButton.Size = [System.Drawing.Size]::new(40, 34)
    $fullscreenButton.Anchor = "Top,Right"
    Style-MillerButton -Button $fullscreenButton -BackColor $bg -HoverColor ([System.Drawing.Color]::FromArgb(45, 58, 66))
    $script:MillerNormalBounds = $null
    $script:MillerIsFullscreen = $false
    $fullscreenButton.Add_Click({
        if (-not $script:MillerIsFullscreen) {
            $script:MillerNormalBounds = $form.Bounds
            $form.Bounds = [System.Windows.Forms.Screen]::FromControl($form).WorkingArea
            $fullscreenButton.Text = "❐"
            $script:MillerIsFullscreen = $true
        } else {
            if ($script:MillerNormalBounds) { $form.Bounds = $script:MillerNormalBounds }
            $fullscreenButton.Text = "□"
            $script:MillerIsFullscreen = $false
        }
    })

    $summary = [System.Windows.Forms.FlowLayoutPanel]::new()
    $summary.Location = [System.Drawing.Point]::new(260, 138)
    $summary.Size = [System.Drawing.Size]::new(520, 42)
    $summary.BackColor = $bg
    $summary.WrapContents = $false

    $summaryRows = @(
        @("Files", $TotalFiles, [System.Drawing.Color]::White),
        @("Verified", $VerifiedCount, [System.Drawing.Color]::FromArgb(52, 211, 153)),
        @("Unknown", $UnknownCount, [System.Drawing.Color]::FromArgb(250, 204, 21)),
        @("Sus", $SuspiciousCount, [System.Drawing.Color]::FromArgb(248, 113, 113)),
        @("Bypass", $BypassCount, [System.Drawing.Color]::FromArgb(216, 180, 254)),
        @("Obf", $ObfuscatedCount, [System.Drawing.Color]::FromArgb(251, 191, 36)),
        @("JVM", $JvmCount, [System.Drawing.Color]::FromArgb(251, 191, 36))
    )

    foreach ($row in $summaryRows) {
        $card = [System.Windows.Forms.Panel]::new()
        $card.Size = [System.Drawing.Size]::new(64, 42)
        $card.BackColor = $bg
        $card.Margin = [System.Windows.Forms.Padding]::new(4)

        $num = [System.Windows.Forms.Label]::new()
        $num.Text = [string]$row[1]
        $num.ForeColor = $row[2]
        $num.Font = [System.Drawing.Font]::new("Calibri", 16, [System.Drawing.FontStyle]::Bold)
        $num.TextAlign = "MiddleCenter"
        $num.Location = [System.Drawing.Point]::new(0, 0)
        $num.Size = [System.Drawing.Size]::new(64, 23)

        $cap = [System.Windows.Forms.Label]::new()
        $cap.Text = $row[0]
        $cap.ForeColor = [System.Drawing.Color]::White
        $cap.TextAlign = "MiddleCenter"
        $cap.Location = [System.Drawing.Point]::new(0, 24)
        $cap.Size = [System.Drawing.Size]::new(64, 18)
        $cap.Font = [System.Drawing.Font]::new("Calibri", 9, [System.Drawing.FontStyle]::Regular)

        $card.Controls.AddRange(@($num, $cap))
        $summary.Controls.Add($card)
    }

    $bypassReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($BypassMods)) {
        $lines = @("File: $($m.FileName)", "Path: $($m.FilePath)", "")
        $plain = Get-PlainEnglishRisk -Flags @($m.Flags)
        if ($plain.Count -gt 0) {
            $lines += "What this means:"
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
        }
        $lines += "Flags:"
        foreach ($flag in ($m.Flags | Sort-Object)) { $lines += "  - $flag" }
        $bypassReportItems.Add([PSCustomObject]@{ Name = Get-ReportListName $m.FileName; Detail = New-ReportText $lines }) | Out-Null
    }

    $obfReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($ObfuscatedMods)) {
        $lines = @("File: $($m.FileName)", "Path: $($m.FilePath)", "")
        $plain = Get-PlainEnglishRisk -Flags @($m.Flags)
        if ($plain.Count -gt 0) {
            $lines += "What this means:"
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
        }
        $lines += "Flags:"
        foreach ($flag in ($m.Flags | Sort-Object)) { $lines += "  - $flag" }
        $obfReportItems.Add([PSCustomObject]@{ Name = Get-ReportListName $m.FileName; Detail = New-ReportText $lines }) | Out-Null
    }

    $jvmReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($JvmFlags)) {
        $plain = Get-PlainEnglishRisk -Flags @($m)
        $lines = @("Runtime / launcher flag:", "")
        if ($plain.Count -gt 0) {
            $lines += "What this means:"
            foreach ($note in $plain) { $lines += "  - $note" }
            $lines += ""
        }
        $lines += [string]$m
        $jvmReportItems.Add([PSCustomObject]@{ Name = (($m -split " — ")[0]); Detail = New-ReportText $lines }) | Out-Null
    }

    $unknownReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($UnknownMods)) {
        $source = if ($m.DownloadSource) { $m.DownloadSource } else { "Unknown" }
        $unknownReportItems.Add([PSCustomObject]@{ Name = Get-ReportListName $m.FileName; Detail = New-ReportText @("File: $($m.FileName)", "Path: $($m.FilePath)", "Download source: $source") }) | Out-Null
    }

    $verifiedReportItems = [System.Collections.Generic.List[object]]::new()
    foreach ($m in @($VerifiedMods)) {
        $verifiedReportItems.Add([PSCustomObject]@{ Name = Get-ReportListName $m.FileName; Detail = New-ReportText @("Mod: $($m.ModName)", "File: $($m.FileName)", "Path: $($m.FilePath)") }) | Out-Null
    }

    $views = @(
        [PSCustomObject]@{ Title = "All Flags"; Count = $SuspiciousCount; Items = @($suspiciousReportItems); Color = $muted },
        [PSCustomObject]@{ Title = "Bypass"; Count = $BypassCount; Items = @($bypassReportItems); Color = $muted },
        [PSCustomObject]@{ Title = "Obfuscated"; Count = $ObfuscatedCount; Items = @($obfReportItems); Color = [System.Drawing.Color]::FromArgb(251, 191, 36) },
        [PSCustomObject]@{ Title = "JVM"; Count = $JvmCount; Items = @($jvmReportItems); Color = [System.Drawing.Color]::FromArgb(251, 191, 36) },
        [PSCustomObject]@{ Title = "Unknown"; Count = $UnknownCount; Items = @($unknownReportItems); Color = [System.Drawing.Color]::FromArgb(250, 204, 21) },
        [PSCustomObject]@{ Title = "Verified"; Count = $VerifiedCount; Items = @($verifiedReportItems); Color = [System.Drawing.Color]::FromArgb(52, 211, 153) }
    )

    $content = [System.Windows.Forms.Panel]::new()
    $content.Location = [System.Drawing.Point]::new(260, 210)
    $content.Size = [System.Drawing.Size]::new(750, 486)
    $content.Anchor = "Top,Bottom,Left,Right"
    $content.BackColor = $bg
    $contentTopLine = New-CwgiLine -X 18 -Y 0 -Width 600 -Color $muted

    $nav = [System.Windows.Forms.FlowLayoutPanel]::new()
    $nav.Location = [System.Drawing.Point]::new(20, 226)
    $nav.Size = [System.Drawing.Size]::new(180, 420)
    $nav.BackColor = $bg
    $nav.FlowDirection = "TopDown"
    $nav.WrapContents = $false
    $nav.Anchor = "Top,Bottom,Left"

    $list = [System.Windows.Forms.ListBox]::new()
    $list.Location = [System.Drawing.Point]::new(18, 18)
    $list.Size = [System.Drawing.Size]::new(280, 448)
    $list.BackColor = $bg
    $list.ForeColor = $text
    $list.BorderStyle = "None"
    $list.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Regular)
    $list.ItemHeight = 34
    $list.DrawMode = "OwnerDrawFixed"
    Enable-RoundedControl -Control $list -Radius 14
    $list.Anchor = "Top,Bottom,Left"

    $details = [System.Windows.Forms.RichTextBox]::new()
    $details.Location = [System.Drawing.Point]::new(318, 18)
    $details.Size = [System.Drawing.Size]::new(414, 448)
    $details.BackColor = $bg
    $details.ForeColor = $text
    $details.BorderStyle = "None"
    $details.ReadOnly = $true
    $details.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Regular)
    Enable-RoundedControl -Control $details -Radius 14
    $details.Anchor = "Top,Bottom,Left,Right"
    $list.Tag = $details
    $sectionDivider = New-CwgiLine -X 306 -Y 18 -Width 2 -Color $muted
    $sectionDivider.Size = [System.Drawing.Size]::new(2, 448)

    $list.Add_DrawItem({
        param($sender, $eventArgs)
        if ($eventArgs.Index -lt 0) { return }
        $isSelected = (($eventArgs.State -band [System.Windows.Forms.DrawItemState]::Selected) -eq [System.Windows.Forms.DrawItemState]::Selected)
        $rowBack = $bg
        $rowText = if ($isSelected) { $muted } else { [System.Drawing.Color]::White }
        $brushBack = [System.Drawing.SolidBrush]::new($rowBack)
        $brushText = [System.Drawing.SolidBrush]::new($rowText)
        $eventArgs.Graphics.FillRectangle($brushBack, $eventArgs.Bounds)
        $name = [string]$sender.Items[$eventArgs.Index].Name
        $rect = [System.Drawing.RectangleF]::new($eventArgs.Bounds.X + 12, $eventArgs.Bounds.Y + 8, $eventArgs.Bounds.Width - 20, $eventArgs.Bounds.Height - 8)
        $eventArgs.Graphics.DrawString($name, $sender.Font, $brushText, $rect)
        if ($isSelected) {
            $pen = [System.Drawing.Pen]::new($muted, 2)
            $eventArgs.Graphics.DrawLine($pen, $eventArgs.Bounds.X + 12, $eventArgs.Bounds.Bottom - 3, $eventArgs.Bounds.Right - 12, $eventArgs.Bounds.Bottom - 3)
            $pen.Dispose()
        }
        $brushBack.Dispose()
        $brushText.Dispose()
    })

    $list.Add_SelectedIndexChanged({
        param($sender, $eventArgs)
        $detailBox = [System.Windows.Forms.RichTextBox]$sender.Tag
        if ($sender.SelectedItem -and $detailBox) {
            $detailBox.Text = [string]$sender.SelectedItem.Detail
        }
    })

    $script:selectedNavButton = $null
    $loadView = {
        param($view, $button)
        if ($script:selectedNavButton) {
            $script:selectedNavButton.BackColor = $bg
            $script:selectedNavButton.ForeColor = [System.Drawing.Color]::White
            $script:selectedNavButton.FlatAppearance.BorderSize = 0
        }
        $button.BackColor = $bg
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatAppearance.BorderColor = $muted
        $button.FlatAppearance.BorderSize = 2
        $script:selectedNavButton = $button

        $list.Items.Clear()
        foreach ($item in @($view.Items)) { $list.Items.Add($item) | Out-Null }
        $list.DisplayMember = "Name"
        if ($list.Items.Count -gt 0) {
            $list.SelectedIndex = 0
            $details.Text = [string]$list.SelectedItem.Detail
        } else {
            $details.Text = "Nothing in $($view.Title)."
        }
    }

    foreach ($view in $views) {
        $button = [System.Windows.Forms.Button]::new()
        $button.Text = "$($view.Title)  $($view.Count)"
        $button.Size = [System.Drawing.Size]::new(180, 42)
        $button.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 4)
        Style-MillerButton -Button $button -BackColor $bg -HoverColor ([System.Drawing.Color]::FromArgb(35, 36, 40))
        $button.ForeColor = [System.Drawing.Color]::White
        $button.Font = [System.Drawing.Font]::new("Calibri", 10, [System.Drawing.FontStyle]::Bold)
        $button.Tag = $view
        $button.Add_Click({
            param($sender, $eventArgs)
            & $loadView $sender.Tag $sender
        })
        $nav.Controls.Add($button)
        $line = New-CwgiLine -X 0 -Y 0 -Width 170 -Color $muted
        $line.Margin = [System.Windows.Forms.Padding]::new(5, 0, 5, 9)
        $nav.Controls.Add($line)
    }

    $sidebar.Controls.AddRange(@($logo, $plugPanel, $nav))
    $content.Controls.AddRange(@($contentTopLine, $list, $sectionDivider, $details))
    & $loadView $views[0] $nav.Controls[0]

    $form.Controls.AddRange(@($sidebar, $title, $status, $statusLine, $fullscreenButton, $topCloseButton, $summary, $content))
    $null = $form.ShowDialog()
    $form.Dispose()
}

$currentFont = (Get-ItemProperty "HKCU:\Console" -ErrorAction SilentlyContinue).FaceName
if ($currentFont -notmatch "NSimSun|Gothic|Noto") {
    Write-Host "  Tip: To see all Unicode characters, set the terminal font to 'NSimSun'" -ForegroundColor DarkYellow
    Write-Host
}

$Banner = @"

  __  __ _ _ _            __  __           _ 
 |  \/  (_) | | ___ _ __ |  \/  | ___   __| |
 | |\/| | | | |/ _ \ '__|| |\/| |/ _ \ / _` |
 | |  | | | | |  __/ |   | |  | | (_) | (_| |
 |_|  |_|_|_|_|\___|_|   |_|  |_|\___/ \__,_|

              A N Y L S E R

          cwgi mod analyser

"@

Write-Host $Banner -ForegroundColor Cyan
Write-Host ""
Write-Host "                Made with " -ForegroundColor Gray -NoNewline
Write-Host "♥ " -ForegroundColor Red -NoNewline
Write-Host "by " -ForegroundColor Gray -NoNewline
Write-Host "cwgi" -ForegroundColor Cyan
Write-Host ""
Write-Host ("━" * 76) -ForegroundColor DarkCyan
Write-Host

$defaultModsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
$modsPath = Show-MillerFolderPicker -DefaultPath $defaultModsPath
if ([string]::IsNullOrWhiteSpace($modsPath)) {
    Write-Host "Scan cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "Continuing with " -NoNewline
Write-Host $modsPath -ForegroundColor White
Write-Host

if (-not (Test-Path $modsPath -PathType Container)) {
    Show-MillerInfoBox -Title "Invalid folder" -Message "The selected directory does not exist or is not accessible." -Icon Error
    Write-Host "❌ Invalid Path!" -ForegroundColor Red
    Write-Host "The directory does not exist or is not accessible." -ForegroundColor Yellow
    Write-Host
    Write-Host "Tried to access: $modsPath" -ForegroundColor Gray
    exit 1
}

Show-MillerProgressWindow
Update-MillerProgress -Phase "Finding jars, hidden folders, and Dfabric.addMods paths..." -Index 0 -Total 1 -FileName $modsPath

Write-Host "📁 Scanning directory: $modsPath" -ForegroundColor Green
Write-Host

$mcProcess = Get-Process javaw -ErrorAction SilentlyContinue
if (-not $mcProcess) {
    $mcProcess = Get-Process java -ErrorAction SilentlyContinue
}

if ($mcProcess) {
    try {
        $startTime = $mcProcess.StartTime
        $uptime = (Get-Date) - $startTime
        Write-Host "🕒 { Minecraft Uptime }" -ForegroundColor DarkCyan
        Write-Host "   $($mcProcess.Name) PID $($mcProcess.Id) started at $startTime" -ForegroundColor Gray
        Write-Host "   Running for: $($uptime.Hours)h $($uptime.Minutes)m $($uptime.Seconds)s" -ForegroundColor Gray
        Write-Host ""
    } catch { }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$suspiciousPatterns = @(
    "AimAssist", "AnchorTweaks", "AutoAnchor", "AutoCrystal", "AutoDoubleHand",
    "AutoHitCrystal", "AutoPot", "AutoTotem", "AutoArmor", "InventoryTotem",
    "JumpReset", "LegitTotem", "PingSpoof", "SelfDestruct",
    "ShieldBreaker", "TriggerBot", "AxeSpam", "WebMacro",
    "FastPlace", "WalskyOptimizer", "WalksyOptimizer", "walsky.optimizer",
    "WalksyCrystalOptimizerMod", "Donut", "Replace Mod",
    "ShieldDisabler", "SilentAim", "Totem Hit", "Wtap", "FakeLag",
    "BlockESP", "dev.krypton", "Virgin", "AntiMissClick",
    "LagReach", "PopSwitch", "SprintReset", "ChestSteal", "AntiBot",
    "ElytraSwap", "FastXP", "FastExp", "Refill",  "AirAnchor",
    "jnativehook", "FakeInv", "HoverTotem", "AutoClicker", "AutoFirework",
    "PackSpoof", "Antiknockback", "catlean", "Argon",
    "AuthBypass", "Asteria", "Prestige", "AutoEat", "AutoMine",
    "MaceSwap", "DoubleAnchor", "AutoTPA", "BaseFinder", "Xenon", "gypsy",
    "Grim", "grim",
    "org.chainlibs.module.impl.modules.Crystal.Y",
    "org.chainlibs.module.impl.modules.Crystal.bF",
    "org.chainlibs.module.impl.modules.Crystal.bM",
    "org.chainlibs.module.impl.modules.Crystal.bY",
    "org.chainlibs.module.impl.modules.Crystal.bq",
    "org.chainlibs.module.impl.modules.Crystal.cv",
    "org.chainlibs.module.impl.modules.Crystal.o",
    "org.chainlibs.module.impl.modules.Blatant.I",
    "org.chainlibs.module.impl.modules.Blatant.bR",
    "org.chainlibs.module.impl.modules.Blatant.bx",
    "org.chainlibs.module.impl.modules.Blatant.cj",
    "org.chainlibs.module.impl.modules.Blatant.dk",
    "imgui.gl3", "imgui.glfw",
    "BowAim", "Criticals", "Fakenick", "FakeItem",
    "invsee", "ItemExploit", "Hellion", "hellion",
    "LicenseCheckMixin", "ClientPlayerInteractionManagerAccessor",
    "ClientPlayerEntityMixim", "dev.gambleclient", "obfuscatedAuth",
    "phantom-refmap.json", "xyz.greaj",
    "じ.class", "ふ.class", "ぶ.class", "ぷ.class", "た.class",
    "ね.class", "そ.class", "な.class", "ど.class", "ぐ.class",
    "ず.class", "で.class", "つ.class", "べ.class", "せ.class",
    "と.class", "み.class", "び.class", "す.class", "の.class"
)

$cheatStrings = @(
    "AutoCrystal", "autocrystal", "auto crystal", "cw crystal",
    "dontPlaceCrystal", "dontBreakCrystal",
    "AutoHitCrystal", "autohitcrystal", "canPlaceCrystalServer", "healPotSlot",
    "ＡｕｔｏＣｒｙｓｔａｌ", "Ａｕｔｏ Ｃｒｙｓｔａｌ",
    "ＡｕｔｏＨｉｔＣｒｙｓｔａｌ",
    "AutoAnchor", "autoanchor", "auto anchor", "DoubleAnchor",
     "HasAnchor", "anchortweaks", "anchor macro", "safe anchor", "safeanchor",
    "SafeAnchor", "AirAnchor",
    "ＡｕｔｏＡｎｃｈｏｒ", "Ａｕｔｏ Ａｎｃｈｏｒ",
    "ＤｏｕｂｌｅＡｎｃｈｏｒ", "Ｄｏｕｂｌｅ Ａｎｃｈｏｒ",
    "ＳａｆｅＡｎｃｈｏｒ", "Ｓａｆｅ Ａｎｃｈｏｒ",
    "Ａｎｃｈｏｒ Ｍａｃｒｏ", "anchorMacro",
    "AutoTotem", "autototem", "auto totem", "InventoryTotem",
    "inventorytotem", "HoverTotem", "hover totem", "legittotem",
    "ＡｕｔｏＴｏｔｅｍ", "Ａｕｔｏ Ｔｏｔｅｍ",
    "ＨｏｖｅｒＴｏｔｅｍ", "Ｈｏｖｅｒ Ｔｏｔｅｍ",
    "ＩｎｖｅｎｔｏｒｙＴｏｔｅｍ", "Ａｕｔｏ Ｉｎｖｅｎｔｏｒｙ Ｔｏｔｅｍ",
    "Ａｕｔｏ Ｔｏｔｅｍ Ｈｉｔ",
    "AutoPot", "autopot", "auto pot", "speedPotSlot", "strengthPotSlot",
    "AutoArmor", "autoarmor", "auto armor",
    "ＡｕｔｏＰｏｔ", "Ａｕｔｏ Ｐｏｔ",
    "Ａｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ", "AutoPotRefill",
    "ＡｕｔｏＡｒｍｏｒ", "Ａｕｔｏ Ａｒｍｏｒ",
    "preventSwordBlockBreaking", "preventSwordBlockAttack",
    "ShieldDisabler", "ShieldBreaker",
    "ＳｈｉｅｌｄＤｉｓａｂｌｅｒ", "Ｓｈｉｅｌｄ Ｄｉｓａｂｌｅｒ",
    "Breaking shield with axe...",
    "AutoDoubleHand", "autodoublehand", "auto double hand",
    "ＡｕｔｏＤｏｕｂｌｅＨａｎｄ", "Ａｕｔｏ Ｄｏｕｂｌｅ Ｈａｎｄ",
    "AutoClicker",
    "ＡｕｔｏＣｌｉｃｋｅｒ",
    "Failed to switch to mace after axe!",
    "AutoMace", "MaceSwap", "SpearSwap",
    "ＡｕｔｏＭａｃｅ", "Ａｕｔｏ Ｍａｃｅ",
    "ＭａｃｅＳｗａｐ", "Ｍａｃｅ Ｓｗａｐ",
    "Ｓｐｅａｒ Ｓｗａｐ", "Ａｕｔｏｍａｔｉｃａｌｌｙ ａｘｅ ａｎｄ ｍａｃｅ ｓｈｉｅｌｄｅｄ ｐｌａｙｅｒｓ",
    "Ｓｔｕｎ Ｓｌａｍ", "StunSlam",
    "Donut", "JumpReset", "axespam", "axe spam",
    "EndCrystalItemMixin",
    "findKnockbackSword", "attackRegisteredThisClick",
    "AimAssist", "aimassist", "aim assist",
    "triggerbot", "trigger bot",
    "ＡｉｍＡｓｓｉｓｔ", "Ａｉｍ Ａｓｓｉｓｔ",
    "ＴｒｉｇｇｅｒＢｏｔ", "Ｔｒｉｇｇｅｒ Ｂｏｔ",
    "Silent Rotations", "SilentRotations",
    "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "FakeInv", "swapBackToOriginalSlot",
    "FakeLag", "pingspoof", "ping spoof",
    "ＦａｋｅＬａｇ", "Ｆａｋｅ Ｌａｇ",
    "fakePunch", "Fake Punch",
    "Ｆａｋｅ Ｐｕｎｃｈ",
    "webmacro", "web macro",
    "AntiWeb", "AutoWeb",
    "Ａｎｔｉ Ｗｅｂ", "ＡｕｔｏＷｅｂ",
    "Ｐｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "lvstrng", "dqrkis", "selfdestruct", "self destruct",
    "WalksyCrystalOptimizerMod", "WalksyOptimizer", "WalskyOptimizer",
    "Ｗａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ",
    "autoCrystalPlaceClock",
    "AutoFirework", "ElytraSwap", "FastXP", "FastExp", "NoJumpDelay",
    "ＥｌｙｔｒａＳｗａｐ", "Ｅｌｙｔｒａ Ｓｗａｐ",
    "PackSpoof", "Antiknockback", "catlean",
    "AuthBypass", "obfuscatedAuth", "LicenseCheckMixin",
    "BaseFinder", "invsee", "ItemExploit",
    "FreezePlayer",
    "Ｆｒｅｅｃａｍ", "Ｍｏｖｅ ｆｒｅｅｌｙ ｔｈｒｏｕｇｈ ｗａｌｌｓ",
    "Ｎｏ Ｃｌｉｐ", "Ｆｒｅｅｚｅ Ｐｌａｙｅｒ",
    "LWFH Crystal",
    "ＬＷＦＨ Ｃｒｙｓｔａｌ",
    "KeyPearl", "LootYeeter",
    "ＫｅｙＰｅａｒｌ", "Ｋｅｙ Ｐｅａｒｌ",
    "Ｌｏｏｔ Ｙｅｅｔｅｒ",
    "FastPlace",
    "Ｆａｓｔ Ｐｌａｃｅ", "Ｐｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅｒ",
    "AutoBreach",
    "Ａｕｔｏ Ｂｒｅａｃｈ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown",
    "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem",
    "arrayOfString", "POT_CHEATS",
    "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃｔｉｖａｔｅ Ｋｅｙ",
    "Click Simulation", "Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ",
    "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ",
    "No Bounce", "NoBounce", "Ｎｏ Ｂｏｕｎｃｅ", "ＮｏＢｏｕｎｃｅ",
    "Ｒｅｍｏｖｅｓ ｔｈｅ ｃｒｙｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Place Delay", "Ｐｌａｃｅ Ｄｅｌａｙ",
    "Break Delay", "Ｂｒｅａｋ Ｄｅｌａｙ",
    "Fast Mode", "Ｆａｓｔ Ｍｏｄｅ",
    "Place Chance", "Ｐｌａｃｅ Ｃｈａｎｃｅ",
    "Break Chance", "Ｂｒｅａｋ Ｃｈａｎｃｅ",
    "Stop On Kill", "Ｓｔｏｐ Ｏｎ Ｋｉｌｌ",
    "Ｄａｍａｇｅ Ｔｉｃｋ", "damagetick",
    "Anti Weakness", "Ａｎｔｉ Ｗｅａｋｎｅｓｓ",
    "Particle Chance", "Ｐａｒｔｉｃｌｅ Ｃｈａｎｃｅ",
    "Trigger Key", "Ｔｒｉｇｇｅｒ Ｋｅｙ",
    "Switch Delay", "Ｓｗｉｔｃｈ Ｄｅｌａｙ",
    "Totem Slot", "Ｔｏｔｅｍ Ｓｌｏｔ",
    "Silent Rotations", "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "Smooth Rotations", "Ｓｍｏｏｔｈ Ｒｏｔａｔｉｏｎｓ",
    "Rotation Speed", "Ｒｏｔａｔｉｏｎ Ｓｐｅｅｄ",
    "Use Easing", "Ｕｓｅ Ｅａｓｉｎｇ",
    "Easing Strength", "Ｅａｓｉｎｇ Ｓｔｒｅｎｇｔｈ",
    "While Use", "Ｗｈｉｌｅ Ｕｓｅ",
    "Stop on Kill", "Ｓｔｏｐ ｏｎ Ｋｉｌｌ",
    "Click Simulation", "Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ",
    "Glowstone Delay", "Ｇｌｏｗｓｔｏｎｅ Ｄｅｌａｙ",
    "Glowstone Chance", "Ｇｌｏｗｓｔｏｎｅ Ｃｈａｎｃｅ",
    "Explode Delay", "Ｅｘｐｌｏｄｅ Ｄｅｌａｙ",
    "Explode Chance", "Ｅｘｐｌｏｄｅ Ｃｈａｎｃｅ",
    "Explode Slot", "Ｅｘｐｌｏｄｅ Ｓｌｏｔ",
    "Only Charge", "Ｏｎｌｙ Ｃｈａｒｇｅ",
    "Anchor Macro", "Ａｎｃｈｏｒ Ｍａｃｒｏ",
    "Reach Distance", "Ｒｅａｃｈ Ｄｉｓｔａｎｃｅ",
    "Min Height", "Ｍｉｎ Ｈｅｉｇｈｔ",
    "Min Fall Speed", "Ｍｉｎ Ｆａｌｌ Ｓｐｅｅｄ",
    "Attack Delay", "Ａｔｔａｃｋ Ｄｅｌａｙ",
    "Breach Delay", "Ｂｒｅａｃｈ Ｄｅｌａｙ",
    "Require Elytra", "Ｒｅｑｕｉｒｅ Ｅｌｙｔｒａ",
    "Auto Switch Back", "Ａｕｔｏ Ｓｗｉｔｃｈ Ｂａｃｋ",
    "Check Line of Sight", "Ｃｈｅｃｋ Ｌｉｎｅ ｏｆ Ｓｉｇｈｔ",
    "Only When Falling", "Ｏｎｌｙ Ｗｈｅｎ Ｆａｌｌｉｎｇ",
    "Require Crit", "Ｒｅｑｕｉｒｅ Ｃｒｉｔ",
    "Show Status Display", "Ｓｈｏｗ Ｓｔａｔｕｓ Ｄｉｓｐｌａｙ",
    "Stop On Crystal", "Ｓｔｏｐ Ｏｎ Ｃｒｙｓｔａｌ",
    "Check Shield", "Ｃｈｅｃｋ Ｓｈｉｅｌｄ",
    "On Pop", "Ｏｎ Ｐｏｐ",
    "Predict Damage", "Ｐｒｅｄｉｃｔ Ｄａｍａｇｅ",
    "On Ground", "Ｏｎ Ｇｒｏｕｎｄ",
    "Check Players", "Ｃｈｅｃｋ Ｐｌａｙｅｒｓ",
    "Predict Crystals", "Ｐｒｅｄｉｃｔ Ｃｒｙｓｔａｌｓ",
    "Check Aim", "Ｃｈｅｃｋ Ａｉｍ",
    "Check Items", "Ｃｈｅｃｋ Ｉｔｅｍｓ",
    "Activates Above", "Ａｃｔｉｖａｔｅｓ Ａｂｏｖｅ",
    "Blatant", "Ｂｌａｔａｎｔ",
    "Force Totem", "Ｆｏｒｃｅ Ｔｏｔｅｍ",
    "Stay Open For", "Ｓｔａｙ Ｏｐｅｎ Ｆｏｒ",
    "Auto Inventory Totem", "Ａｕｔｏ Ｉｎｖｅｎｔｏｒｙ Ｔｏｔｅｍ",
    "Only On Pop", "Ｏｎｌｙ Ｏｎ Ｐｏｐ",
    "Vertical Speed", "Ｖｅｒｔｉｃａｌ Ｓｐｅｅｄ",
    "Hover Totem", "Ｈｏｖｅｒ Ｔｏｔｅｍ",
    "Swap Speed", "Ｓｗａｐ Ｓｐｅｅｄ",
    "Strict One-Tick", "Ｓｔｒｉｃｔ Ｏｎｅ－Ｔｉｃｋ",
    "Mace Priority", "Ｍａｃｅ Ｐｒｉｏｒｉｔｙ",
    "Min Totems", "Ｍｉｎ Ｔｏｔｅｍｓ",
    "Min Pearls", "Ｍｉｎ Ｐｅａｒｌｓ",
    "Totem First", "Ｔｏｔｅｍ Ｆｉｒｓｔ",
    "Drop Interval", "Ｄｒｏｐ Ｉｎｔｅｒｖａｌ",
    "Random Pattern", "Ｒａｎｄｏｍ Ｐａｔｔｅｒｎ",
    "Loot Yeeter", "Ｌｏｏｔ Ｙｅｅｔｅｒ",
    "Horizontal Aim Speed", "Ｈｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ",
    "Vertical Aim Speed", "Ｖｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ",
    "Include Head", "Ｉｎｃｌｕｄｅ Ｈｅａｄ",
    "Web Delay", "Ｗｅｂ Ｄｅｌａｙ",
    "Holding Web", "Ｈｏｌｄｉｎｇ Ｗｅｂ",
    "Not When Affects Player", "Ｎｏｔ Ｗｈｅｎ Ａｆｆｅｃｔｓ Ｐｌａｙｅｒ",
    "Hit Delay", "Ｈｉｔ Ｄｅｌａｙ",
    "Ｓｗｉｔｃｈ Ｂａｃｋ",
    "Require Hold Axe", "Ｒｅｑｕｉｒｅ Ｈｏｌｄ Ａｘｅ",
    "Fake Punch", "Ｆａｋｅ Ｐｕｎｃｈ",
    "placeInterval", "breakInterval", "stopOnKill",
    "activateOnRightClick", "holdCrystal",
    "ｐｌａｃｅＩｎｔｅｒｖａｌ", "ｂｒｅａｋＩｎｔｅｒｖａｌ",
    "ｓｔｏｐＯｎＫｉｌｌ", "ａｃｔｉｖａｔｅＯｎＲｉｇｈｔＣｌｉｃｋ",
    "ｄａｍａｇｅｔｉｃｋ", "ｈｏｌｄＣｒｙｓｔａｌ",
    "ｆａｋｅＰｕｎｃｈ",
    "Ｒｅｆｉｌｌｓ ｙｏｕｒ ｈｏｔｂａｒ ｗｉｔｈ ｐｏｔｉｏｎｓ",
    "Ｋｅｐｓ ｙｏｕ ｓｐｒｉｎｔｉｎｇ ａｔ ａｌｌ ｔｉｍｅｓ",
    "Ｐｌａｃｅｓ ａｎｃｈｏｒ， ｃｈａｒｇｅｓ ｉｔ， ｐｒｏｔｅｃｔｓ ｙｏｕ， ａｎｄ ｅｘｐｌｏｄｅｓ",
    "Ａｕｔｏ ｓｗａｐ ｔｏ ｓｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Macro Key", "Ａｕｔｏ Ｐｏｔ", "Ｍａｃｒｏ Ｋｅｙ",
    "KillAura", "ClickAura", "MultiAura", "ForceField", "LegitAura",
    "AimBot", "AutoAim", "SilentAim", "AimLock", "HeadSnap",
    "CrystalAura",
    "AnchorAura", "AnchorFill", "AnchorPlace",
    "BedAura", "AutoBed", "BedBomb", "BedPlace",
    "BowAimbot", "BowSpam", "AutoBow",
    "AutoCrit", "CritBypass", "AlwaysCrit", "CriticalHit",
    "ReachHack", "ExtendReach", "LongReach", "HitboxExpand",
    "AntiKB", "NoKnockback", "GrimVelocity", "GrimDisabler", "VelocitySpoof", "KBReduce",
    "OffhandTotem", "TotemSwitch",
    "AutoWeapon", "AutoSword", "AutoCity", "Burrow", "SelfTrap",
    "HoleFiller", "AntiSurround", "AntiBurrow",
    "WTap", "TargetStrafe", "AutoGap", "AutoPearl",
    "FlyHack", "CreativeFlight", "BoatFly", "PacketFly", "AirJump",
    "SpeedHack", "BHop", "BunnyHop",
    "AntiFall", "NoFallDamage", "SafeFall",
    "StepHack", "FastClimb", "AutoStep", "HighStep",
    "WaterWalk", "LiquidWalk", "LavaWalk",
    "NoSlow", "NoSlowdown", "NoWeb", "NoSoulSand",
    "WallHack",
    "ElytraSpeed", "InstantElytra",
    "ScaffoldWalk", "FastBridge", "BuildHelper", "AutoBridge",
    "Nuker", "NukerLegit", "InstantBreak",
    "GhostHand", "NoSwing",
    "PlaceAssist", "AirPlace", "AutoPlace", "InstantPlace",
    "PlayerESP", "MobESP", "ItemESP", "StorageESP", "ChestESP",
    "Tracers", "NameTagsHack",
    "XRayHack", "OreFinder", "CaveFinder", "OreESP",
    "NewChunks", "ChunkBorders", "TunnelFinder",
    "TargetHUD", "ReachDisplay",
    "DoubleClicker", "JitterClick", "ButterflyClick", "CPSBoost",
    "ChestStealer", "InvManager", "InvMovebypass",
    "AutoSprint", "AntiAFK", "AutoRespawn",
    "FakeNick", "PopSwitch",
    "FakeLatency", "FakePing", "SpoofRotation", "PositionSpoof",
    "GameSpeed", "SpeedTimer",
     "GrimBypass", "VulcanBypass", "MatrixBypass",
    "AACBypass", "VerusDisabler", "IntaveBypass", "WatchdogBypass",
    "PacketMine", "PacketWalk", "PacketSneak", "PacketCancel", "PacketDupe", "PacketSpam",
    "SelfDestruct", "HideClient",
    "SessionStealer", "TokenLogger", "TokenGrabber", "DiscordToken",
    "RemoteAccess", "ReverseShell", "C2Server", "Backdoor", "KeyLogger",
    "StashFinder", "TrailFinder",
    "imgui.binding",
    "JNativeHook", "GlobalScreen", "NativeKeyListener",
    "client-refmap.json", "cheat-refmap.json",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    "meteordevelopment", "cc/novoline",
    "com/alan/clients", "club/maxstats", "wtf/moonlight",
    "me/zeroeightsix/kami", "net/ccbluex", "today/opai",
    "net/minecraft/injection", "org/chainlibs/module/impl/modules",
    "xyz/greaj", "com/cheatbreaker", "com/moonsworth",
    "doomsdayclient", "DoomsdayClient", "doomsday.jar",
    "novaclient", "api.novaclient.lol",
    "WalksyOptimizer", "LWFH Crystal",
    "vape.gg", "vapeclient", "VapeClient", "VapeLite",
    "intent.store", "IntentClient",
    "rise.today", "riseclient.com",
    "meteor-client", "meteorclient", "meteordevelopment.meteorclient",
    "liquidbounce", "fdp-client", "net.ccbluex",
    "novoware", "novoclient",
    "aristois", "impactclient", "azura",
    "pandaware", "skilled", "moonClient", "astolfo",
    "futureClient", "konas", "rusherhack", "inertia", "exhibition"
)

$patternRegex = [regex]::new(
    '(?<![A-Za-z])(' + ($suspiciousPatterns -join '|') + ')(?![A-Za-z])',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

$cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }

function Get-FileSHA1 {
    param([string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA1).Hash
}

function Get-DownloadSource {
    param([string]$Path)
    $zoneData = Get-Content -Raw -Stream Zone.Identifier $Path -ErrorAction SilentlyContinue
    if ($zoneData -match "HostUrl=(.+)") {
        $url = $matches[1].Trim()
        if ($url -match "mediafire\.com")                                        { return "MediaFire" }
        elseif ($url -match "discord\.com|discordapp\.com|cdn\.discordapp\.com") { return "Discord" }
        elseif ($url -match "dropbox\.com")                                      { return "Dropbox" }
        elseif ($url -match "drive\.google\.com")                                { return "Google Drive" }
        elseif ($url -match "mega\.nz|mega\.co\.nz")                             { return "MEGA" }
        elseif ($url -match "github\.com")                                       { return "GitHub" }
        elseif ($url -match "modrinth\.com")                                     { return "Modrinth" }
        elseif ($url -match "curseforge\.com")                                   { return "CurseForge" }
        elseif ($url -match "anydesk\.com")                                      { return "AnyDesk" }
        elseif ($url -match "doomsdayclient\.com")                               { return "DoomsdayClient" }
        elseif ($url -match "prestigeclient\.vip")                               { return "PrestigeClient" }
        elseif ($url -match "198macros\.com")                                    { return "198Macros" }
        elseif ($url -match "dqrkis\.xyz")                                       { return "Dqrkis" }
        else {
            if ($url -match "https?://(?:www\.)?([^/]+)") { return $matches[1] }
            return $url
        }
    }
    return $null
}

function Get-ModRelativePath {
    param(
        [string]$BasePath,
        [string]$FilePath
    )

    try {
        $baseFull = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\') + '\'
        $fileFull = [System.IO.Path]::GetFullPath($FilePath)
        if (-not $fileFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $fileFull
        }
        $baseUri = [System.Uri]::new($baseFull)
        $fileUri = [System.Uri]::new($fileFull)
        return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('/', '\')
    } catch {
        return [System.IO.Path]::GetFileName($FilePath)
    }
}

function Get-FabricAddModsValues {
    param([string]$CommandText)

    $values = [System.Collections.Generic.List[string]]::new()
    if ([string]::IsNullOrWhiteSpace($CommandText)) { return $values }

    $matches = [regex]::Matches($CommandText, '(?i)(?:^|\s)-?Dfabric\.addMods(?:=|\s+)(?:"([^"]+)"|''([^'']+)''|([^\s]+))')
    foreach ($m in $matches) {
        $value = ($m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value | Where-Object { $_ } | Select-Object -First 1)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $values.Add($value) | Out-Null
        }
    }

    return $values
}

function Get-FabricAddModsJarFiles {
    $paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    function Add-FabricPathValue {
        param([string]$Value)

        if ([string]::IsNullOrWhiteSpace($Value)) { return }

        $expanded = [Environment]::ExpandEnvironmentVariables($Value.Trim().Trim().Trim('"').Trim("'").TrimEnd(',', ';').Trim('"').Trim("'"))
        $parts = $expanded -split ';'
        foreach ($part in $parts) {
            $candidate = $part.Trim().Trim('"').Trim("'").TrimEnd(',', ';').Trim('"').Trim("'")
            if ([string]::IsNullOrWhiteSpace($candidate)) { continue }

            try {
                if ($candidate.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ge 0) { continue }
                if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                    if ([System.IO.Path]::GetExtension($candidate) -ieq ".jar") {
                        $paths.Add([System.IO.Path]::GetFullPath($candidate)) | Out-Null
                    }
                } elseif (Test-Path -LiteralPath $candidate -PathType Container) {
                    Get-ChildItem -LiteralPath $candidate -Filter *.jar -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
                        $paths.Add($_.FullName) | Out-Null
                    }
                }
            } catch { }
        }
    }

    $javaProcs = @(
        Get-Process javaw -ErrorAction SilentlyContinue
        Get-Process java  -ErrorAction SilentlyContinue
    )

    foreach ($proc in $javaProcs) {
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction Stop
            foreach ($value in (Get-FabricAddModsValues -CommandText $wmi.CommandLine)) {
                Add-FabricPathValue -Value $value
            }
        } catch { }
    }

    try {
        $launcherProfiles = Join-Path $env:APPDATA ".minecraft\launcher_profiles.json"
        if (Test-Path $launcherProfiles -PathType Leaf) {
            $profileText = Get-Content -LiteralPath $launcherProfiles -Raw -ErrorAction Stop
            foreach ($value in (Get-FabricAddModsValues -CommandText $profileText)) {
                Add-FabricPathValue -Value $value
            }
        }
    } catch { }

    return @($paths)
}

function Query-Modrinth {
    param([string]$Hash)
    try {
        $versionInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$Hash" -Method Get -UseBasicParsing -ErrorAction Stop
        if ($versionInfo.project_id) {
            $projectInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($versionInfo.project_id)" -Method Get -UseBasicParsing -ErrorAction Stop
            return @{ Name = $projectInfo.title; Slug = $projectInfo.slug }
        }
    } catch { }
    return @{ Name = ""; Slug = "" }
}

function Query-Megabase {
    param([string]$Hash)
    try {
        $result = Invoke-RestMethod -Uri "https://megabase.vercel.app/api/query?hash=$Hash" -Method Get -UseBasicParsing -ErrorAction Stop
        if (-not $result.error) { return $result.data }
    } catch { }
    return $null
}

$fullwidthRegex = [regex]::new(
    "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

function Invoke-ModScan {
    param([string]$FilePath)

    $foundPatterns  = [System.Collections.Generic.HashSet[string]]::new()
    $foundStrings   = [System.Collections.Generic.HashSet[string]]::new()
    $foundFullwidth = [System.Collections.Generic.HashSet[string]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        foreach ($entry in $archive.Entries) {
            foreach ($m in $patternRegex.Matches($entry.FullName)) {
                [void]$foundPatterns.Add($m.Value)
            }
        }

        $allEntries    = [System.Collections.Generic.List[object]]::new()
        $innerArchives = [System.Collections.Generic.List[object]]::new()

        foreach ($e in $archive.Entries) { $allEntries.Add($e) }

        foreach ($nj in ($archive.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })) {
            try {
                $ns = $nj.Open()
                $ms = New-Object System.IO.MemoryStream
                $ns.CopyTo($ms); $ns.Close()
                $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $innerArchives.Add($iz)
                foreach ($ie in $iz.Entries) { $allEntries.Add($ie) }
            } catch { }
        }

        foreach ($entry in $allEntries) {
            $name = $entry.FullName

            if ($name -match '\.(class|json)$' -or $name -match 'MANIFEST\.MF') {
                try {
                    $st = $entry.Open()
                    $ms2 = New-Object System.IO.MemoryStream
                    $st.CopyTo($ms2); $st.Close()
                    $bytes = $ms2.ToArray(); $ms2.Dispose()

                    $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
                    $utf8  = [System.Text.Encoding]::UTF8.GetString($bytes)

                    foreach ($m in $patternRegex.Matches($ascii)) { [void]$foundPatterns.Add($m.Value) }

                    foreach ($s in $cheatStringSet) {
                        if ($ascii.Contains($s)) { [void]$foundStrings.Add($s); continue }
                        if ($utf8.Contains($s))  { [void]$foundStrings.Add($s) }
                    }

                    foreach ($m in $fullwidthRegex.Matches($utf8)) {
                        [void]$foundFullwidth.Add($m.Value)
                    }
                } catch { }
            }
        }

        foreach ($ia in $innerArchives) { try { $ia.Dispose() } catch { } }
        $archive.Dispose()
    } catch { }

    $fwCheatPool = @($script:cheatStrings | Where-Object {
        $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]"
    })
    $resolvedFullwidth = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in @($foundFullwidth)) {
        if ($fw.Length -lt 3) { continue }
        $bestMatch = $null
        foreach ($cs in $fwCheatPool) {
            if ($cs.Contains($fw)) {
                if ($null -eq $bestMatch -or $cs.Length -lt $bestMatch.Length) {
                    $bestMatch = $cs
                }
            }
        }
        if ($null -ne $bestMatch) {
            [void]$resolvedFullwidth.Add($bestMatch)
        } elseif ($fw.Length -ge 6) {
            [void]$resolvedFullwidth.Add($fw)
        }
    }
    $resolved = @($resolvedFullwidth)
    $finalFullwidth = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in $resolved) {
        $isRedundant = $false
        foreach ($other in $resolved) {
            if ($fw.Length -lt $other.Length -and $other.Contains($fw)) {
                $isRedundant = $true; break
            }
        }
        if (-not $isRedundant) { [void]$finalFullwidth.Add($fw) }
    }

    return @{ Patterns = $foundPatterns; Strings = $foundStrings; Fullwidth = $finalFullwidth }
}

function Invoke-ObfuscationScan {
    param([string]$FilePath)

    $flags = [System.Collections.Generic.List[string]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        $totalClass    = 0
        $numericCount  = 0
        $unicodeCount  = 0
        $fullwidthCount= 0
        $japaneseCount = 0
        $singleLetterCount = 0
        $twoLetterCount    = 0
        $gibberishCount    = 0
        $noVowelCount      = 0
        $confusionCount    = 0
        $singleCharPkg     = 0
        $contentSample     = [System.Text.StringBuilder]::new()
        $sampleSize        = 0

        $cheatObfuscators = @{
            "Skidfuscator"   = @("dev/skidfuscator", "Skidfuscator", "skidfuscator.dev")
            "Paramorphism"   = @("Paramorphism", "paramorphism-", "dev/paramorphism")
            "Radon"          = @("ItzSomebody/Radon", "me/itzsomebody/radon", "Radon Obfuscator")
            "Caesium"        = @("sim0n/Caesium", "Caesium Obfuscator", "dev/sim0n/caesium")
            "Bozar"          = @("vimasig/Bozar", "Bozar Obfuscator", "com/bozar")
            "Branchlock"     = @("Branchlock", "branchlock.dev")
            "Binscure"       = @("Binscure", "com/binscure")
            "SuperBlaubeere" = @("superblaubeere", "superblaubeere27")
            "Qprotect"       = @("Qprotect", "QProtect", "mdma.dev/qprotect")
            "Zelix"          = @("ZKMFLOW", "ZKM", "ZelixKlassMaster", "com/zelix")
            "Stringer"       = @("StringerJavaObfuscator", "com/licel/stringer")
            "JNIC"           = @("JNIC", "jnic.obf", "jnic-obfuscator")
            "Scuti"          = @("ScutiObf", "scuti.obf")
            "Smoke"          = @("SmokeObf", "smoke.obf")
        }

        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName

            if ($name -match "\.class$") {
                $totalClass++
                $className = [System.IO.Path]::GetFileNameWithoutExtension(($name -split "/")[-1])

                if ($className -match "^\d+$")                          { $numericCount++ }
                if ($className -match "[^\x00-\x7F]")                   { $unicodeCount++ }
                if ($className -match "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]") { $fullwidthCount++ }
                if ($className -match "[\u3040-\u309F\u30A0-\u30FF]")  { $japaneseCount++ }
                if ($className -match "^[a-zA-Z]$")                     { $singleLetterCount++ }
                if ($className -match "^[a-zA-Z]{2}$")                  { $twoLetterCount++ }
                if ($className -match "^[Il1O0]+$" -or $className -match "^[_]+$") { $confusionCount++ }

                if ($className.Length -ge 3 -and $className.Length -le 8 -and $className -match "^[a-zA-Z]+$") {
                    $vowels = ($className.ToCharArray() | Where-Object { $_ -match "[aeiouAEIOU]" }).Count
                    if ($vowels -eq 0) { $noVowelCount++ }
                    $hasCluster = $className -match "[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{3,}"
                    if ($hasCluster -and ($vowels / $className.Length) -lt 0.3) { $gibberishCount++ }
                }

                $segs = ($name -replace "\.class$", "") -split "/"
                foreach ($seg in $segs[0..($segs.Count - 2)]) {
                    if ($seg.Length -eq 1) { $singleCharPkg++ }
                }

                if ($sampleSize -lt 150000 -and $entry.Length -lt 100000 -and $entry.Length -gt 100) {
                    try {
                        $st = $entry.Open()
                        $ms = New-Object System.IO.MemoryStream
                        $st.CopyTo($ms); $st.Close()
                        $ascii = [System.Text.Encoding]::ASCII.GetString($ms.ToArray())
                        $ms.Dispose()
                        [void]$contentSample.Append($ascii)
                        $sampleSize += $ascii.Length
                    } catch { }
                }
            }
        }

        $archive.Dispose()

        if ($totalClass -lt 5) { return $flags }

        $pct = { param($n) [math]::Round(($n / $totalClass) * 100) }

        $numPct   = & $pct $numericCount
        $uniPct   = & $pct $unicodeCount
        $fwPct    = & $pct $fullwidthCount
        $jpPct    = & $pct $japaneseCount
        $s1Pct    = & $pct $singleLetterCount
        $s2Pct    = & $pct $twoLetterCount
        $gibPct   = & $pct $gibberishCount
        $novPct   = & $pct $noVowelCount
        $confPct  = & $pct $confusionCount

        if ($numPct   -ge 20) { $flags.Add("Numeric class names — $numPct% of classes have numeric-only names") }
        if ($uniPct   -ge 10) { $flags.Add("Unicode class names — $uniPct% of classes use non-ASCII characters") }
        if ($fwPct    -gt  0) { $flags.Add("Fullwidth Unicode class names — $fwPct% use ａｂｃ/ＡＢＣ/０１２ chars ($fullwidthCount classes)") }
        if ($jpPct    -gt  0) { $flags.Add("Japanese obfuscation — $jpPct% use hiragana/katakana class names ($japaneseCount classes)") }
        if ($s1Pct    -ge 15) { $flags.Add("Single-letter class names — $s1Pct% ($singleLetterCount classes)") }
        if ($s2Pct    -ge 20) { $flags.Add("Two-letter class names — $s2Pct% ($twoLetterCount classes)") }
        if ($gibPct   -ge  5) { $flags.Add("Gibberish class names — $gibPct% have no vowels / consonant clusters ($gibberishCount classes)") }
        if ($novPct   -ge  8) { $flags.Add("No-vowel class names — $novPct% ($noVowelCount classes)") }
        if ($confPct  -ge  3) { $flags.Add("Confusion-char names (Il1O0/_) — $confPct% ($confusionCount classes)") }
        if ($singleCharPkg -ge 6) { $flags.Add("Single-char package paths — $singleCharPkg path segments like a/b/c") }

        $fwStringMatches = [regex]::Matches($contentSample.ToString(), "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}")
        if ($fwStringMatches.Count -gt 0) {
            $examples = ($fwStringMatches | Select-Object -First 3 | ForEach-Object { $_.Value }) -join ", "
            $flags.Add("Fullwidth strings in class content — $($fwStringMatches.Count) occurrences (e.g. $examples)")
        }

        $sampleStr = $contentSample.ToString()
        foreach ($obfName in $cheatObfuscators.Keys) {
            foreach ($pat in $cheatObfuscators[$obfName]) {
                if ($sampleStr.Contains($pat)) {
                    $flags.Add("Known cheat obfuscator detected — $obfName (matched: $pat)")
                    break
                }
            }
        }

    } catch { }

    return $flags
}

function Invoke-BypassScan {
    param([string]$FilePath)

    $flags = [System.Collections.Generic.List[string]]::new()

    $mavenPrefixes = @(
        "com_","org_","net_","io_","dev_","gs_","xyz_",
        "app_","me_","tv_","uk_","be_","fr_","de_"
    )

    function Test-SuspiciousJarName {
        param([string]$JarName)
        $base = [System.IO.Path]::GetFileNameWithoutExtension($JarName)
        if ($base -match '\d')                                          { return $false }
        foreach ($pfx in $mavenPrefixes) {
            if ($base.ToLower().StartsWith($pfx))                       { return $false }
        }
        if ($base.Length -gt 20)                                        { return $false }
        return $true
    }

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        $nestedJars   = @($zip.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })
        $outerClasses = @($zip.Entries | Where-Object { $_.FullName -match "\.class$" })

        $suspiciousNestedJars = @()
        foreach ($nj in $nestedJars) {
            $njBase = [System.IO.Path]::GetFileName($nj.FullName)
            if (Test-SuspiciousJarName -JarName $njBase) {
                $suspiciousNestedJars += $njBase
            }
        }
        foreach ($sj in $suspiciousNestedJars) {
            $flags.Add("Suspicious nested JAR — no version, unknown dependency: $sj")
        }

        if ($nestedJars.Count -eq 1 -and $outerClasses.Count -lt 3) {
            $njName = [System.IO.Path]::GetFileName(($nestedJars | Select-Object -First 1).FullName)
            $flags.Add("Hollow shell — only $($outerClasses.Count) own class(es), wraps: $njName")
        }

        $outerModId = ""
        $fmje = $zip.Entries | Where-Object { $_.FullName -eq "fabric.mod.json" } | Select-Object -First 1
        if ($fmje) {
            try {
                $s = $fmje.Open()
                $r = New-Object System.IO.StreamReader($s)
                $t = $r.ReadToEnd(); $r.Close(); $s.Close()
                if ($t -match '"id"\s*:\s*"([^"]+)"') { $outerModId = $matches[1] }
            } catch { }
        }

        $allEntries    = [System.Collections.Generic.List[object]]::new()
        foreach ($e in $zip.Entries) { $allEntries.Add($e) }

        $innerZips = [System.Collections.Generic.List[object]]::new()
        foreach ($nj in $nestedJars) {
            try {
                $ns = $nj.Open()
                $ms = New-Object System.IO.MemoryStream
                $ns.CopyTo($ms); $ns.Close()
                $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $innerZips.Add($iz)
                foreach ($ie in $iz.Entries) { $allEntries.Add($ie) }
            } catch { }
        }

        $runtimeExecFound  = $false
        $httpDownloadFound = $false
        $httpExfilFound    = $false
        $obfuscatedCount   = 0
        $numericClassCount = 0
        $unicodeClassCount = 0
        $totalClassCount   = 0

        foreach ($entry in $allEntries) {
            $name = $entry.FullName

            if ($name -match "\.class$") {
                $totalClassCount++
                $className = [System.IO.Path]::GetFileNameWithoutExtension(($name -split "/")[-1])

                if ($className -match "^\d+$") { $numericClassCount++ }
                if ($className -match "[^\x00-\x7F]") { $unicodeClassCount++ }

                $segs = ($name -replace "\.class$","") -split "/"
                $consecutiveSingle = 0
                $maxConsecutive    = 0
                foreach ($seg in $segs) {
                    if ($seg.Length -eq 1) {
                        $consecutiveSingle++
                        if ($consecutiveSingle -gt $maxConsecutive) { $maxConsecutive = $consecutiveSingle }
                    } else {
                        $consecutiveSingle = 0
                    }
                }
                if ($maxConsecutive -ge 3) { $obfuscatedCount++ }

                try {
                    $st = $entry.Open()
                    $ms2 = New-Object System.IO.MemoryStream
                    $st.CopyTo($ms2)
                    $st.Close()
                    $rawBytes = $ms2.ToArray()
                    $ms2.Dispose()
                    $ct = [System.Text.Encoding]::ASCII.GetString($rawBytes)

                    if ($ct -match "java/lang/Runtime" -and
                        $ct -match "getRuntime" -and
                        $ct -match "exec") {
                        $runtimeExecFound = $true
                    }

                    if ($ct -match "openConnection" -and
                        $ct -match "HttpURLConnection" -and
                        $ct -match "FileOutputStream") {
                        $httpDownloadFound = $true
                    }

                    if ($ct -match "openConnection" -and
                        $ct -match "setDoOutput" -and
                        $ct -match "getOutputStream" -and
                        $ct -match "getProperty") {
                        $httpExfilFound = $true
                    }

                } catch { }
            }
        }

        foreach ($iz in $innerZips) { try { $iz.Dispose() } catch { } }
        $zip.Dispose()

        $obfPct = if ($totalClassCount -ge 10) { [math]::Round(($obfuscatedCount   / $totalClassCount) * 100) } else { 0 }
        $numPct = if ($totalClassCount -ge 5)  { [math]::Round(($numericClassCount / $totalClassCount) * 100) } else { 0 }
        $uniPct = if ($totalClassCount -ge 5)  { [math]::Round(($unicodeClassCount / $totalClassCount) * 100) } else { 0 }

        if ($runtimeExecFound -and $obfPct -ge 25) {
            $flags.Add("Runtime.exec() in obfuscated code — can run arbitrary OS commands")
        }
        if ($httpDownloadFound) {
            $flags.Add("HTTP file download — fetches and writes files from a remote server at runtime")
        }
        if ($httpExfilFound) {
            $flags.Add("HTTP POST exfiltration — sends system data to an external server")
        }
        if ($totalClassCount -ge 10 -and $obfPct -ge 25) {
            $flags.Add("Heavy obfuscation — $obfPct% of classes use single-letter path segments (a/b/c style)")
        }
        if ($numPct -ge 20) {
            $flags.Add("Numeric class names — $numPct% of classes have numeric-only names (e.g. 1234.class)")
        }
        if ($uniPct -ge 10) {
            $flags.Add("Unicode class names — $uniPct% of classes use non-ASCII characters")
        }

        $knownLegitModIds = @(
            "vmp-fabric","vmp","lithium","sodium","iris","fabric-api",
            "modmenu","ferrite-core","lazydfu","starlight","entityculling",
            "memoryleakfix","krypton","c2me-fabric","smoothboot-fabric",
            "immediatelyfast","noisium","threadtweak"
        )
        $dangerCount = ($flags | Where-Object {
            $_ -match "Runtime\.exec|HTTP file download|HTTP POST|Heavy obfuscation|Suspicious nested JAR"
        }).Count
        if ($outerModId -and ($knownLegitModIds -contains $outerModId) -and $dangerCount -gt 0) {
            $flags.Add("Fake mod identity — claims to be '$outerModId' but contains dangerous code")
        }

    } catch { }

    return $flags
}

function Invoke-JvmScan {
    $results = [System.Collections.Generic.List[string]]::new()

    function Add-FabricAddModsFlag {
        param(
            [string]$Source,
            [string]$CommandText
        )

        if ([string]::IsNullOrWhiteSpace($CommandText)) { return }

        foreach ($value in (Get-FabricAddModsValues -CommandText $CommandText)) {
            if ([string]::IsNullOrWhiteSpace($value)) { $value = "(no value found)" }
            $results.Add("Fabric addMods bypass — Dfabric.addMods loads extra mods from launcher/JVM args (source: $Source, value: $value)")
        }
    }

    $javaProcs = @(
        Get-Process javaw -ErrorAction SilentlyContinue
        Get-Process java  -ErrorAction SilentlyContinue
    )

    foreach ($proc in $javaProcs) {
        try {
            $wmi     = Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction Stop
            $cmdLine = $wmi.CommandLine

            if ($cmdLine) {
                Add-FabricAddModsFlag -Source "$($proc.ProcessName) PID $($proc.Id)" -CommandText $cmdLine

                $agentMatches = [regex]::Matches($cmdLine, '-javaagent:([^\s"]+)')
                foreach ($m in $agentMatches) {
                    $agentPath = $m.Groups[1].Value.Trim('"').Trim("'")
                    $agentName = [System.IO.Path]::GetFileName($agentPath)
                    $legitAgents = @("jmxremote","yjp","jrebel","newrelic","jacoco","theseus")
                    $isLegit = $false
                    foreach ($la in $legitAgents) { if ($agentName -match $la) { $isLegit = $true; break } }
                    if (-not $isLegit) {
                        $results.Add("JVM Agent — -javaagent:$agentName (path: $agentPath)")
                    }
                }

                $suspiciousFlags = @(
                    @{ Flag = "-Xbootclasspath/p:"; Desc = "prepends to bootstrap classpath, overrides core Java classes" },
                    @{ Flag = "-Xbootclasspath/a:"; Desc = "appends to bootstrap classpath, injects below classloader" },
                    @{ Flag = "-agentlib:jdwp";     Desc = "JDWP debug agent, remote debugging enabled" },
                    @{ Flag = "-agentpath:";         Desc = "native agent loaded, bypasses Java sandbox" }
                )
                foreach ($sf in $suspiciousFlags) {
                    if ($cmdLine -match [regex]::Escape($sf.Flag)) {
                        $results.Add("Suspicious JVM flag — $($sf.Flag) ($($sf.Desc))")
                    }
                }
            }
        } catch { }
    }

    try {
        $launcherProfiles = Join-Path $env:APPDATA ".minecraft\launcher_profiles.json"
        if (Test-Path $launcherProfiles -PathType Leaf) {
            $profileText = Get-Content -LiteralPath $launcherProfiles -Raw -ErrorAction Stop
            Add-FabricAddModsFlag -Source "launcher_profiles.json" -CommandText $profileText
        }
    } catch { }

    return $results
}

function Write-Rule {
    param([string]$Char = "─", [int]$Width = 76, [ConsoleColor]$Color = "DarkGray")
    Write-Host ($Char * $Width) -ForegroundColor $Color
}

function Write-SectionHeader {
    param(
        [string]$Title,
        [int]$Count,
        [ConsoleColor]$DotColor,
        [ConsoleColor]$CountColor
    )
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "●" -ForegroundColor $DotColor -NoNewline
    Write-Host "  $Title  " -ForegroundColor White -NoNewline
    Write-Host "($Count)" -ForegroundColor $CountColor
    Write-Host ""
}

function Write-SuspiciousCard {
    param($Mod)

    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkRed
    Write-Host "  │ " -ForegroundColor DarkRed -NoNewline
    Write-Host " FLAGGED " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
    Write-Host "  " -NoNewline
    Write-Host $Mod.FileName -ForegroundColor Yellow
    Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkRed

    if ($Mod.Patterns.Count -gt 0) {
        Write-Host "  │" -ForegroundColor DarkRed
        Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
        Write-Host "PATTERNS" -ForegroundColor DarkGray
        foreach ($p in ($Mod.Patterns | Sort-Object)) {
            Write-Host "  │    " -ForegroundColor DarkRed -NoNewline
            Write-Host $p -ForegroundColor Red
        }
    }

    $uniqueStrings = $Mod.Strings | Where-Object { $Mod.Patterns -notcontains $_ } | Sort-Object
    if ($uniqueStrings.Count -gt 0) {
        Write-Host "  │" -ForegroundColor DarkRed
        Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
        Write-Host "STRINGS" -ForegroundColor DarkGray
        foreach ($s in $uniqueStrings) {
            Write-Host "  │    " -ForegroundColor DarkRed -NoNewline
            Write-Host $s -ForegroundColor DarkYellow
        }
    }

    if ($Mod.Fullwidth -and $Mod.Fullwidth.Count -gt 0) {
        Write-Host "  │" -ForegroundColor DarkRed
        Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
        Write-Host "FULLWIDTH UNICODE" -ForegroundColor DarkGray
        foreach ($fw in ($Mod.Fullwidth | Sort-Object)) {
            Write-Host "  │    " -ForegroundColor DarkRed -NoNewline
            Write-Host "FULLWIDTH: $fw" -ForegroundColor Cyan
        }
    }

    Write-Host "  │" -ForegroundColor DarkRed
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkRed
    Write-Host ""
}

function Write-InjectionCard {
    param($Mod)

    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkMagenta
    Write-Host "  │ " -ForegroundColor DarkMagenta -NoNewline
    Write-Host " INJECTION " -ForegroundColor White -BackgroundColor DarkMagenta -NoNewline
    Write-Host "  " -NoNewline
    Write-Host $Mod.FileName -ForegroundColor Yellow
    Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkMagenta

    foreach ($flag in $Mod.Flags) {
        if ($flag -match "^(.+?) — (.+)$") {
            $flagTitle = $matches[1]
            $flagDesc  = $matches[2]
        } else {
            $flagTitle = $flag
            $flagDesc  = ""
        }

        Write-Host "  │" -ForegroundColor DarkMagenta
        Write-Host "  │  " -ForegroundColor DarkMagenta -NoNewline
        Write-Host "◉ " -ForegroundColor Magenta -NoNewline
        Write-Host $flagTitle -ForegroundColor White

        if ($flagDesc -ne "") {
            Write-Host "  │    " -ForegroundColor DarkMagenta -NoNewline
            Write-Host $flagDesc -ForegroundColor Gray
        }
    }

    Write-Host "  │" -ForegroundColor DarkMagenta
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkMagenta
    Write-Host ""
}

function Write-ObfuscationCard {
    param($Mod)

    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host "  │ " -ForegroundColor DarkYellow -NoNewline
    Write-Host " OBFUSCATED " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    Write-Host "  " -NoNewline
    Write-Host $Mod.FileName -ForegroundColor Yellow
    Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkYellow

    foreach ($flag in $Mod.Flags) {
        if ($flag -match "^(.+?) — (.+)$") {
            $flagTitle = $matches[1]
            $flagDesc  = $matches[2]
        } else {
            $flagTitle = $flag
            $flagDesc  = ""
        }

        Write-Host "  │" -ForegroundColor DarkYellow
        Write-Host "  │  " -ForegroundColor DarkYellow -NoNewline
        Write-Host "⚑ " -ForegroundColor Yellow -NoNewline
        Write-Host $flagTitle -ForegroundColor White

        if ($flagDesc -ne "") {
            Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline
            Write-Host $flagDesc -ForegroundColor Gray
        }
    }

    Write-Host "  │" -ForegroundColor DarkYellow
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host ""
}

$verifiedMods    = @()
$unknownMods     = @()
$suspiciousMods  = @()
$bypassMods      = @()
$obfuscatedMods  = @()

if (-not (Test-Path $modsPath -PathType Container)) {
    Show-MillerInfoBox -Title "Invalid folder" -Message "The selected directory does not exist or is not accessible." -Icon Error
    Write-Host "❌ Error accessing directory: $modsPath" -ForegroundColor Red
    exit 1
}

$scanErrors = @()
$jarFiles = @(Get-ChildItem -Path $modsPath -Filter *.jar -Recurse -Force -File -ErrorAction SilentlyContinue -ErrorVariable scanErrors | Sort-Object FullName)
$dfabricJarPathSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($dfabricPath in (Get-FabricAddModsJarFiles)) {
    try {
        if ($dfabricJarPathSet.Add($dfabricPath)) {
            $alreadyQueued = ($jarFiles | Where-Object { $_.FullName -eq $dfabricPath }).Count -gt 0
            if (-not $alreadyQueued) {
                $jarFiles += Get-Item -LiteralPath $dfabricPath -ErrorAction Stop
            }
        }
    } catch { }
}
$jarFiles = @($jarFiles | Sort-Object FullName)

if ($jarFiles.Count -eq 0) {
    Close-MillerProgressWindow
    Show-MillerInfoBox -Title "No JAR files found" -Message "No .jar files were found in the selected mods folder, including hidden and nested folders." -Icon Warning
    Write-Host "⚠️  No JAR files found in: $modsPath" -ForegroundColor Yellow
    exit 0
}

$fileWord    = if ($jarFiles.Count -eq 1) { "file" } else { "files" }
Write-Host "🔍 Found $($jarFiles.Count) JAR $fileWord to analyze (including hidden files and nested library folders)" -ForegroundColor Green
if ($dfabricJarPathSet.Count -gt 0) {
    Write-Host "⚠️  Found $($dfabricJarPathSet.Count) JAR file(s) loaded through Dfabric.addMods" -ForegroundColor Yellow
}
if ($scanErrors.Count -gt 0) {
    Write-Host "⚠️  Some folders could not be read, but the analyser will continue with everything it could access." -ForegroundColor Yellow
}
Write-Host

$spinnerFrames = @("⣾","⣽","⣻","⢿","⡿","⣟","⣯","⣷")
$totalFiles    = $jarFiles.Count
$idx           = 0

Write-Host "🔍 Pass 1 — Hash verification (Modrinth + Megabase)..." -ForegroundColor Cyan

foreach ($jar in $jarFiles) {
    $idx++
    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
    $displayName = Get-ModRelativePath -BasePath $modsPath -FilePath $jar.FullName
    Update-MillerProgress -Phase "Pass 1 of 5: verifying hashes" -Index $idx -Total $totalFiles -FileName $displayName
    Write-Host "`r[$spinner] Verifying: $idx/$totalFiles - $displayName" -ForegroundColor Yellow -NoNewline

    $hash = Get-FileSHA1 -Path $jar.FullName

    if ($hash) {
        $modrinthData = Query-Modrinth -Hash $hash
        if ($modrinthData.Slug) {
            $verifiedMods += [PSCustomObject]@{ ModName = $modrinthData.Name; FileName = $displayName; FilePath = $jar.FullName }
            continue
        }
        $megabaseData = Query-Megabase -Hash $hash
        if ($megabaseData.name) {
            $verifiedMods += [PSCustomObject]@{ ModName = $megabaseData.Name; FileName = $displayName; FilePath = $jar.FullName }
            continue
        }
    }

    $src = Get-DownloadSource $jar.FullName
    $unknownMods += [PSCustomObject]@{ FileName = $displayName; FilePath = $jar.FullName; DownloadSource = $src }
}

Write-Host "`r$(' ' * 100)`r" -NoNewline

$jarWord = if ($totalFiles -eq 1) { "JAR" } else { "JARs" }
Write-Host "🔬 Pass 2 — Deep-scanning all $totalFiles $jarWord..." -ForegroundColor Cyan
$idx = 0

foreach ($jar in $jarFiles) {
    $idx++
    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
    $displayName = Get-ModRelativePath -BasePath $modsPath -FilePath $jar.FullName
    Update-MillerProgress -Phase "Pass 2 of 5: scanning mod contents" -Index $idx -Total $totalFiles -FileName $displayName
    Write-Host "`r[$spinner] Scanning: $idx/$totalFiles - $displayName" -ForegroundColor Yellow -NoNewline

    $result = Invoke-ModScan -FilePath $jar.FullName
    $isDfabricAddMod = $dfabricJarPathSet.Contains($jar.FullName)
    if ($isDfabricAddMod) {
        [void]$result.Patterns.Add("Loaded through Dfabric.addMods")
    }

    if ($isDfabricAddMod -or $result.Patterns.Count -gt 0 -or $result.Strings.Count -gt 0 -or $result.Fullwidth.Count -gt 0) {
        $suspiciousMods += [PSCustomObject]@{
            FileName = $displayName
            FilePath = $jar.FullName
            Patterns = $result.Patterns
            Strings  = $result.Strings
            Fullwidth = $result.Fullwidth
            Reason = if ($isDfabricAddMod) { "Dfabric.addMods loaded this jar outside the normal mods flow" } else { "" }
        }
        $verifiedMods = $verifiedMods | Where-Object { $_.FilePath -ne $jar.FullName }
        $unknownMods  = $unknownMods  | Where-Object { $_.FilePath -ne $jar.FullName }
    }
}

Write-Host "`r$(' ' * 100)`r" -NoNewline

Write-Host "🛡️  Pass 3 — Bypass/injection scan on all $totalFiles $jarWord..." -ForegroundColor Magenta
$idx = 0

foreach ($jar in $jarFiles) {
    $idx++
    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
    $displayName = Get-ModRelativePath -BasePath $modsPath -FilePath $jar.FullName
    Update-MillerProgress -Phase "Pass 3 of 5: checking bypass and injection" -Index $idx -Total $totalFiles -FileName $displayName
    Write-Host "`r[$spinner] Bypass scan: $idx/$totalFiles - $displayName" -ForegroundColor Yellow -NoNewline

    $bypassFlags = Invoke-BypassScan -FilePath $jar.FullName

    if ($bypassFlags.Count -gt 0) {
        $bypassMods += [PSCustomObject]@{
            FileName = $displayName
            FilePath = $jar.FullName
            Flags    = $bypassFlags
        }
        $verifiedMods = $verifiedMods | Where-Object { $_.FilePath -ne $jar.FullName }
        $unknownMods  = $unknownMods  | Where-Object { $_.FilePath -ne $jar.FullName }
    }
}

Write-Host "`r$(' ' * 100)`r" -NoNewline

Write-Host "🔎 Pass 4 — Obfuscation analysis on all $totalFiles $jarWord..." -ForegroundColor DarkCyan
$idx = 0

foreach ($jar in $jarFiles) {
    $idx++
    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
    $displayName = Get-ModRelativePath -BasePath $modsPath -FilePath $jar.FullName
    Update-MillerProgress -Phase "Pass 4 of 5: analysing obfuscation" -Index $idx -Total $totalFiles -FileName $displayName
    Write-Host "`r[$spinner] Obf scan: $idx/$totalFiles - $displayName" -ForegroundColor Yellow -NoNewline

    $obfFlags = Invoke-ObfuscationScan -FilePath $jar.FullName

    if ($obfFlags.Count -gt 0) {
        $alreadyFlagged = ($suspiciousMods | Where-Object { $_.FilePath -eq $jar.FullName }).Count -gt 0 -or
                          ($bypassMods     | Where-Object { $_.FilePath -eq $jar.FullName }).Count -gt 0
        if (-not $alreadyFlagged) {
            $obfuscatedMods += [PSCustomObject]@{
                FileName = $displayName
                FilePath = $jar.FullName
                Flags    = $obfFlags
            }
            $verifiedMods = $verifiedMods | Where-Object { $_.FilePath -ne $jar.FullName }
        }
    }
}

Write-Host "`r$(' ' * 100)`r" -NoNewline

$jvmFlags = @()
Update-MillerProgress -Phase "Pass 5 of 5: checking launcher and JVM flags" -Index 1 -Total 1 -FileName "Runtime / launcher scan"
Write-Host "⚡ Pass 5 — Scanning JVM for agents and injections..." -ForegroundColor DarkYellow
$jvmFlags = Invoke-JvmScan
if ($jvmFlags.Count -gt 0) {
    Write-Host "   ⚠️  JVM issues found!" -ForegroundColor Yellow
} else {
    Write-Host "   ✓  JVM looks clean" -ForegroundColor DarkGray
}

Write-Host "`r$(' ' * 100)`r" -NoNewline

if ($verifiedMods.Count -gt 0) {
    Write-SectionHeader -Title "VERIFIED MODS" -Count $verifiedMods.Count -DotColor Green -CountColor Green
    Write-Rule "─" 76 DarkGray
    foreach ($mod in $verifiedMods) {
        Write-Host "  ✓ " -ForegroundColor Green -NoNewline
        Write-Host "$($mod.ModName)" -ForegroundColor White -NoNewline
        Write-Host " → " -ForegroundColor Gray -NoNewline
        Write-Host "$($mod.FileName)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

if ($unknownMods.Count -gt 0) {
    Write-SectionHeader -Title "UNKNOWN MODS" -Count $unknownMods.Count -DotColor Yellow -CountColor Yellow
    Write-Rule "─" 76 DarkGray
    foreach ($mod in $unknownMods) {
        $name = $mod.FileName
        if ($name.Length -gt 50) { $name = $name.Substring(0,47) + "..." }
        $topLine    = "  ╔═ ? " + $name + " " + ("═" * (65 - $name.Length)) + "╗"
        $sourceText = if ($mod.DownloadSource) { "Source: $($mod.DownloadSource)" } else { "Source: ?" }
        $bottomLine = "  ╚═ " + $sourceText + " " + ("═" * (67 - $sourceText.Length)) + "╝"
        Write-Host $topLine    -ForegroundColor Yellow
        Write-Host $bottomLine -ForegroundColor Yellow
        Write-Host ""
    }
}

if ($suspiciousMods.Count -gt 0) {
    Write-SectionHeader -Title "SUSPICIOUS MODS" -Count $suspiciousMods.Count -DotColor Red -CountColor Red
    Write-Rule "─" 76 DarkGray
    Write-Host ""
    foreach ($mod in $suspiciousMods) {
        Write-SuspiciousCard -Mod $mod
    }
}

if ($bypassMods.Count -gt 0) {
    Write-SectionHeader -Title "BYPASS / INJECTION DETECTED" -Count $bypassMods.Count -DotColor Magenta -CountColor Magenta
    Write-Rule "─" 76 DarkGray
    Write-Host ""
    foreach ($mod in $bypassMods) {
        Write-InjectionCard -Mod $mod
    }
}

if ($obfuscatedMods.Count -gt 0) {
    Write-SectionHeader -Title "OBFUSCATED MODS" -Count $obfuscatedMods.Count -DotColor DarkYellow -CountColor Yellow
    Write-Rule "─" 76 DarkGray
    Write-Host ""
    foreach ($mod in $obfuscatedMods) {
        Write-ObfuscationCard -Mod $mod
    }
}

if ($jvmFlags.Count -gt 0) {
    Write-SectionHeader -Title "JVM / RUNTIME INJECTION" -Count $jvmFlags.Count -DotColor Yellow -CountColor Yellow
    Write-Rule "─" 76 DarkGray
    Write-Host ""
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host "  │ " -ForegroundColor DarkYellow -NoNewline
    Write-Host " JVM " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
    Write-Host "  javaw / java process" -ForegroundColor Yellow
    Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkYellow
    foreach ($flag in $jvmFlags) {
        $ft = $flag; $fd = ""; $fpath = ""
        if ($flag -match "^(.+?) — (.+) \(path: (.+)\)$") {
            $ft = $matches[1]; $fd = $matches[2]; $fpath = $matches[3]
        } elseif ($flag -match "^(.+?) — (.+)$") {
            $ft = $matches[1]; $fd = $matches[2]
        }
        Write-Host "  │" -ForegroundColor DarkYellow
        Write-Host "  │  " -ForegroundColor DarkYellow -NoNewline
        Write-Host "◉ " -ForegroundColor Yellow -NoNewline
        Write-Host $ft -ForegroundColor White
        if ($fd -ne "") {
            Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline
            Write-Host $fd -ForegroundColor Gray
        }
        if ($fpath -ne "") {
            $display = if ($fpath.Length -gt 60) { "..." + $fpath.Substring($fpath.Length - 57) } else { $fpath }
            Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline
            Write-Host $display -ForegroundColor DarkGray
        }
    }
    Write-Host "  │" -ForegroundColor DarkYellow
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host ""
}

Write-Host "📊 SUMMARY" -ForegroundColor Cyan
Write-Rule "━" 76 Blue
Write-Host "  Total files scanned: " -ForegroundColor Gray -NoNewline; Write-Host "$totalFiles"                   -ForegroundColor White
Write-Host "  Verified mods:       " -ForegroundColor Gray -NoNewline; Write-Host "$($verifiedMods.Count)"        -ForegroundColor Green
Write-Host "  Unknown mods:        " -ForegroundColor Gray -NoNewline; Write-Host "$($unknownMods.Count)"         -ForegroundColor Yellow
Write-Host "  Suspicious mods:     " -ForegroundColor Gray -NoNewline; Write-Host "$($suspiciousMods.Count)"      -ForegroundColor Red
Write-Host "  Bypass/Injected:     " -ForegroundColor Gray -NoNewline; Write-Host "$($bypassMods.Count)"          -ForegroundColor Magenta
Write-Host "  Obfuscated mods:     " -ForegroundColor Gray -NoNewline; Write-Host "$($obfuscatedMods.Count)"      -ForegroundColor Yellow
Write-Host "  JVM issues:          " -ForegroundColor Gray -NoNewline; Write-Host "$($jvmFlags.Count)"            -ForegroundColor Yellow
Write-Host
Write-Rule "━" 76 Blue
Write-Host ""
Write-Host "  Analysis complete! Thanks for using cwgi mod analyser" -ForegroundColor Cyan
Write-Host ""
Close-MillerProgressWindow
Show-MillerSummaryPopup `
    -TotalFiles $totalFiles `
    -VerifiedMods $verifiedMods `
    -UnknownMods $unknownMods `
    -SuspiciousMods $suspiciousMods `
    -BypassMods $bypassMods `
    -ObfuscatedMods $obfuscatedMods `
    -JvmFlags $jvmFlags

Write-Host "  👤 Created by: " -ForegroundColor White -NoNewline
Write-Host "🌟 " -ForegroundColor Cyan -NoNewline
Write-Host "cwgi" -ForegroundColor Cyan
Write-Host "  📱 My Socials: " -ForegroundColor White -NoNewline
Write-Host "💬 " -ForegroundColor Blue -NoNewline
Write-Host "Discord  : " -ForegroundColor Blue -NoNewline
Write-Host "cwgii" -ForegroundColor Blue
Write-Host "                 " -NoNewline
Write-Host "🔗 " -ForegroundColor DarkGray -NoNewline
Write-Host "TikTok   : " -ForegroundColor DarkGray -NoNewline
Write-Host "cwgicuh" -ForegroundColor DarkGray
Write-Host "                 " -NoNewline
Write-Host "🎥 " -ForegroundColor Red -NoNewline
Write-Host "Server   : " -ForegroundColor Red -NoNewline
Write-Host "aucpvp.net" -ForegroundColor Red
Write-Host ""
Write-Rule "━" 76 Blue
Write-Host ""
exit 0
