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
    Write-Information "Build completed successfully!"
}

Task Test -Depends Build, RunTests {
    Write-Information "All tests completed!"
}

Task Publish -Depends Build, Test, PublishModule {
    Write-Information "Module published successfully!"
}

Task Clean -Depends CleanPublish, CleanTestResults {
    Write-Information "Clean completed!"
}

Task FullBuild -Depends Clean, Build, Test {
    Write-Information "Full build pipeline completed!"
}

# Individual tasks
Task ValidateManifest {
    Write-Information "Validating module manifest..."
    $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    $script:CurrentVersion = $manifest.Version
    Write-Information "Manifest Version: $script:CurrentVersion"

    Write-Information "✓ Manifest validation passed"
}

Task UpdateVersion -Depends ValidateManifest {
    Write-Information "Updating module version..."

    Write-Information "Current Version: $script:CurrentVersion"
    Write-Information "Specified Version: $SemVer"

    if ($SemVer -eq "0.0.0") {
        Write-Information "No version specified, using current version from manifest."
        $SemVer = $script:CurrentVersion
    }

    Write-Information "New Version: $SemVer"
}

Task UpdateManifest -Depends UpdateVersion {
    Write-Information "Updating module manifest..."

    # Get function list from Public folder
    $functionList = (Get-ChildItem -Path $PublicPath -Filter "*.ps1").BaseName
    Write-Information "Functions to export: $($functionList -join ', ')"

    # Load build configuration
    $buildConfiguration = Get-Content "$PSScriptRoot\module_config.json" | ConvertFrom-Json
    $currentManifest = Import-PowerShellDataFile $ManifestPath

    if ($SemVer -eq "0.0.0") {
        Write-Information "No version specified, using current version from manifest."
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

    Write-Information "✓ Module manifest updated"
}

Task GenerateMarkdownHelp -Depends UpdateManifest {
    Write-Information "Generating markdown help documentation..."

    Write-Information "Using module: $ModuleName"
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

    Write-Information "✓ Markdown help generated"
}

Task GenerateExternalHelp -Depends GenerateMarkdownHelp {
    Write-Information "Generating external XML help..."

    # Generate XML help from markdown
    New-ExternalHelp -Path $DocsPath -OutputPath $EnUSPath -Force

    Write-Information "✓ External XML help generated"
}

Task GenerateDocumentation -Depends GenerateExternalHelp {
    Write-Information "✓ All documentation generated successfully"
}

Task CleanPublish {
    Write-Information "Cleaning publish directory..."

    if (Test-Path $PublishPath) {
        Get-ChildItem $PublishPath -Recurse | Remove-Item -Force -Recurse
        Write-Information "✓ Publish directory cleaned"
    } else {
        Write-Information "✓ Publish directory already clean"
    }
}

Task CleanTestResults {
    Write-Information "Cleaning test results..."

    # Clean up test result files
    Get-ChildItem "$PSScriptRoot\PesterResults_PS*.xml" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem "$PSScriptRoot\TestResults_PS*.xml" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem "$PSScriptRoot\Tests\test-config.*" -ErrorAction SilentlyContinue | Remove-Item -Force

    if (Test-Path $TestResultsPath) {
        Remove-Item $TestResultsPath -Recurse -Force
    }

    Write-Information "✓ Test results cleaned"
}

Task CreatePublishStructure -Depends CleanPublish {
    Write-Information "Creating publish directory structure..."

    $modulePublishPath = "$PublishPath\$ModuleName"
    New-Item -Path $modulePublishPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Information "✓ Publish structure created"
}

Task CopyModuleFiles -Depends CreatePublishStructure, GenerateDocumentation {
    Write-Information "Copying module files for publishing..."

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
            Write-Information "  ✓ Copied $($item.Name)"
        } else {
            Write-Warning "Source not found: $($item.Source)"
        }
    }

    Write-Information "✓ Module files copied to publish directory"
}

Task PackageModule -Depends CopyModuleFiles {
    Write-Information "✓ Module packaged for publishing"
}

Task RunTests -Depends ValidateTestEnvironment {
    Write-Information "Running Pester tests..."

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    Write-Information "Testing with PowerShell $PSVersion"

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
    Write-Information "Test result files: $($AllFiles -join ', ')"

    # Check for failures
    $TestResults = @(Get-ChildItem -Path "$PSScriptRoot\PesterResults_PS*.xml" | Import-Clixml)
    $FailedCount = $TestResults | Select-Object -ExpandProperty FailedCount | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    Write-Information "Failed Count: $FailedCount"

    if ($FailedCount -gt 0) {
        $FailedItems = $TestResults | Select-Object -ExpandProperty Tests | Where-Object { $_.Passed -notlike $True }

        Write-Information "FAILED TESTS SUMMARY:"
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

    Write-Information "✓ All tests passed!"
}

Task ValidateTestEnvironment {
    Write-Information "Validating test environment..."

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
        Write-Information "Found $($testFiles.Count) test file(s)"
    }

    Write-Information "✓ Test environment validated"
}

Task PublishModule -Depends PackageModule {
    Write-Information "Publishing module to PowerShell Gallery..."

    if (-not $Publish) {
        Write-Information "Publish flag not set. Skipping publication."
        return
    }

    # Check if Get-SimpleSetting is available (used for API key)
    if (-not (Get-Command -Name 'Get-SimpleSetting' -ErrorAction SilentlyContinue)) {
        throw "Get-SimpleSetting command not found. This is required to retrieve the PowerShell Gallery API key."
    }

    try {
        $publishKey = Get-SimpleSetting -Section 'PowerShellGallery' -Name 'DefaultApiKey'
        if (-not $publishKey) {
            Write-Information "PowerShell Gallery API key not found in settings."
            Write-Information "Please set the API key using: Set-SimpleSetting -Section 'PowerShellGallery' -Name 'DefaultApiKey' -Value '<YourApiKey>'"
            throw "PowerShell Gallery API key not found in settings."
        }

        $modulePublishPath = "$PublishPath\$ModuleName"
        Publish-Module -Path $modulePublishPath -NuGetApiKey $publishKey

        Write-Information "Waiting for module to be published..."
        # Wait for a few seconds to ensure the module is published
        Start-Sleep -Seconds 2

        $publishedModuleDetails = Find-Module -Name DevOpsCommands
        $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
        if ($publishedModuleDetails.Version -ne $manifest.Version) {
            Write-Error "Issue with module version mismatch after publishing. Expected: $($manifest.Version), Found: $($publishedModuleDetails.Version)"
            throw "Module version mismatch after publishing"
        } else {
            Write-Information "Module version matches after publishing: $($publishedModuleDetails.Version)"
        }

        Write-Information "✓ Module published to PowerShell Gallery successfully!"
    } catch {
        Write-Error "Failed to publish module: $($_.Exception.Message)"
        throw
    }
}

Task ShowHelp {
    Write-Information @"
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
  Invoke-PSake psakefile.ps1 -taskList Publish -parameters @{Publish=`$true}

Properties:
  SemVer    - Semantic version for the module (e.g., "1.2.3")
  Publish   - Set to `$true to enable publishing to PowerShell Gallery
"@
}
