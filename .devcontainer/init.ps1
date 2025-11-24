#!/usr/bin/env pwsh
# DevOpsCommands Codespace Initialization Script

Write-Information "Initializing DevOpsCommands development environment..." -InformationAction Continue

# Install required PowerShell modules
Write-Information "Installing PowerShell modules..." -InformationAction Continue
$modules = @('Psake', 'Pester', 'platyPS', 'SimpleSettings')
foreach ($module in $modules) {
    Write-Information "  - Installing $module..." -InformationAction Continue
    Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
}

Write-Information "Installation complete!" -InformationAction Continue
