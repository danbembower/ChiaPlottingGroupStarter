
<# Description
    .Description
        This is my basic plotting plan

    To Do Items
        Add validation to folders
        Add a help section
#>



<# Ask for input and setting defaults #>
    [int]$NumGroups = Read-Host "How many Groups of parallel plots? (Default 2)"
        if($NumGroups -eq 0){$NumGroups = 2}
    [int]$InitialDelay = Read-Host "How many seconds to delay the first group? (Default 0)"
        if($NumGroups -eq 1){
    [string]$FirstGroupNumber = Read-host "Enter the single Group Number (Default 1)"}else{
    [int]$OffsetGroup = Read-Host "How many seconds to offset each group? (Default 8 hrs/# groups)"}
        if($OffsetGroup -eq 0){$OffsetGroup = 8*3600/$NumGroups;"Offset time set to $($OffsetGroup) seconds."}
    [int]$NumPlotsPerGroup = Read-Host "How many Plots in each group? (Default 3)"
        if($NumPlotsPerGroup -eq 0){$NumPlotsPerGroup = 3}
        if($NumplotsPerGroup -eq 1){}else{
    [int]$OffsetParallel = Read-Host "How many seconds offset each parallel plot? (Default is 12)"
        if($OffsetParallel -eq 0){$OffsetParallel = 12}}        
    [int]$NumInSequence = Read-Host "How many sequences do you want in each plot? (Default 9)"
        if($NumInSequence -eq 0){$NumInSequence = 9}
    [int]$k = Read-Host "What k level? (Default 32)"
        if($k -eq 0){$k = 32}
    [string]$TempFolder = Read-Host "What temp folder to use? (Default is A:\)"
        if([string]::IsNullOrEmpty($TempFolder)){$TempFolder = "A:\"}        
    [string]$DestinationFolder = Read-Host "What destination folder? (Default is S:\PSPlots\)"
        if([string]::IsNullOrEmpty($DestinationFolder)){$DestinationFolder = "S:\PSPlots\"}
    [string]$logpath1 = "C:\ChiaStuff\PlottingLogs\"
        

""
""
"Plotting on $($TempFolder) for final output on $($DestinationFolder)"
"Plotting in $($NumGroups) Groups of $($NumPlotsPerGroup) Plots in each group, repeating $($NumInSequence) times"
"Log files placed in $($logpath1)"



<# Main Plotting Loop #>
for ($group = 1; $group -le $NumGroups; $group++)    #  For each Group
{
    if($FirstGroupNumber -ne 0){$group = $FirstGroupNumber; $NumGroups = $FirstGroupNumber; $FirstGroupNumber = 0}
    
    <# Delay first group if needed #>
    if ($group -eq 1 -and $InitialDelay -ne 0)
    {
        for($secondsleft = $InitialDelay; $secondsleft -gt 0)
        {
            
            $message = "The first group of parallel plots (Group $($group) of $($NumGroups)) will be started Soon"
            $hours = [math]::Floor($Secondsleft/3600)
            $minutes = [math]::floor(($Secondsleft-($Hours*3600))/60)
            $totaltime = $InitialDelay
            $remaining = $hours.Tostring() + " Hours, " + $minutes.Tostring() + " Minutes"
        
        
            if($secondsleft -gt 65){
                Write-Progress -Activity $message -Status $remaining -PercentComplete ($secondsleft * 100 / $totaltime)
                $secondsleft = $secondsleft - 60
                Start-Sleep -seconds 60
            }else{
                Write-Progress -Activity $message -Status $secondsleft -PercentComplete ($secondsleft * 100 / $totaltime)
                $secondsleft = $secondsleft - 1
                start-sleep -seconds 1        
            }
        }
    }

    
    <# Create Parallel Plotting Powershell Windows #>
    for ($plot = 1; $plot -le $NumPlotsPerGroup ; $plot++)   # For each parallel Plot
    { 
        $datestamp = get-date -format yyyy-MM-dd-hh-mm
        $pleasantdate = get-date -format "dddd, hh:mm tt"
        $plotname = "Group-$($group)-Plot-$($plot)"
        $temppath = "$($TempFolder)$($datestamp)-$($plotname)-Temp\"
        $logpath = "$($logpath1)$($datestamp)-$($plotname).log"
        
        <#
        $datestamp
        $plotname
        $temppath
        $logpath
        $destinationfolder
        #>
        
        <# This is the main thing starting plotting #>
        $chiaProcess = Start-Process -FilePath powershell -ArgumentList "-noexit 
                        `$host.ui.RawUI.WindowTitle = 'Plotting $($plotname)'
                        ''
                        '$($plotname)'
                        ''
                        'Temp Directory: $($temppath)'
                        'Destination Folder: $($destinationfolder)'
                        'Location of Log: $($logpath)'
                        ''
                        'Started on $($pleasantdate)'
                        ''
                        chia.exe plots create -k $($k) -n $NumInSequence -b 4000 -r 2 -u 128 -t $($temppath) -d $($DestinationFolder) | Tee-Object -FilePath $($logpath)
                        "
       
        if ($plot -ne $NumPlotsPerGroup){ 
            for($secondsleft = $OffsetParallel; $secondsleft -gt 0){
                $nextplot = $plot+1
                $message = "The next parallel plot (Plot $($nextplot) of $($NumPlotsPerGroup)) in Group $($group) will be started soon"
                Write-Progress -Activity $message -Status $secondsleft -PercentComplete ($secondsleft * 100 / $OffsetParallel)
                $secondsleft = $secondsleft - 1
                Start-Sleep -seconds 1
            }
        }
    }
    
    if ($group -ne $NumGroups)
    {
        for($secondsleft = $OffsetGroup; $secondsleft -gt 0)
        {
            $nextgroup = $group + 1
            $message = "The next group of parallel plots (Group $($nextgroup) of $($NumGroups)) will be started soon"
            $hours = [math]::Floor($Secondsleft/3600)
            $minutes = [math]::Floor(($Secondsleft-($Hours*3600))/60)
            $remaining = $hours.Tostring() + " Hours, " + $minutes.Tostring() + " Minutes"

            if($secondsleft -gt 65){
                Write-Progress -Activity $message -Status $remaining -PercentComplete ($secondsleft * 100 / $OffsetGroup)
                $secondsleft = $secondsleft - 60
                Start-Sleep -seconds 60
            }else{
                Write-Progress -Activity $message -Status $secondsleft -PercentComplete ($secondsleft * 100 / $OffsetGroup)
                $secondsleft = $secondsleft - 1
                start-sleep -seconds 1
            }
        }
    }
}








