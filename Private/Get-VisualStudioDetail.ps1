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
        $vsLocationDetails = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere" -format json -prerelease | ConvertFrom-Json

        # Find the correct installation based on the parameters. Start with major version filtering.
        $vsLocationDetails = $vsLocationDetails | Where-Object { $_.installationVersion -like "$MajorVersion.*" }

        $usedPreviewFallback = $false

        if ($UsePreview) {
            $vsLocation = $vsLocationDetails | Where-Object { $_.channelId -like "*Preview" }
        } else {
            $vsLocation = $vsLocationDetails | Where-Object { $_.channelId -notlike "*Preview" }
            
            # If release version not found, fallback to preview version
            if (-not $vsLocation) {
                $vsLocation = $vsLocationDetails | Where-Object { $_.channelId -like "*Preview" }
                $usedPreviewFallback = $true
            }
        }

        # Handle case where no installation is found
        if (-not $vsLocation) {
            return $null, $null, $false
        }

        return ("$($vsLocation.installationPath)\Common7\Tools\Launch-VsDevShell.ps1"), ($vsLocation.displayName), $usedPreviewFallback
    }

    end {
    }
}
