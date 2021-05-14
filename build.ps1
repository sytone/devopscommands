[CmdletBinding()]
param(
    # The version of the output module
    [Alias("ModuleVersion")]
    [string]$SemVer
)

$buildconfiguration = Get-Content "$PSScriptRoot\module_config.json" | ConvertFrom-Json

$moduleName = $buildconfiguration.moduleName

$manifestPath = "$PSScriptRoot\$moduleName.psd1"

Write-Information "Validating Manifest..."
$manifest = Test-ModuleManifest -Path $manifestPath

Write-Information "Updating Version..."
if (-not $SemVer) {
    $SemVer = gitversion -showvariable SemVer
}
Write-Output "Old Version: $($manifest.Version)"
Write-Output "New Version: $SemVer"

# Update the manifest with the new version value and fix the weird string replace bug
$functionList = ((Get-ChildItem -Path "$PSScriptRoot\Public").BaseName)
$currentManifest = Import-PowerShellDataFile $manifestPath

$Params = @{
    Path              = $manifestPath
    Copyright         = "Copyright $(Get-Date -Format "yyyy") $($currentManifest.Author)"
    ModuleVersion     = $SemVer
    FunctionsToExport = $functionList
}

if ($buildconfiguration.Copyright) { $Params.Remove("Copyright"); $Params.Add("Copyright", $buildconfiguration.Copyright) }

if ($buildconfiguration.NestedModules) { $Params.Add("NestedModules", $buildconfiguration.NestedModules) }
if ($buildconfiguration.Guid) { $Params.Add("Guid", $buildconfiguration.Guid) }
if ($buildconfiguration.Author) { $Params.Add("Author", $buildconfiguration.Author) }
if ($buildconfiguration.CompanyName) { $Params.Add("CompanyName", $buildconfiguration.CompanyName) }
if ($buildconfiguration.RootModule) { $Params.Add("RootModule", $buildconfiguration.RootModule) }
if ($buildconfiguration.Description) { $Params.Add("Description", $buildconfiguration.Description) }
if ($buildconfiguration.ProcessorArchitecture) { $Params.Add("ProcessorArchitecture", $buildconfiguration.ProcessorArchitecture) }
if ($buildconfiguration.CompatiblePSEditions) { $Params.Add("CompatiblePSEditions", $buildconfiguration.CompatiblePSEditions) }
if ($buildconfiguration.PowerShellVersion) { $Params.Add("PowerShellVersion", $buildconfiguration.PowerShellVersion) }
if ($buildconfiguration.ClrVersion) { $Params.Add("ClrVersion", $buildconfiguration.ClrVersion) }
if ($buildconfiguration.DotNetFrameworkVersion) { $Params.Add("DotNetFrameworkVersion", $buildconfiguration.DotNetFrameworkVersion) }
if ($buildconfiguration.PowerShellHostName) { $Params.Add("PowerShellHostName", $buildconfiguration.PowerShellHostName) }
if ($buildconfiguration.PowerShellHostVersion) { $Params.Add("PowerShellHostVersion", $buildconfiguration.PowerShellHostVersion) }
if ($buildconfiguration.RequiredModules) { $Params.Add("RequiredModules", $buildconfiguration.RequiredModules) }
if ($buildconfiguration.TypesToProcess) { $Params.Add("TypesToProcess", $buildconfiguration.TypesToProcess) }
if ($buildconfiguration.FormatsToProcess) { $Params.Add("FormatsToProcess", $buildconfiguration.FormatsToProcess) }
if ($buildconfiguration.ScriptsToProcess) { $Params.Add("ScriptsToProcess", $buildconfiguration.ScriptsToProcess) }
if ($buildconfiguration.RequiredAssemblies) { $Params.Add("RequiredAssemblies", $buildconfiguration.RequiredAssemblies) }
if ($buildconfiguration.FileList) { $Params.Add("FileList", $buildconfiguration.FileList) }
if ($buildconfiguration.ModuleList) { $Params.Add("ModuleList", $buildconfiguration.ModuleList) }
if ($buildconfiguration.AliasesToExport) { $Params.Add("AliasesToExport", $buildconfiguration.AliasesToExport) }
if ($buildconfiguration.VariablesToExport) { $Params.Add("VariablesToExport", $buildconfiguration.VariablesToExport) }
if ($buildconfiguration.CmdletsToExport) { $Params.Add("CmdletsToExport", $buildconfiguration.CmdletsToExport) }
if ($buildconfiguration.DscResourcesToExport) { $Params.Add("DscResourcesToExport", $buildconfiguration.DscResourcesToExport) }
if ($buildconfiguration.PrivateData) { $Params.Add("PrivateData", $buildconfiguration.PrivateData) }
if ($buildconfiguration.Tags) { $Params.Add("Tags", $buildconfiguration.Tags) }
if ($buildconfiguration.ProjectUri) { $Params.Add("ProjectUri", $buildconfiguration.ProjectUri) }
if ($buildconfiguration.LicenseUri) { $Params.Add("LicenseUri", $buildconfiguration.LicenseUri) }
if ($buildconfiguration.IconUri) { $Params.Add("IconUri", $buildconfiguration.IconUri) }
if ($buildconfiguration.ReleaseNotes) { $Params.Add("ReleaseNotes", $buildconfiguration.ReleaseNotes) }
if ($buildconfiguration.Prerelease) { $Params.Add("Prerelease", $buildconfiguration.Prerelease) }
if ($buildconfiguration.HelpInfoUri) { $Params.Add("HelpInfoUri", $buildconfiguration.HelpInfoUri) }
if ($buildconfiguration.PassThru) { $Params.Add("PassThru", $buildconfiguration.PassThru) }
if ($buildconfiguration.DefaultCommandPrefix) { $Params.Add("DefaultCommandPrefix", $buildconfiguration.DefaultCommandPrefix) }
if ($buildconfiguration.ExternalModuleDependencies) { $Params.Add("ExternalModuleDependencies", $buildconfiguration.ExternalModuleDependencies) }
if ($buildconfiguration.PackageManagementProviders) { $Params.Add("PackageManagementProviders", $buildconfiguration.PackageManagementProviders) }
if ($buildconfiguration.RequireLicenseAcceptance) { $Params.Add("RequireLicenseAcceptance", $buildconfiguration.RequireLicenseAcceptance) }


