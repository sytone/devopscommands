function Repair-EnvironmentVariable {
    [CmdletBinding()]
    param (
        [string] $EnvironmentVariableName
    )
    begin {
    }

    process {
        $variableToCheck = Get-Item "env:$($EnvironmentVariableName)"
        if ($variableToCheck.Value.Contains("`n") -or $variableToCheck.Value.Contains("`r")) {
            Set-Item -Path "env:$($EnvironmentVariableName)" -Value ($variableToCheck.Value -replace "`r`n", " ")
            Write-Verbose "Environment variable '$($EnvironmentVariableName)' contains newlines, replacing with spaces."
        }
        if ($variableToCheck.Value.Length -gt 4096) {
            Set-Item -Path "env:$($EnvironmentVariableName)" -Value $variableToCheck.Value.Substring(0, 4096)
            Write-Verbose "Environment variable '$($EnvironmentVariableName)' exceeds 4096 characters, truncating."
        }
    }

    end {
    }
}