Function Update-ElvUI {
<#
    .SYNOPSIS
    Updates ElvUI

    .DESCRIPTION
    Checks the local ElvUI.toc vs the Web version and downloads if there is a newer version, replacing existing one.
    Addon folder can be passed to the script, if not specified C:\Program Files(x86)\World of Warcraft is the default folder

    .EXAMPLE
    PS> . .\wow.ps1  #sourcing wow.ps1
    PS> Update-ElvUI  ## Use -force if you want to download the latest version anyway
    VERBOSE: 2016-07-28_19:27: ElvUI Tool Folder: C:\Program Files (x86)\World of Warcraft\Interface\AddOns\ElvUI
    VERBOSE: 2016-07-28_19:27: Current Version: 10.12
    VERBOSE: GET http://www.tukui.org/dl.php with 0-byte payload
    VERBOSE: received -1-byte response of content type text/html; charset=UTF-8
    VERBOSE: 2016-07-28_19:27: Web Version: 10.12
    VERBOSE: 2016-07-28_19:27: We already have the latest version
    VERBOSE: 2016-07-28_19:27: All done!

    .EXAMPLE
    PS> #This forces and update, even if the version is the same
    PS> update-elvui -WoWFolder 'C:\Program Files (x86)\World of Warcraft\' -force  
    VERBOSE: 2017-01-19_17:42: ElvUI Tool Folder: C:\Program Files (x86)\World of Warcraft\Interface\Addons\ElvUI
    VERBOSE: 2017-01-19_17:42: Current Version: 10.41
    VERBOSE: GET http://www.tukui.org/dl.php with 0-byte payload
    VERBOSE: received -1-byte response of content type text/html; charset=UTF-8
    Vector smash protection is enabled.
    VERBOSE: 2017-01-19_17:42: Web Version: 10.41
    VERBOSE: 2017-01-19_17:42: Force Switch has been used. Proceeding!
    VERBOSE: 2017-01-19_17:42: Downloading as C:\Users\adil\AppData\Local\Temp\10.41
    VERBOSE: GET http://www.tukui.org/downloads/elvui-10.41.zip with 0-byte payload
    VERBOSE: received 3331221-byte response of content type application/zip
    VERBOSE: 2017-01-19_17:42: Extracting to C:\Users\adil\AppData\Local\Temp
    VERBOSE: 2017-01-19_17:43: Copying ElvUI to C:\Program Files (x86)\World of Warcraft\Interface\Addons\ElvUI


        Directory: C:\Program Files (x86)\World of Warcraft\Interface\Addons


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    d-----        12/8/2016   6:16 PM                .gitlab

    ...
    VERBOSE: 2017-01-19_17:43: Web Version: 10.41
    VERBOSE: 2017-01-19_17:43: Current Version: 10.41
    VERBOSE: 2017-01-19_17:43: All done!

#>
[CMDLETBINDING()]
param (
            [ValidateScript({test-path $_})]
            [string]$WoWFolder='C:\Program Files (x86)\World of Warcraft\',
            
            [switch]$force
        )

    Function Get-LatestElvUIFromWeb {        
        $downloadLink = $href
        &$log "Downloading as $ENV:temp\$WebVersion"
        Invoke-WebRequest -Uri "$downloadLink" -OutFile "$ENV:temp\$WebVersion.zip"


        &$log "Extracting to $env:temp"
        $shell = New-Object -ComObject shell.application
        $zip=$shell.namespace("$ENV:temp\$WebVersion.zip")
        $yesToAll=16
        $null = new-item -path "$ENV:temp\ElvUI$webVersion" -ItemType Directory -Force
        foreach ($item in $zip.items()) { 
            $shell.NameSpace("$ENV:temp\ElvUI$webVersion").copyhere($item,$yesToAll) 
        }


        &$log "Copying ElvUI to $ElvUIFolder"
        copy-item -Path "$ENV:temp\ElvUI$webVersion\*" -Destination "$AddOnFolder" -recurse -Force  -PassThru

        $currentVersion = Get-CurrentElvUIVersion

        &$log "Web Version: $WebVersion"
        &$log "Current Version: $currentVersion"
        

    }  
    
    
    $VerbosePreference ='Continue'
    $log = {
        param ([string]$msg)
        Write-Verbose "$(get-date -Format 'yyyy-MM-dd_HH:mm'): $msg"    
    }

    [string]$AddonFolder = join-path $WoWFolder 'Interface\Addons'
    [string]$ElvUIFolder= join-path $AddonFolder 'ElvUI'

    &$log "ElvUI Tool Folder: $ElvUIFolder"

    Function Get-CurrentElvUIVersion {
        $ElvUIToc = join-path $ElvUIFolder 'Elvui.toc'
        [version]( ((gc $ElvUIToc).where{$_ -match 'Version'}).split(': ')[3])
    }

    $CurrentElvUIVersion = Get-CurrentElvUIVersion
    &$log "Current Version: $CurrentElvUIVersion"

    $url = 'http://www.tukui.org/dl.php'
    $r1 = Invoke-WebRequest -Uri $url

    $href= ($r1.links.href).where{$_ -match 'elvui.*zip'} ## http://www.tukui.org/downloads/elvui-10.12.zip
    # We rely on the link format used on Web site for download: ElvUI-{version}.zip
    $WebVersion = [version](($href.split('/'))[-1] -replace '.zip' -replace 'ElvUI-')  #Major:9 , Minor:90

    
    &$log "Web Version: $WebVersion"

    

        if ($force) {

        &$log "Force Switch has been used. Proceeding!"
        Get-LatestElvUIFromWeb
        
    } elseif (( $WebVersion.Major -gt $CurrentElvUIVersion.Major) -or (( $WebVersion.Major -eq $CurrentElvUIVersion.Major) -and ($WebVersion.Minor -gt $CurrentElvUIVersion.Minor))) {
  

            &$log "Web version seems to be newer. " 
            # We are doing this b/c 10.0.4 is advertised as 10.04 on site. So [version].Minor comparison may not be accurate

                                
                Get-LatestElvUIFromWeb      
        
       } else {
        
    
        &$log "We already have the latest version"
    
    }

    &$log "All done!"
}

