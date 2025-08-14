$host.UI.RawUI.WindowTitle = "PSploit"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Red"
$esc = [char]27
$fgRed = "$esc[31m"
$bgBlack = "$esc[40m"
$fat = "$esc[1m"
$underline = "$esc[4m"
$nounderline = "$esc[24m"
$nofat = "$esc[22m"
$reset = "$nounderline$fat$bgBlack$fgRed"

$index = @{}

$index[1] = @{
    tools   = @("ToolA", "ToolB")
    creator = "Nina"
    title   = "std tools"
}

$index[2] = @{
    tools   = @("Tool1", "Tool2", "Tool3", "Tool4", "Tool5", "Tool6", "Tool7", "Tool8", "Tool9", "Tool10", "Tool11", "Tool12")
    creator = "Nina"
    title   = "advanced suite"
}

$sidesCount = $index.Count
$toolsCount = ($index.Values | ForEach-Object { $_.tools.Count }) -join "+" | Invoke-Expression
$toolsCount = $toolsCount.ToString("0000")
$lastSide = ($index.Keys | Sort-Object {[int]$_} | Select-Object -Last 1)



$banner = @"
${reset}
         ┌───────────────────────────────────────────────────────────────────────────────┐
         │  ██▓███       ██████     ██▓███      ██▓        ▒█████      ██▓   ▄▄▄█████▓   │
         │  ▓██░  ██▒   ▒██    ▒    ▓██░  ██▒   ▓██▒       ▒██▒  ██▒   ▓██▒   ▓  ██▒ ▓▒  │
         │  ▓██░ ██▓▒   ░ ▓██▄      ▓██░ ██▓▒   ▒██░       ▒██░  ██▒   ▒██▒   ▒ ▓██░ ▒░  │
         │  ▒██▄█▓▒ ▒     ▒   ██▒   ▒██▄█▓▒ ▒   ▒██░       ▒██   ██░   ░██░   ░ ▓██▓ ░   │
         │  ▒██▒ ░  ░   ▒██████▒▒   ▒██▒ ░  ░   ░██████▒   ░ ████▓▒░   ░██░     ▒██▒ ░   │
         │  ▒▓▒░ ░  ░   ▒ ▒▓▒ ▒ ░   ▒▓▒░ ░  ░   ░ ▒░▓  ░   ░ ▒░▒░▒░    ░▓       ▒ ░░     │
         │  ░▒ ░        ░ ░▒  ░ ░   ░▒ ░        ░ ░ ▒  ░     ░ ▒ ▒░     ▒ ░       ░      │
         │  ░░          ░  ░  ░     ░░            ░ ░      ░ ░ ░ ▒      ▒ ░     ░        │
         └───────────────────────────────────────────────────────────────────────────────┘                                                                                  
"@

$infoside = @"
${reset}
    ┌─────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                         │
    │                           ${underline}[INFO] - How to use PSploit${reset}                                   │
    │                                                                                         │
    │          [TIP] - If you don't want to see this screen, run the script with -noinfo      │
    │                                                                                         │
    │          ${underline}Controls${reset}                     ${underline}INFO${reset}                                              │
    │          A - Go back a page           This tool is community-driven                     │
    │          D - Go to next page          It focuses on using PowerShell (v5.1) to          │
    │        W/A - Select tool              its advantage — simplicity and system             │
    │      Enter - Run tool                 integration.                                      │
    │          E - Exit the tool            If you'd like to contribute or share feedback:    │
    │          ? - Hidden key (:            Text: t.me/nina_aka_lubrj                         │
    │                                                                                         │
    ├─────────────┬────────────┬──────────────┬────────────────┬─────────────────┬────────────┤
    │ << Back (A) │ Site > 000 │ Tools > ${toolsCount} │ Creator > Nina │ Server > Online │ Next (D)>> │
    └─────────────┴────────────┴──────────────┴────────────────┴─────────────────┴────────────┘
                                                                                    
"@


$selected = $null
$side = 0

Clear-Host
Write-host $banner
Write-host $infoside

function load_side {
    Clear-Host
    Write-Host $banner

    $spaceString = "                                                                                       "
    $head = "'$($index[$side].title)' by '$($index[$side].creator)'"

    $tool = @()

    $countPreviousTools = 0
    foreach ($sideKey in $index.Keys | Sort-Object {[int]$_}) {
        if ([int]$sideKey -lt $side) {
            $countPreviousTools += $index[$sideKey].tools.Count
        }
    }

    for ($i = 0; $i -lt 12; $i++) {
        if ($i -lt $index[$side].tools.Count) {
            $maxLen = 36
            $toolName = $index[$side].tools[$i]

            if ($toolName.Length -le $maxLen) {
                $formattedName = $toolName.PadRight($maxLen)
            } else {
                $formattedName = "..." + $toolName.Substring($toolName.Length - ($maxLen - 3))
            }

            $globalPos = $countPreviousTools + $i + 1
            $tool += "$($globalPos.ToString('0000')) $formattedName"
        } else {
            $tool += " " * 41
        }
    }

    $site = @"
    ┌─────────────────────────────────────────────────────────────────────────────────────────┐
    │ ${head} │
    ├────────────────────────────────────────────┬────────────────────────────────────────────┤
    │ ${tool[0]} │ ${tool[6]} │
    ├────────────────────────────────────────────┼────────────────────────────────────────────┤
    │ ${tool[1]} │ ${tool[7]} │
    ├────────────────────────────────────────────┼────────────────────────────────────────────┤
    │ ${tool[2]} │ ${tool[8]} │
    ├────────────────────────────────────────────┼────────────────────────────────────────────┤
    │ ${tool[3]} │ ${tool[9]} │
    ├────────────────────────────────────────────┼────────────────────────────────────────────┤
    │ ${tool[4]} │ ${tool[10]} │
    ├────────────────────────────────────────────┼────────────────────────────────────────────┤
    │ ${tool[5]} │ ${tool[11]} │
    ├─────────────┬────────────┬──────────────┬──┴─────────────┬─────────────────┬────────────┤
    │ << Back (A) │ Site > ${side.ToString("000")} │ Tools > ${toolsCount} │ Creator > Nina │ Server > Online │ Next (D)>> │
    └─────────────┴────────────┴──────────────┴────────────────┴─────────────────┴────────────┘

"@

    Write-Host $site
}


while ($true) {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $char = [string]$key.Character
    switch ($char.ToLower()) {
        'w' {
            if ($side -ne 0) {
                if ($null -eq $selected) {
                    $selected = 1
                } elseif ($selected -ne 12) {
                    $selected++
                }
            }
        }
        's' {
            if ($side -ne 0) {
                if ($null -eq $selected) {
                    $selected = 1
                } elseif ($selected -ne 1) {
                    $selected--
                }
            }
        }
        'a' { 
            if ($side -le 1) {
                $side = $lastSide
            }
            else {
                $side--
            }
        }
        'd' {
            if ($side -ge $lastSide) {
                $side = 1
            }
            else {
                $side++
            }
        }
        'e' {
            Write-Host "Thanks for using"
            exit 
        }
        default { Write-Host "Unknown: $char" }
    }
    load_side
}

