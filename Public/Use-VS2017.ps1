function Use-VS2017 {
    <#
    .SYNOPSIS
        Load the build enviroment for Visul Studio 2017
    .DESCRIPTION
        Load the build enviroment for Visul Studio 2017 using the Visual Studio 2017 development settings.
    .EXAMPLE
        Use-VS2017
    #>
    begin {
        Write-Information (Get-ModuleHeaderInfo)
    }

    process {
        Write-Information "`n------------------------------------------------------------"
        Write-Information " * Setting up environment..."
        Write-Information "   - Visual Studio 2017 Command Prompt processing."
        Push-Location "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools"
        cmd /c "VsDevCmd.bat&set" |
        ForEach-Object {
            if ($_ -match "=") {
                $v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
            }
        }
        Pop-Location
        Write-Information "   - Visual Studio 2017 Command Prompt variables set."
    }

    end {
    }
}

