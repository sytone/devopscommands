# PSake build file for DevOpsCommands module
# Usage: Invoke-PSake psakefile.ps1 -taskList <TaskName>

Properties {
    # Build configuration
    $ModuleName = (Get-Content "$PSScriptRoot\module_config.json" | ConvertFrom-Json).ModuleName
    $ManifestPath = "$PSScriptRoot\$ModuleName.psd1"
    $PublishPath = "$PSScriptRoot\publish"
    $TestResultsPath = "$PSScriptRoot\TestResults"

    # Default version if not specified
    $SemVer = "0.0.0"
    $Publish = $false

    # Paths
    $DocsPath = "$PSScriptRoot\docs"
    $PublicPath = "$PSScriptRoot\Public"
    $PrivatePath = "$PSScriptRoot\Private"
    $TestsPath = "$PSScriptRoot\Tests"
    $EnUSPath = "$PSScriptRoot\en-US"
}

# Default task
Task Default -Depends Build

# Meta tasks that combine multiple steps
Task Build -Depends ValidateManifest, UpdateVersion, UpdateManifest, GenerateDocumentation, PackageModule {
    Write-Host "Build completed successfully!" -ForegroundColor Green
}

Task Test -Depends Build, RunTests {
    Write-Host "All tests completed!" -ForegroundColor Green
}

Task Publish -Depends Build, Test, PublishModule {
    Write-Host "Module published successfully!" -ForegroundColor Green
}

Task Clean -Depends CleanPublish, CleanTestResults {
    Write-Host "Clean completed!" -ForegroundColor Green
}

Task FullBuild -Depends Clean, Build, Test {
    Write-Host "Full build pipeline completed!" -ForegroundColor Green
}

# Individual tasks
Task ValidateManifest {
    Write-Host "Validating module manifest..." -ForegroundColor Yellow
    $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    $script:CurrentVersion = $manifest.Version
    Write-Host "Manifest Version: $script:CurrentVersion" -ForegroundColor Cyan

    Write-Host "✓ Manifest validation passed" -ForegroundColor Green
}

Task UpdateVersion -Depends ValidateManifest {
    Write-Host "Updating module version..." -ForegroundColor Yellow

    Write-Host "Current Version: $script:CurrentVersion" -ForegroundColor Cyan
    Write-Host "Specified Version: $SemVer" -ForegroundColor Cyan

    if ($SemVer -eq "0.0.0") {
        Write-Host "No version specified, using current version from manifest." -ForegroundColor Cyan
        $SemVer = $script:CurrentVersion
    }

    Write-Host "New Version: $SemVer" -ForegroundColor Cyan
}

Task UpdateManifest -Depends UpdateVersion {
    Write-Host "Updating module manifest..." -ForegroundColor Yellow

    # Get function list from Public folder
    $functionList = (Get-ChildItem -Path $PublicPath -Filter "*.ps1").BaseName
    Write-Host "Functions to export: $($functionList -join ', ')" -ForegroundColor Cyan

    # Load build configuration
    $buildConfiguration = Get-Content "$PSScriptRoot\module_config.json" | ConvertFrom-Json
    $currentManifest = Import-PowerShellDataFile $ManifestPath

    if ($SemVer -eq "0.0.0") {
        Write-Host "No version specified, using current version from manifest." -ForegroundColor Cyan
        $SemVer = $script:CurrentVersion
    }

    # Build parameters for Update-ModuleManifest
    $Params = @{
        Path              = $ManifestPath
        ModuleVersion     = $SemVer
        FunctionsToExport = $functionList
        Copyright         = "Copyright $(Get-Date -Format 'yyyy') $($buildConfiguration.Author)"
    }

    # Add optional parameters from configuration
    $configProperties = @(
        'NestedModules', 'Guid', 'Author', 'CompanyName', 'RootModule', 'Description',
        'ProcessorArchitecture', 'CompatiblePSEditions', 'PowerShellVersion', 'ClrVersion',
        'DotNetFrameworkVersion', 'PowerShellHostName', 'PowerShellHostVersion',
        'RequiredModules', 'TypesToProcess', 'FormatsToProcess', 'ScriptsToProcess',
        'RequiredAssemblies', 'FileList', 'ModuleList', 'AliasesToExport',
        'VariablesToExport', 'CmdletsToExport', 'DscResourcesToExport', 'PrivateData',
        'Tags', 'ProjectUri', 'LicenseUri', 'IconUri', 'ReleaseNotes', 'Prerelease',
        'HelpInfoUri', 'PassThru', 'DefaultCommandPrefix', 'ExternalModuleDependencies',
        'PackageManagementProviders', 'RequireLicenseAcceptance'
    )

    foreach ($property in $configProperties) {
        if ($buildConfiguration.$property) {
            $Params[$property] = $buildConfiguration.$property
        }
    }

    # Override copyright if specified in config
    if ($buildConfiguration.Copyright) {
        $Params['Copyright'] = $buildConfiguration.Copyright
    }

    Update-ModuleManifest @Params

    # Fix manifest formatting issues
    (Get-Content -Path $ManifestPath) -replace "PSGet_$ModuleName", $ModuleName | Set-Content -Path $ManifestPath
    (Get-Content -Path $ManifestPath) -replace 'NewManifest', $ModuleName | Set-Content -Path $ManifestPath
    (Get-Content -Path $ManifestPath) -replace 'FunctionsToExport = ', 'FunctionsToExport = @(' | Set-Content -Path $ManifestPath -Force
    (Get-Content -Path $ManifestPath) -replace "$($functionList[-1])'", "$($functionList[-1])')" | Set-Content -Path $ManifestPath -Force

    Write-Host "✓ Module manifest updated" -ForegroundColor Green
}

