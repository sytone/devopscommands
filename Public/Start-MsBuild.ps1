function Start-MSBuild {
    <#
    .SYNOPSIS
      Runs MSBuild with binary logging enabled by default

    .DESCRIPTION
      Wraps the call to MSBuild using common settings to make command line building repeatable.
      By default, uses binary logging for better performance and structured log output that can be viewed with the MSBuild Structured Log Viewer.

    .PARAMETER AdditionalArguments
      Allows you to add additional arguments to the MSBuild command. Can be a string or array of strings.

    .PARAMETER LogToConsole
      Enables console logging, which will slow down the build process but give you immediate visual feedback.
      Handy for debugging build issues.

    .PARAMETER Clean
      Runs the build with the Clean target before the main build to remove all build artifacts.

    .PARAMETER Restore
      Runs the build with the Restore target before the main build to restore NuGet packages.

    .PARAMETER CleanNugetCache
      Calls 'dotnet nuget locals all --clear' to remove all cached packages. You will need to restore after this.

    .PARAMETER Release
      Sets the build configuration to Release instead of Debug.

    .PARAMETER Nuke
      Deletes all folders with names specified in NukeFolders parameter (default: bin, obj, node_modules, out, TestResults).

    .PARAMETER GitNuke
      Performs a complete git reset: deletes all extra files, resets the git repo to the last commit, and pulls the latest changes.
      WARNING: This will permanently delete uncommitted changes.

    .PARAMETER ShowBuildSummary
      Shows the build performance summary in the console output when LogToConsole is enabled.

    .PARAMETER SkipToolsRestore
      By default, 'dotnet tool restore' is run before the build. This switch skips that step.

    .PARAMETER LogVerbosity
      Sets the verbosity level for MSBuild logging. Valid values: quiet, minimal, normal, detailed, diagnostic.
      Default is 'minimal'.

    .PARAMETER NukeFolders
      Specifies which folder names to delete when using the Nuke parameter.
      Default folders: bin, obj, node_modules, out, TestResults.

    .PARAMETER MessageCallback
      A ScriptBlock that handles informational messages during the build process.
      Default writes to Write-Information.

    .PARAMETER ErrorCallback
      A ScriptBlock that handles error messages during the build process.
      Default writes to Write-Error.

    .EXAMPLE
      Start-MSBuild

      Runs a basic debug build with binary logging enabled.

    .EXAMPLE
      Start-MSBuild -Release -Clean

      Runs a clean release build.

    .EXAMPLE
      Start-MSBuild -LogToConsole -LogVerbosity detailed

      Runs a build with detailed console output instead of binary logging.

    .EXAMPLE
      Start-MSBuild -Restore -Clean -Release

      Performs a complete build: restore packages, clean artifacts, then build in release mode.

    .EXAMPLE
      Start-MSBuild -Nuke -AdditionalArguments @("/p:PublishProfile=FolderProfile", "/p:PublishUrl=bin\Release\Publish")

      Deletes build folders and runs build with additional MSBuild arguments.

    .EXAMPLE
      Start-MSBuild -CleanNugetCache -Restore

      Clears the NuGet cache and restores packages before building.

    .EXAMPLE
      Start-MSBuild -LogToConsole -ShowBuildSummary -LogVerbosity normal

      Runs build with console logging, showing build performance summary with normal verbosity.
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Position = 0)]
        $AdditionalArguments = @(),
        [Switch] $LogToConsole,
        [Switch] $Clean,
        [Switch] $Restore,
        [Switch] $CleanNugetCache,
        [Switch] $Release,
        [Switch] $Nuke,
        [Switch] $GitNuke,
        [Switch] $ShowBuildSummary,
        [Switch] $SkipToolsRestore,
        [ValidateSet("quiet", "minimal", "normal", "detailed", "diagnostic")]
        [string]$LogVerbosity = "minimal",
        $NukeFolders = @("bin", "obj", "node_modules", "out", "TestResults"),
        [scriptblock]$MessageCallback = { param($message) Write-Information "$message" },
        [scriptblock]$ErrorCallback = { param($exception) Write-Error $exception }
    )

    begin {
        Write-HeadingBlock (Get-ModuleHeaderInfo)
        Write-Information "Executing MSBuild with following settings"
        Write-Information "     Visual Studio Version: $vsDefault"
        Write-Information "   Default Build Arguments: $msBuildArguments"
        Write-Information "Structured Log Viewer Path: $StructuredLogViewerPath"
        if ($LogToConsole) { Write-Information "- Logging to Console Enabled" }
        if ($Nuke) { Write-Information "- Removing all folders called ($($NukeFolders -join ","))" }
        if ($Clean) { Write-Information "- Clean Enabled" }
        if ($Restore) { Write-Information "- Restore Enabled" }
        if ($CleanNugetCache) { Write-Information "- Clean Nuget Cache Enabled" }
        if ($Release) { Write-Information "- Release Configuration Enabled" }
        Write-Information "Additional Arguments: $($AdditionalArguments)"
    }

    process {

        $sw = [Diagnostics.Stopwatch]::StartNew()
        $msBuildArgumentsUsed = $msBuildArguments
        if ($LogToConsole) {
            if ($ShowBuildSummary) {
                $msBuildArgumentsUsed += "/consoleLoggerParameters:PerformanceSummary;Summary;Verbosity=$LogVerbosity"
            } else {
                $msBuildArgumentsUsed += "/consoleLoggerParameters:Verbosity=$LogVerbosity"
            }
        } else {
            $msBuildArgumentsUsed += '/noConsoleLogger'
            $msBuildArgumentsUsed += '/binaryLogger'
        }

        if ($Release) {
            $msBuildArgumentsUsed += '/p:Configuration="Release"'
        } else {
            $msBuildArgumentsUsed += '/p:Configuration="Debug"'
        }

        $msBuildArgumentsUsed += "/verbosity:$LogVerbosity"

        $msBuildArgumentsUsed += $AdditionalArguments
        if ($null -eq (Get-Command "msbuild.exe" -ErrorAction SilentlyContinue)) {
            Write-Information "Unable to find msbuild.exe in your PATH, loading VS $vsDefault"
            switch ($vsDefault) {
                "17" { Use-VS2022 }
                "16" { Use-VS2019 }
                "15" { Use-VS2017 }
                Default { Use-VS2019 }
            }
        }

        if ($null -eq (Get-Command "msbuild.exe" -ErrorAction SilentlyContinue)) {
            Write-Information "Unable to find msbuild.exe in your PATH, unable to build."
        } else {
            if ($CleanNugetCache) {
                Write-Information "Cleaning the NUGET Cache"
                if ($PSCmdlet.ShouldProcess("Start-Process", "dotnet nuget locals all --clear")) {
                    $ExitCode, $Output = Invoke-Call "dotnet" @('nuget', 'locals', 'all', '--clear') $MessageCallback $ErrorCallback
                }
            }

            if ($Nuke) {
                Write-Information "Deleting folders $($NukeFolders -join ",") "
                if ($PSCmdlet.ShouldProcess("Start-Process", "Get-ChildItem ./ -include $($NukeFolders -join ",") -Recurse | ForEach-Object { [IO.Directory]::Delete(`$_.FullName, `$true) }")) {
                    Get-ChildItem ./ -Include $NukeFolders -Recurse | ForEach-Object { [IO.Directory]::Delete($_.FullName, $true) }
                }
            }

            if ($GitNuke) {
                Write-Information "Resetting git repository to last commit and pulling latest changes"
                if ($PSCmdlet.ShouldProcess("Start-Process", "git clean -fdx")) {
                    $ExitCode, $Output = Invoke-Call "git" @('clean', '-fdx') $MessageCallback $ErrorCallback
                }
                if ($PSCmdlet.ShouldProcess("Start-Process", "git reset HEAD~1 --hard")) {
                    $ExitCode, $Output = Invoke-Call "git" @('reset', 'HEAD~1', '--hard') $MessageCallback $ErrorCallback
                }
                if ($PSCmdlet.ShouldProcess("Start-Process", "git pull")) {
                    $ExitCode, $Output = Invoke-Call "git" @('pull') $MessageCallback $ErrorCallback
                }
            }

            if (-not $SkipToolsRestore) {
                Write-Information "Running dotnet tool restore"
                if ($PSCmdlet.ShouldProcess("Start-Process", "dotnet tool restore")) {
                    $ExitCode, $Output = Invoke-Call "dotnet" @('tool', 'restore') $MessageCallback $ErrorCallback
                }
            }

            if ($Restore) {
                Write-Information "Running restore target"
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Restore`"")) {
                    $ExitCode, $Output = Invoke-Call "msbuild" @($msBuildArgumentsUsed.Replace("/binaryLogger", "/binaryLogger:restore.binlog"), '/t:"Restore"') $MessageCallback $ErrorCallback
                }
            }

            if ($Clean) {
                Write-Information "Running clean target"
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Clean`"")) {
                    $ExitCode, $Output = Invoke-Call "msbuild" @($msBuildArgumentsUsed.Replace("/binaryLogger", "/binaryLogger:clean.binlog"), '/t:"Clean"') $MessageCallback $ErrorCallback
                }
            }

            Write-Information "Running build target"
            if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed")) {
                $ExitCode, $Output = Invoke-Call "msbuild" $msBuildArgumentsUsed $MessageCallback $ErrorCallback
                if ($ExitCode -gt 0) { Write-Error "MSBuild returned error code $($ExitCode)" }
            }
        }
        $sw.Stop()
        Write-Information "Build took $($sw.Elapsed.TotalMinutes) minutes"
        if ((Get-Command $StructuredLogViewerPath) -and -not $LogToConsole) {
            if (-not (Get-Process StructuredLogViewer -ErrorAction SilentlyContinue)) {
                $StructuredLogViewerPath = (Get-Command StructuredLogViewer.exe).Source
                if ($PSCmdlet.ShouldProcess("&", "$StructuredLogViewerPath $PWD\msbuild.binlog")) {
                    Start-Process -FilePath $StructuredLogViewerPath -ArgumentList "$PWD\msbuild.binlog" -NoNewWindow
                }
            }
        }

    }

    end {
    }
}