Update-ModuleManifest @Params

(Get-Content -Path $manifestPath) -replace "PSGet_$moduleName", $moduleName | Set-Content -Path $manifestPath
(Get-Content -Path $manifestPath) -replace 'NewManifest', $moduleName | Set-Content -Path $manifestPath
(Get-Content -Path $manifestPath) -replace 'FunctionsToExport = ', 'FunctionsToExport = @(' | Set-Content -Path $manifestPath -Force
(Get-Content -Path $manifestPath) -replace "$($functionList[-1])'", "$($functionList[-1])')" | Set-Content -Path $manifestPath -Force


# Create new markdown and XML help files
Write-Information "Building new function documentation"
Import-Module -Name "$PSScriptRoot\$moduleName.psm1" -Force
Get-Module $moduleName
Write-Information "Updating markdown based help"
New-MarkdownHelp -Module $moduleName -OutputFolder .\docs -ErrorAction SilentlyContinue
Update-MarkdownHelp "$PSScriptRoot\docs"
Write-Information "Building new xml file for help"
New-ExternalHelp -Path "$PSScriptRoot\docs" -OutputPath "$PSScriptRoot\en-US\" -Force

# Package for Publish
New-Item -Path ./publish -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path ./docs -Destination ./publish/docs -Recurse

return

if (Get-Command -Name "Get-SimpleSetting") {
    $publishKey = Get-SimpleSetting -Section "PowerShellGallery" -Name "DefaultApiKey"
    Publish-Module -Path "." -NuGetApiKey $publishKey
}
