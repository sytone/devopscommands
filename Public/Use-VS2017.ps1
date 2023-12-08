function Use-VS2017 {
    <#
    .SYNOPSIS
        Load the build enviroment for Visual Studio 2017
    .DESCRIPTION
        Load the build enviroment for Visual Studio 2017 using the Visual Studio 2017 development settings.
    .EXAMPLE
        Use-VS2017
    #>
    begin {
        wh (Get-ModuleHeaderInfo)
    }

    process {
        wi "------------------------------------------------------------"
        wi "Setting up environment..."
        wi "   - Visual Studio 2017 Command Prompt processing."
        Push-Location "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools"
        cmd /c "VsDevCmd.bat&set" |
            ForEach-Object {
                if ($_ -match "=") {
                    $v = $_.split("="); Set-Item -Force -Path "ENV:\$($v[0])" -Value "$($v[1])"
                }
            }
        Pop-Location
        wi "   - Visual Studio 2017 Command Prompt variables set."
    }

    end {
    }
}

