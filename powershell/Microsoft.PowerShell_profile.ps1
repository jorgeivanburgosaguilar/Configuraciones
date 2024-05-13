function Show-As-Linux {
    param (
        [string]$Path = '.'
    )

    Get-ChildItem -Path $Path -Attributes ReadOnly, Hidden, Directory, Archive, Device, Normal, Temporary, SparseFile, ReparsePoint, Compressed, Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData | ForEach-Object {
        $color = "White"

        # Change color based on attribute
        if ($_.Attributes -match 'Directory') { $color = "DarkCyan" }
        elseif ($_.Attributes -match 'Hidden') { $color = "DarkGray" }
        elseif ($_.Attributes -match 'ReadOnly') { $color = "Gray" }
        elseif ($_.Attributes -match 'Compressed') { $color = "Blue" }

        # Prepare the output string
        $output = "$($_.LastWriteTime)  $($_.Mode)  $([string]::Format("{0,10:N0}", $_.Length))  $_"

        # Write the output with color
        Write-Host $output -ForegroundColor $color
    }
}

function Show-All-Files {
    param (
        [string]$Path = '.'
    )

    Get-ChildItem -Path $Path -Force -Attributes ReadOnly, Hidden, System, Directory, Archive, Device, Normal, Temporary, SparseFile, ReparsePoint, Compressed, Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData | ForEach-Object {
        $color = "White"

        # Change color based on attribute
        if ($_.Attributes -match 'Directory') { $color = "DarkCyan" }
        elseif ($_.Attributes -match 'Hidden') { $color = "DarkGray" }
        elseif ($_.Attributes -match 'System') { $color = "Red" }
        elseif ($_.Attributes -match 'ReadOnly') { $color = "Gray" }
        elseif ($_.Attributes -match 'Compressed') { $color = "Blue" }

        # Prepare the output string
        $output = "$($_.LastWriteTime)  $($_.Mode)  $([string]::Format("{0,10:N0}", $_.Length))  $_"

        # Write the output with color
        Write-Host $output -ForegroundColor $color
    }
}

function ChangeDirectoryToDesarrollo {
	Set-Location C:\Desarrollo\
}

Set-Alias -Name l -Value Show-As-Linux
Set-Alias -Name la -Value Show-All-Files
Set-Alias -Name cddev -Value ChangeDirectoryToDesarrollo