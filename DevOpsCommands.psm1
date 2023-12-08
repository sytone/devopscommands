# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
    Try {
        . $import.fullname
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Update this section as needed.
# - Read in or create an initial config file and variable
# - Set variables visible to the module and its functions only

if ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference) {
    $levelSwitch = New-LevelSwitch -MinimumLevel Verbose
} elseif ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference) {
    $levelSwitch = New-LevelSwitch -MinimumLevel Debug
} else {
    $levelSwitch = New-LevelSwitch -MinimumLevel Information
}

New-Logger |
    Set-MinimumLevel -ControlledBy $levelSwitch |
    # Here you can add as many sinks as you want - see https://github.com/PoShLog/PoShLog/wiki/Sinks for all available sinks
    Add-SinkConsole -OutputTemplate '[{Timestamp:yyyyMMdd-HHmmss}][{Level:u3}] {Message:lj}{NewLine}{Exception}' |
    Start-Logger


function Write-HeadingBlock($Message) {
    Write-InformationLog -Message "--- `e[32m[`e[0m$Message`e[32m]`e[0m ---"
}
function we($message) { Write-ErrorLog $message }
function wf($message) { Write-FatalLog $message }
function wi($message) { Write-InformationLog $message }
function wv($message) { Write-VerboseLog $message }
function ww($message) { Write-WarningLog $message }
function wh($message) { Write-HeadingBlock $message }


# This only exports the public functions and nothing else.
Export-ModuleMember -Function $Public.Basename