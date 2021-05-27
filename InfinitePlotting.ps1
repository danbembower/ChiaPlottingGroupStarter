
<# Description
    .Description
        This is my basic plotting plan

    To Do Items
        Add validation to folders
        Add a help section
        Add Checking into log files to determine when to start instead of timing
#>



<# Ask for input and setting defaults #>
    #[int]$NumGroups = Read-Host "How many Groups of parallel plots? (Default 2)"; if($NumGroups -eq 0){$NumGroups = 2}

    [int]$InitialDelay = Read-Host "How many minutes to delay the first group? (Default 0)"; if($InitialDelay -eq 0){$InitialDelay = 1}else{$InitialDelay=$InitialDelay*60}
    
    [double]$CompletionTime = Read-Host "About how many minutes to complete a parallel group? (Default $(8*60))"; if($CompletionTime -eq 0){$CompletionTime = 8*60*60}else{$CompletionTime = $CompletionTime*60}

    [int]$OffsetGroup = Read-Host "How many minutes to offset each group? (Default is half: $($CompletionTime/120))";if($OffsetGroup -eq 0){$OffsetGroup = $CompletionTime/2}

    [int]$FirstGroupNumber = Read-host "Enter the number to call the first group (Default 1)";if($FirstGroupNumber -eq 0){$FirstGroupNumber = 1}

    [int]$NumPlotsPerGroup = Read-Host "How many parallel plots (series)? (Default 3)"; if($NumPlotsPerGroup -eq 0){$NumPlotsPerGroup = 3}
    
    if($NumplotsPerGroup -eq 1){}else{[int]$OffsetParallel = Read-Host "How many minutes to offset each parallel plot? (Default is 15 min)"; if($OffsetParallel -eq 0){$OffsetParallel = 15*60}else{$OffsetParallel=$OffsetParallel*60}}
  
    [int]$k = Read-Host "What k level? ('-k', Default 32)"; if($k -eq 0){$k = 32}

    [string]$TempFolder = Read-Host "What temp folder to use? ('-t', Default is A:\)"; if([string]::IsNullOrEmpty($TempFolder)){$TempFolder = "A:\"}        
    
    [string]$logpath1 = Read-Host "What folder for logs? (Default is C:\ChiaStuff\PlottingLogs\)"; if([string]::IsNullOrEmpty($logpath1)){$logpath1 = "C:\ChiaStuff\PlottingLogs\"}

    $SeriesLetter = @("Get Series Letter")
    $DestFolder = @("Set unique drive letter")
    for ($i=1;$i -le $NumPlotsPerGroup;$i++){
        $SeriesLetter += $([char](64+$i))
        $DestFolder += Read-host "What destination folder for plots from series $($SeriesLetter.getvalue($i))? ('-d', Default is B:\)"; if([string]::IsNullOrEmpty($DestFolder[$i])){$DestFolder[$i]="B:\"}
    } 

<#Print Information in PowerShell Window#>
""
""
"Plotting $($NumGroups) Groups of $($NumPlotsPerGroup) Plots in each group, repeating every $($OffsetGroup) seconds. "
"Log files placed in $($logpath1)"
for ($i=1;$i -le $NumplotsPerGroup;$i++){
    $message = "Final Plots for Series " + $SeriesLetter[$i] + " are located at " + $DestFolder[$i]
    $message
}
$confirmation = Read-Host "Ready? [y/n]"
while($confirmation -ne "y"){
    if ($confirmation -eq 'n') {exit}
    $confirmation = Read-Host "Ready? [y/n]"
}
"Scheduling indefinitely. Press Ctrl + C to end process."



<# Main Plotting Loop #>
for ($group = $FirstGroupNumber; $group -le 999999999; $group++){   #  For each Group
    
    <# Delay first group if needed #>
    if ($group -eq $FirstGroupNumber -and $InitialDelay -ne 0){
        for($secondsleft = $InitialDelay; $secondsleft -gt 0){
            $totaltime = $InitialDelay
            $message = "The first group of parallel plots (Group $($group)) will be start after this countdown"
            $hours = [math]::Floor($Secondsleft/3600)
            $minutes = [math]::floor(($Secondsleft-($Hours*3600))/60)

            $remaining = $hours.Tostring() + " Hours, " + $minutes.Tostring() + " Minutes Remaining"
                
            if($secondsleft -gt 60){$o
                Write-Progress -Activity $message -Status $remaining -PercentComplete ($secondsleft * 100 / $totaltime)
                $secondsleft = $secondsleft - 60
                Start-Sleep -seconds 60
            }else{
                Write-Progress -Activity $message -Status "$($secondsleft) Seconds Remaining" -PercentComplete ($secondsleft * 100 / $totaltime)
                $secondsleft = $secondsleft - 1
                start-sleep -seconds 1        
            }
        }
    }
    
    <# Create Each Series of Parallel Plots #>
    for ($plot = 1; $plot -le $NumPlotsPerGroup ; $plot++){   # For each parallel Plot
        
        <# Get Nice Names #>
        $datestamp = get-date -format yyyy-MM-dd-hh-mm
        $pleasantdate = get-date -format "dddd, hh:mm tt"
        $plotname = "Group-$($group)-Series-$($SeriesLetter[$plot])"
        $temppath = "$($TempFolder)$($datestamp)-$($plotname)-Temp\"
        $logpath = "$($logpath1)$($datestamp)-$($plotname).log"
        $windowtitle = "$($datestamp) $($plotname) - Active Plotter"
        $destinationfolder = $DestFolder[$plot]        
        
        <# This is the main thing starting plotting #>
        $chiaProcess = Start-Process -FilePath powershell -ArgumentList "-noexit 
                        `$host.ui.RawUI.WindowTitle = 'Plotting $($windowtitle)'
                        ''
                        '$($plotname)'
                        ''
                        'Temp Directory: $($temppath)'
                        'Destination Folder: $($destinationfolder)'
                        'Location of Log: $($logpath)'
                        ''
                        'Started on $($pleasantdate)'
                        ''
                        chia.exe plots create -k $($k) -n 1 -b 4000 -r 2 -u 128 -t $($temppath) -d $($DestinationFolder) | Tee-Object -FilePath $($logpath)
                        "
        <# Delay Parallel Series until last Series #>
        if ($plot -ne $NumPlotsPerGroup){
            for($secondsleft = $OffsetParallel; $secondsleft -gt 0){
                $totaltime = $OffsetParallel
                $message = "The next plot, Group $($group) Series $($SeriesLetter[$plot+1]) will start after this countdown"
                $hours = [math]::Floor($Secondsleft/3600)
                $minutes = [math]::floor(($Secondsleft-($Hours*3600))/60)
                $remaining = $hours.Tostring() + " Hours, " + $minutes.Tostring() + " Minutes"
                
                if($secondsleft -gt 60){
                    Write-Progress -Activity $message -Status $remaining -PercentComplete ($secondsleft * 100 / $totaltime)
                    $secondsleft = $secondsleft - 60
                    Start-Sleep -seconds 60
                }else{
                    Write-Progress -Activity $message -Status "$($secondsleft) Seconds Remaining" -PercentComplete ($secondsleft * 100 / $totaltime)
                    $secondsleft = $secondsleft - 1
                    start-sleep -seconds 1        
                }
            }
        }
    }
    <#Delay Scheduling of Next Group, to infinity #>
    for($secondsleft = $OffsetGroup; $secondsleft -gt 0){
        $totaltime = $OffsetGroup
        $message = "The next group of parallel plots (Group $($group+1)) will start after this countdown"
        $hours = [math]::Floor($Secondsleft/3600)
        $minutes = [math]::Floor(($Secondsleft-($Hours*3600))/60)
        $remaining = $hours.Tostring() + " Hours, " + $minutes.Tostring() + " Minutes"

        if($secondsleft -gt 60){
            Write-Progress -Activity $message -Status $remaining -PercentComplete ($secondsleft * 100 / $totaltime)
            $secondsleft = $secondsleft - 60
            Start-Sleep -seconds 60
        }else{
            Write-Progress -Activity $message -Status "$($secondsleft) Seconds Remaining" -PercentComplete ($secondsleft * 100 / $totaltime)
            $secondsleft = $secondsleft - 1
            start-sleep -seconds 1        
        }
    }
}