Task GenerateMarkdownHelp -Depends UpdateManifest {
    Write-Host "Generating markdown help documentation..." -ForegroundColor Yellow

    Write-Host "Using module: $ModuleName" -ForegroundColor Cyan
    Import-Module -Name "$PSScriptRoot\$ModuleName.psm1" -Force -Global
    $moduleDetails = Get-Module $ModuleName
    if (-not $moduleDetails) {
        Write-Error "Failed to import module: $ModuleName"
        throw "Module import failed"
    }

    # Ensure PlatyPS module is available
    if (-not (Get-Module -ListAvailable -Name PlatyPS)) {
        Write-Warning "PlatyPS module not found. Install with: Install-Module PlatyPS -Scope CurrentUser"
        throw "PlatyPS module is required for documentation generation"
    }

    Import-Module PlatyPS -Force

    # Generate new markdown help files
    New-MarkdownHelp -Module $ModuleName -OutputFolder $DocsPath -ErrorAction SilentlyContinue

    # Update existing markdown help
    Update-MarkdownHelp $DocsPath

    Write-Host "✓ Markdown help generated" -ForegroundColor Green
}

Task GenerateExternalHelp -Depends GenerateMarkdownHelp {
    Write-Host "Generating external XML help..." -ForegroundColor Yellow

    # Generate XML help from markdown
    New-ExternalHelp -Path $DocsPath -OutputPath $EnUSPath -Force

    Write-Host "✓ External XML help generated" -ForegroundColor Green
}

Task GenerateDocumentation -Depends GenerateExternalHelp {
    Write-Host "✓ All documentation generated successfully" -ForegroundColor Green
}

Task CleanPublish {
    Write-Host "Cleaning publish directory..." -ForegroundColor Yellow

    if (Test-Path $PublishPath) {
        Get-ChildItem $PublishPath -Recurse | Remove-Item -Force -Recurse
        Write-Host "✓ Publish directory cleaned" -ForegroundColor Green
    } else {
        Write-Host "✓ Publish directory already clean" -ForegroundColor Green
    }
}

Task CleanTestResults {
    Write-Host "Cleaning test results..." -ForegroundColor Yellow

    # Clean up test result files
    Get-ChildItem "$PSScriptRoot\PesterResults_PS*.xml" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem "$PSScriptRoot\TestResults_PS*.xml" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem "$PSScriptRoot\Tests\test-config.*" -ErrorAction SilentlyContinue | Remove-Item -Force

    if (Test-Path $TestResultsPath) {
        Remove-Item $TestResultsPath -Recurse -Force
    }

    Write-Host "✓ Test results cleaned" -ForegroundColor Green
}

Task CreatePublishStructure -Depends CleanPublish {
    Write-Host "Creating publish directory structure..." -ForegroundColor Yellow

    $modulePublishPath = "$PublishPath\$ModuleName"
    New-Item -Path $modulePublishPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✓ Publish structure created" -ForegroundColor Green
}

