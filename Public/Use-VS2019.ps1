function Use-VS2019 {
    param (
        [switch] $UsePreview
    )
    <#
  .SYNOPSIS
      Load the build enviroment for Visul Studio 2019
  .DESCRIPTION
      Load the build enviroment for Visul Studio 2019 using the Visual Studio 2019 development settings.
  .EXAMPLE
      Use-VS2019
  #>
    begin {
        Write-Information (Get-ModuleHeaderInfo)
    }

    process {
        if ($UsePreview) {
            $version = "Preview"
        }
        else {
            $version = "Enterprise"
        }
        Write-Information "`n------------------------------------------------------------"
        Write-Information " * Setting up environment..."
        Write-Information "   - Visual Studio 2019 ($version) Command Prompt processing."
        Push-Location "C:\Program Files (x86)\Microsoft Visual Studio\2019\$version\Common7\Tools"
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


