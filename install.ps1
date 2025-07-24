$envLoadLine = "`n. Import-Module -Name '$PSScriptRoot\DevOpsCommands' -Force   #DEVOPSCOMMANDS`n"

Write-Information  "Checking for $profile"
if ((Test-Path $profile) -eq $false) {
    Write-Information  "$profile is missing, creating a new file"
    New-Item $profile -type file -force -ea 0 | Out-Null
    $envLoadLine | Set-Content  ($profile)
} else {
    Write-Information  "$profile is found, checking to see if DEVOPSCOMMANDS exists"
    (Get-Content ($profile)) | Foreach-Object {
        $_ -replace '^.+#DEVOPSCOMMANDS.+$', ($envLoadLine)
    } | Set-Content  ($profile)

    $mi = Select-String -Path $profile -Pattern "#DEVOPSCOMMANDS"
    if (!$mi.Matches) {
        Write-Information  "DEVOPSCOMMANDS is missing, adding it to the profile."
        $profileData = (Get-Content ($profile))
        ($profileData += $envLoadLine) | Set-Content  ($profile)
    }
}