function Use-VS2019 {
    <#
    .SYNOPSIS
        Load the build environment for Visual Studio 2019
    .DESCRIPTION
        Load the build environment for Visual Studio 2019 using the Visual Studio 2019 development settings.
    .EXAMPLE
        Use-VS2019
    #>
    param (
        [switch] $UsePreview
    )

    begin {
        Write-HeadingBlock (Get-ModuleHeaderInfo)
    }

    process {
        if ($UsePreview) {
            $version = "Preview"
        } else {
            $version = "Enterprise"
        }

        $shellPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\$version\Common7\Tools"

        if (-not (Test-Path (Split-Path $shellPath -Parent))) {
            exit 1
        }

        Write-Information "------------------------------------------------------------"
        Write-Information " * Setting up environment..."
        Write-Information "   - Visual Studio 2019 ($version) Command Prompt processing."
        Push-Location $shellPath
        cmd /c "VsDevCmd.bat&set" |
        ForEach-Object {
            if ($_ -match "=") {
                $v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
            }
        }
        Pop-Location
        Write-Information "   - Visual Studio 2019 ($version) Command Prompt variables set."
    }

    end {
    }
}


