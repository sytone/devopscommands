function Use-VS2022 {
    param (
        [switch] $UsePreview
    )
    <#
  .SYNOPSIS
      Load the build enviroment for Visual Studio 2022
  .DESCRIPTION
      Load the build enviroment for Visual Studio 2022 using the Visual Studio 2022 development settings.
  .EXAMPLE
      Use-VS2022
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

        $version = "Enterprise"
        $shellPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1"

        if(!(Test-Path $shellPath)) {
            $shellPath = "C:\Program Files\Microsoft Visual Studio\2022\Preview\Common7\Tools\Launch-VsDevShell.ps1"
            $version = "Preview"
        }

        if(-not (Test-Path (Split-Path $shellPath -Parent))) {
            return $false
        }

        Push-Location (Split-Path $shellPath -Parent)
        Write-Information "`n------------------------------------------------------------"
        Write-Information " * Setting up environment..."
        Write-Information "   - Visual Studio 2022 ($version) Command Prompt processing."
        & $shellPath
        Pop-Location
        Write-Information "   - Visual Studio 2022 ($version) Command Prompt variables set."
    }

    end {
        return $true
    }
}


