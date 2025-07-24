# Check to see if the aliases are set. If they already exist then do not set them again.
if (Get-Alias -Name msb -ErrorAction SilentlyContinue) {
    Write-Information  "Aliases already set. Skipping alias creation."
    return
} else {
    Write-Information  "Setting aliases for MSBuild commands."
    New-Alias -Name msb -Value Start-MSBuild -Scope Global
    New-Alias -Name msbr -Value Start-MSBuildRelease -Scope Global
}