Function Backup-WoWAddons {
<#
    .SYNOPSIS
    Backups Wow Addons

    .DESCRIPTION
    Backups WowAddons. If BackupRoot is not passed to the function, it will create a backup folder 
    under current World of Warcraft\Interface folder

    .EXAMPLE
    PS> # Source wow.ps1 & run backup-wowaddons
    PS> . .\Wow.ps1
    PS> Backup-WowAddons
    ...
    C:\Program Files (x86)\World of Warcraft\WTF\Account\HINDISTAN\SavedVariables\WeakAurasOptions.lua.bak
    361 File(s) copied
    VERBOSE: 2017-01-19_17:23: Addons Folder: C:\Program Files (x86)\World of Warcraft\Interface\AddOns
    VERBOSE: 2017-01-19_17:23: WTF Folder: C:\Program Files (x86)\World of Warcraft\WTF
    VERBOSE: 2017-01-19_17:23: Backup Folder: C:\Program Files (x86)\World of Warcraft\Interface\Backup-2017-01-19_1723
#>
    [cmdletbinding()]
    param(
        $BackupRoot
    )

    $VerbosePreference ='Continue'
    $log = {
        param ([string]$msg)
        Write-Verbose "$(get-date -Format 'yyyy-MM-dd_HH:mm'): $msg"    
    }

    $InterfaceFolder = 'C:\Program Files (x86)\World of Warcraft\Interface'
    $WTFFolder ='C:\Program Files (x86)\World of Warcraft\WTF'
    
    $AddonsFolder = Join-Path $InterfaceFolder 'AddOns'

    if (!($BackupRoot)) {
        $BackupRoot = $InterfaceFolder
    }

    $BackupName = "Backup-$(get-date -Format 'yyyy-MM-dd_HHmm')"
    
    $BackupFolder = Join-Path $BackupRoot $BackupName
    
   
    #Copy-Item -path "$AddonsFolder\*" -Destination $BackupFolder -Recurse -PassThru -force
    xcopy /S /E /I "$AddonsFolder\*" "$BackupFolder\Addons"  # /I telling it we want the destination directory to be created
    xcopy /S /E /I "$WTFFolder\*" "$BackupFolder\WTF"

    &$log "Addons Folder: $AddonsFolder"
    &$log "WTF Folder: $WTFFolder"
    &$log "Backup Folder: $BackupFolder"
}