Task CopyModuleFiles -Depends CreatePublishStructure, GenerateDocumentation {
    Write-Host "Copying module files for publishing..." -ForegroundColor Yellow

    $modulePublishPath = "$PublishPath\$ModuleName"

    # Copy essential directories and files
    $itemsToCopy = @(
        @{ Source = $DocsPath; Name = "docs" }
        @{ Source = $EnUSPath; Name = "en-US" }
        @{ Source = $PublicPath; Name = "Public" }
        @{ Source = $PrivatePath; Name = "Private" }
        @{ Source = "$PSScriptRoot\$ModuleName.psd1"; Name = "$ModuleName.psd1" }
        @{ Source = "$PSScriptRoot\$ModuleName.psm1"; Name = "$ModuleName.psm1" }
        @{ Source = "$PSScriptRoot\README.md"; Name = "README.md" }
        @{ Source = "$PSScriptRoot\LICENSE"; Name = "LICENSE" }
    )

    foreach ($item in $itemsToCopy) {
        if (Test-Path $item.Source) {
            Copy-Item -Path $item.Source -Destination $modulePublishPath -Recurse -Force
            Write-Host "  ✓ Copied $($item.Name)" -ForegroundColor Cyan
        } else {
            Write-Warning "Source not found: $($item.Source)"
        }
    }

    Write-Host "✓ Module files copied to publish directory" -ForegroundColor Green
}

Task PackageModule -Depends CopyModuleFiles {
    Write-Host "✓ Module packaged for publishing" -ForegroundColor Green
}

Task RunTests -Depends ValidateTestEnvironment {
    Write-Host "Running Pester tests..." -ForegroundColor Yellow

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    Write-Host "Testing with PowerShell $PSVersion" -ForegroundColor Cyan

    # Import Pester
    Import-Module Pester -Force

    # Configure Pester
    $config = [PesterConfiguration]::Default
    $config.Run.Path = $TestsPath
    $config.Output.Verbosity = "Detailed"
    $config.Run.PassThru = $true
    $config.TestResult.OutputFormat = "NUnitXml"
    $config.TestResult.OutputPath = "$PSScriptRoot\$TestFile"

    # Run tests
    $results = Invoke-Pester -Configuration $config

    # Export results
    $results | Export-Clixml -Path "$PSScriptRoot\PesterResults_PS$PSVersion`_$Timestamp.xml"

    # Process results
    $AllFiles = Get-ChildItem -Path "$PSScriptRoot\PesterResults*.xml" | Select-Object -ExpandProperty FullName
    Write-Host "Test result files: $($AllFiles -join ', ')" -ForegroundColor Cyan

    # Check for failures
    $TestResults = @(Get-ChildItem -Path "$PSScriptRoot\PesterResults_PS*.xml" | Import-Clixml)
    $FailedCount = $TestResults | Select-Object -ExpandProperty FailedCount | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    Write-Host "Failed Count: $FailedCount" -ForegroundColor $(if ($FailedCount -eq 0) { 'Green' } else { 'Red' })

    if ($FailedCount -gt 0) {
        $FailedItems = $TestResults | Select-Object -ExpandProperty Tests | Where-Object { $_.Passed -notlike $True }

        Write-Host "FAILED TESTS SUMMARY:" -ForegroundColor Red
        $FailedItems | ForEach-Object {
            $Item = $_
            [PSCustomObject]@{
                Describe = $Item.Describe
                Context  = $Item.Context
                Name     = "It $($Item.Name)"
                Result   = $Item.Result
            }
        } | Sort-Object Describe, Context, Name, Result | Format-List

        # Clean up test files
        Remove-Item "$PSScriptRoot\PesterResults_PS*.xml" -Force -ErrorAction SilentlyContinue
        Remove-Item "$PSScriptRoot\TestResults_PS*.xml" -Force -ErrorAction SilentlyContinue
        Remove-Item "$PSScriptRoot\Tests\test-config.*" -Force -ErrorAction SilentlyContinue

        throw "$FailedCount tests failed."
    }

    # Clean up test files on success
    Remove-Item "$PSScriptRoot\PesterResults_PS*.xml" -Force -ErrorAction SilentlyContinue
    Remove-Item "$PSScriptRoot\TestResults_PS*.xml" -Force -ErrorAction SilentlyContinue
    Remove-Item "$PSScriptRoot\Tests\test-config.*" -Force -ErrorAction SilentlyContinue

    Write-Host "✓ All tests passed!" -ForegroundColor Green
}

