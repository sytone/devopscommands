function Invoke-Call {
    <#
    $callback = {
        param($message)
        Write-Information "$message"
    }
    $ExitCode, $Output = Invoke-Call "MSBuild" "/noLogo /m /nr:false /p:TreatWarningsAsErrors=true /p:Platform=x64" $callback
    #>
    param(
        [string]$Exe,
        [string[]]$CommandArguments,
        [scriptblock]$MessageCallback = { param($message) Write-Information "$message" },
        [scriptblock]$ErrorCallback = { param($exception) Write-Error $exception }
    )

    Write-Verbose "Command: $Exe"
    Write-Verbose "Arguments: $CommandArguments, $($CommandArguments.Count)"
    Write-Verbose "Message Callback: $MessageCallback"
    Write-Verbose "Expression: $Exe $($CommandArguments -join " ")"

    # Disable ErrorActionPreference temporarily https://stackoverflow.com/questions/10666101/lastexitcode-0-but-false-in-powershell-redirecting-stderr-to-stdout-gives
    $SaveErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    # Refer to https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe
    $Output = Invoke-Expression "$Exe $($CommandArguments -join " ")" 2>&1 | ForEach-Object {
        if ($_ -Is [System.Management.Automation.ErrorRecord]) {
            & $ErrorCallback $_.Exception
        } else {
            & $MessageCallback $_
        }
    }

    $ExitCode = $LastExitCode

    # Reset ErrorActionPreference
    $ErrorActionPreference = $SaveErrorActionPreference

    return $ExitCode, $Output
}