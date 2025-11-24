function Use-VS2026 {
    <#
    .SYNOPSIS
        Load the build environment for Visual Studio 2026
    .DESCRIPTION
        Load the build environment for Visual Studio 2026 using the Visual Studio 2026 development settings.
    .EXAMPLE
        Use-VS2022
    #>
    param (
        [switch] $UsePreview
    )
    begin {
        Write-HeadingBlock (Get-ModuleHeaderInfo)
        $completedSuccessfully = $false

        # Clean up environment variables to ensure no newlines or excessive length as they cause issues in the shell.
        Get-ChildItem env: | ForEach-Object {
            Repair-EnvironmentVariable -EnvironmentVariableName $_.Name
        }

        $shellPath, $version = Get-VisualStudioDetail -MajorVersion 18 -UsePreview:$UsePreview
    }

    process {

        if (-not (Test-Path (Split-Path $shellPath -Parent))) {
            $completedSuccessfully = $false
        } else {

            Push-Location (Split-Path $shellPath -Parent)
            Write-Information "------------------------------------------------------------"
            Write-Information " * Setting up environment..."
            Write-Information "   - $version Command Prompt processing."
            & $shellPath
            Pop-Location
            Write-Information "   - $version Command Prompt variables set."
            $completedSuccessfully = $true
        }
    }

    end {
        return $completedSuccessfully
    }
}