Task ValidateTestEnvironment {
    Write-Host "Validating test environment..." -ForegroundColor Yellow

    # Check if Tests directory exists
    if (-not (Test-Path $TestsPath)) {
        throw "Tests directory not found at: $TestsPath"
    }

    # Check if Pester is available
    if (-not (Get-Module -ListAvailable -Name Pester)) {
        Write-Warning "Pester module not found. Install with: Install-Module Pester -Scope CurrentUser"
        throw "Pester module is required for testing"
    }

    # Check for test files
    $testFiles = Get-ChildItem -Path $TestsPath -Filter "*.tests.ps1"
    if ($testFiles.Count -eq 0) {
        Write-Warning "No test files found in $TestsPath"
    } else {
        Write-Host "Found $($testFiles.Count) test file(s)" -ForegroundColor Cyan
    }

    Write-Host "✓ Test environment validated" -ForegroundColor Green
}

Task PublishModule -Depends PackageModule {
    Write-Host "Publishing module to PowerShell Gallery..." -ForegroundColor Yellow

    if (-not $Publish) {
        Write-Host "Publish flag not set. Skipping publication." -ForegroundColor Cyan
        return
    }

    # Check if Get-SimpleSetting is available (used for API key)
    if (-not (Get-Command -Name 'Get-SimpleSetting' -ErrorAction SilentlyContinue)) {
        throw "Get-SimpleSetting command not found. This is required to retrieve the PowerShell Gallery API key."
    }

    try {
        $publishKey = Get-SimpleSetting -Section 'PowerShellGallery' -Name 'DefaultApiKey'
        if (-not $publishKey) {
            Write-Host "PowerShell Gallery API key not found in settings." -ForegroundColor Red
            Write-Host "Please set the API key using: Set-SimpleSetting -Section 'PowerShellGallery' -Name 'DefaultApiKey' -Value '<YourApiKey>'" -ForegroundColor Yellow
            throw "PowerShell Gallery API key not found in settings."
        }

        $modulePublishPath = "$PublishPath\$ModuleName"
        Publish-Module -Path $modulePublishPath -NuGetApiKey $publishKey

        Write-Host "✓ Module published to PowerShell Gallery successfully!" -ForegroundColor Green
    } catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
        throw
    }
}

Task ShowHelp {
    Write-Host @"
Available PSake Tasks:
======================

Primary Tasks:
  Default       - Runs Build (default task)
  Build         - Complete build process (ValidateManifest -> UpdateVersion -> UpdateManifest -> GenerateDocumentation -> PackageModule)
  Test          - Run build and tests (Build -> RunTests)
  Publish       - Full pipeline with publish (Build -> Test -> PublishModule)
  Clean         - Clean build artifacts (CleanPublish -> CleanTestResults)
  FullBuild     - Complete pipeline (Clean -> Build -> Test)

Individual Tasks:
  ValidateManifest      - Validate the module manifest
  UpdateVersion         - Update version information
  UpdateManifest        - Update the module manifest
  GenerateMarkdownHelp  - Generate markdown help files
  GenerateExternalHelp  - Generate XML help files
  GenerateDocumentation - Generate all documentation
  CleanPublish         - Clean publish directory
  CleanTestResults     - Clean test result files
  CreatePublishStructure - Create publish directory structure
  CopyModuleFiles      - Copy files to publish directory
  PackageModule        - Package module for publishing
  RunTests             - Run Pester tests
  ValidateTestEnvironment - Validate test environment
  PublishModule        - Publish to PowerShell Gallery

Usage Examples:
  Invoke-PSake psakefile.ps1
  Invoke-PSake psakefile.ps1 -taskList Build
  Invoke-PSake psakefile.ps1 -taskList Test
  Invoke-PSake psakefile.ps1 -taskList Clean,Build,Test
  Invoke-PSake psakefile.ps1 -taskList Publish -parameters @{Publish=$true}

Properties:
  SemVer    - Semantic version for the module (e.g., "1.2.3")
  Publish   - Set to $true to enable publishing to PowerShell Gallery
"@ -ForegroundColor Cyan
}
