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

    .EXAMPLE
      Start-MSBuild
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Switch] $LogToConsole,
        [Switch] $Clean,
        [Switch] $Restore,
        [Switch] $CleanNugetCache,
        [Switch] $Release,
        $AdditionalArguments = @()
    )

    begin {
        Write-Information (Get-ModuleHeaderInfo)
        Write-Information "Executing MSBuild with following settings"
        Write-Information "     Visual Studio Version: $vsDefault"
        Write-Information "   Default Build Arguments: $msBuildArguments"
        Write-Information "Structured Log Viewer Path: $StructuredLogViewerPath"
        if ($LogToConsole) { Write-Information "- Logging to Console Enabled" }
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
            $msBuildArgumentsUsed += '/consoleLoggerParameters:PerformanceSummary;Summary;Verbosity=minimal'
        }
        else {
            $msBuildArgumentsUsed += '/noconsolelogger'
            $msBuildArgumentsUsed += '/binaryLogger'
        }

        if ($Release) {
            $msBuildArgumentsUsed += '/p:Configuration="Release"'
        }
        else {
            $msBuildArgumentsUsed += '/p:Configuration="Debug"'
        }

        $msBuildArgumentsUsed += $AdditionalArguments
        if ($null -eq (Get-Command "msbuild.exe" -ErrorAction SilentlyContinue)) {
            switch ($vsDefault) {
                "16" { Use-VS2019 }
                "15" { Use-VS2017 }
                Default { Use-VS2019 }
            }
        }

        if ($null -eq (Get-Command "msbuild.exe" -ErrorAction SilentlyContinue)) {
            Write-Information "Unable to find msbuild.exe in your PATH, loading VS $vsDefault"
        }
        else {
            if ($CleanNugetCache) {
                if ($PSCmdlet.ShouldProcess("Start-Process", "dotnet nuget locals all --clear")) {
                    Start-Process -FilePath dotnet  -ArgumentList ('nuget', 'locals', 'all', '--clear') -NoNewWindow -Wait
                }
            }
            if ($Restore) {
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Restore`"")) {
                    Start-Process -FilePath msbuild -ArgumentList ($msBuildArgumentsUsed + '/t:"Restore"') -NoNewWindow -Wait
                }
            }
            if ($Clean) {
                if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed /t:`"Clean`"")) {
                    Start-Process -FilePath msbuild -ArgumentList ($msBuildArgumentsUsed + '/t:"Clean"') -NoNewWindow -Wait
                }
            }
            if ($PSCmdlet.ShouldProcess("Start-Process", "msbuild $msBuildArgumentsUsed'")) {
                Start-Process -FilePath msbuild -ArgumentList $msBuildArgumentsUsed -NoNewWindow -Wait
            }
        }
        $sw.Stop()
        Write-Information "Build took $($sw.Elapsed.TotalMinutes) minutes"
        if ((Get-Command $StructuredLogViewerPath) -and -not $LogToConsole) {
            if (-not (Get-Process StructuredLogViewer -ErrorAction SilentlyContinue)) {
                $StructuredLogViewerPath = (Get-Command StructuredLogViewer.exe).Source
                if ($PSCmdlet.ShouldProcess("&", "$StructuredLogViewerPath $PWD\msbuild.binlog")) {
                    & $StructuredLogViewerPath $PWD\msbuild.binlog
                }
            }
        }

    }

    end {
    }
}

