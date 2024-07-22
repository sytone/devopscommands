function Start-MSBuild {
    <#
    .SYNOPSIS
      Runs MBuild with binary logging enabled by default

    .DESCRIPTION
      Wraps the call to msbuild using common settings to make command lind building repeatable.

    .PARAMETER LogToConsole
      Enabled Console logging, this will slow down the build process but give you immediate visual feedback. Handy for debugging.

    .PARAMETER Clean
      Runs the build with the Clean step as the target before the main build.

    .PARAMETER Restore
      Runs the build with the Restore step as the target before the main build.

    .PARAMETER CleanNugetCache
      Call the nuget command to remove all cached packages, you will need to restore after this.

    .PARAMETER Release
      Make the build configuration Release and not Debug

    .PARAMETER AdditionalArguments
      Allows you to add additional arguments to the msbuild command.

    .PARAMETER Nuke
      Deletes all folders called bin, obj, node_modules, out

    .PARAMETER GitNuke
      Deletes all extra files, resets the git repo to the last commit and pulls the latest changes.

    .PARAMETER ShowBuildSummary
      Shows the build summary in the console output.

    .PARAMETER SkipToolsRestore
      By default a 'dotnet tool restore' is run before the build, this will skip that step.

    .EXAMPLE
      Start-MSBuild
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
        $NukeFolders = @("bin", "obj", "node_modules", "out", "TestResults")
    )

    begin {
        wh (Get-ModuleHeaderInfo)
        wi "Executing MSBuild with following settings"
        wi "     Visual Studio Version: $vsDefault"
        wi "   Default Build Arguments: $msBuildArguments"
        wi "Structured Log Viewer Path: $StructuredLogViewerPath"
        if ($LogToConsole) { wi "- Logging to Console Enabled" }
        if ($Nuke) { wi "- Removing all folders called ($($NukeFolders -join ","))" }
        if ($Clean) { wi "- Clean Enabled" }
        if ($Restore) { wi "- Restore Enabled" }
        if ($CleanNugetCache) { wi "- Clean Nuget Cache Enabled" }
        if ($Release) { wi "- Release Configuration Enabled" }
        wi "Additional Arguments: $($AdditionalArguments)"
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
            $msBuildArgumentsUsed += '/noconsolelogger'
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
            wi "Unable to find msbuild.exe in your PATH, loading VS $vsDefault"
            switch ($vsDefault) {
                "17" { Use-VS2022 }
                "16" { Use-VS2019 }
                "15" { Use-VS2017 }
                Default { Use-VS2019 }
            }
        }

        if ($null -eq (Get-Command "msbuild.exe" -ErrorAction SilentlyContinue)) {
            wi "Unable to find msbuild.exe in your PATH, unable to build."
        } else {
            if ($CleanNugetCache) {
                wi "Cleaning the NUGET Cache"
                if ($PSCmdlet.ShouldProcess("Start-Process", "dotnet nuget locals all --clear")) {
                    Start-Process -FilePath dotnet -ArgumentList ('nuget', 'locals', 'all', '--clear') -NoNewWindow -Wait
                }
            }

            if ($Nuke) {
                wi "Deleteing folders $($NukeFolders -join ",") "
                if ($PSCmdlet.ShouldProcess("Start-Process", "Get-ChildItem ./ -include $($NukeFolders -join ",") -Recurse | ForEach-Object { [IO.Directory]::Delete(`$_.FullName, `$true) }")) {
                    Get-ChildItem ./ -Include $NukeFolders -Recurse | ForEach-Object { [IO.Directory]::Delete($_.FullName, $true) }
                }
            }

            if ($GitNuke) {
                git clean -fdx
                git reset HEAD~1 --hard
                git pull
            }

            if (-not $SkipToolsRestore) {
                wi "Running dotnet tool restore"
                $toolRestoreOutcome = dotnet tool restore
                $toolRestoreOutcome | ForEach-Object { wi $_ }
            }

            if ($Restore) {
                wi "Running restore target"
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Restore`"")) {
                    Start-Process -FilePath msbuild -ArgumentList ($msBuildArgumentsUsed.Replace("/binaryLogger", "/binaryLogger:restore.binlog") + '/t:"Restore"') -NoNewWindow -Wait
                }
            }

            if ($Clean) {
                wi "Running clean target"
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Clean`"")) {
                    Start-Process -FilePath msbuild -ArgumentList ($msBuildArgumentsUsed.Replace("/binaryLogger", "/binaryLogger:clean.binlog") + '/t:"Clean"') -NoNewWindow -Wait
                }
            }

            wi "Running build target"
            if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed'")) {
                $buildProcess = Start-Process -FilePath msbuild -ArgumentList $msBuildArgumentsUsed -NoNewWindow -PassThru
                Wait-Process -InputObject $buildProcess
                if ($buildProcess.ExitCode -gt 0) { Write-Error "MSBuild returned error code $($buildProcess.ExitCode)" }
            }
        }
        $sw.Stop()
        wi "Build took $($sw.Elapsed.TotalMinutes) minutes"
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

