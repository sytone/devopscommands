function Get-VisualStudioDetail {
    [CmdletBinding()]
    param (
        [string] $MajorVersion,
        [Switch] $UsePreview
    )
    begin {
    }

    process {
        # Get the Visual Studio 2022 shell path based on the version (Preview or Enterprise).
        $vsLocationDetails = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere" -format json -version $MajorVersion | ConvertFrom-Json

        if ($UsePreview) {
            $vsLocation = $vsLocationDetails | Where-Object { $_.channelId -like "*Preview" }
        } else {
            $vsLocation = $vsLocationDetails | Where-Object { $_.channelId -notlike "*Preview" }
        }

        return ($vsLocation.installationPath + "\Common7\Tools\Launch-VsDevShell.ps1"), ($vsLocation.displayName)
    }

    end {
    }
}