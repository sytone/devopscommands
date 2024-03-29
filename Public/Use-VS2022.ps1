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
        wh (Get-ModuleHeaderInfo)
        $completedSucessfully = $false
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

        if (!(Test-Path $shellPath)) {
            $shellPath = "C:\Program Files\Microsoft Visual Studio\2022\Preview\Common7\Tools\Launch-VsDevShell.ps1"
            $version = "Preview"
        }

        if (-not (Test-Path (Split-Path $shellPath -Parent))) {
            $completedSucessfully = $false
        }
        else {

            Push-Location (Split-Path $shellPath -Parent)
            wi "------------------------------------------------------------"
            wi " * Setting up environment..."
            wi "   - Visual Studio 2022 ($version) Command Prompt processing."
            & $shellPath
            Pop-Location
            wi "   - Visual Studio 2022 ($version) Command Prompt variables set."
            $completedSucessfully = $true
        }

    }

    end {
        return $completedSucessfully
    }
}


