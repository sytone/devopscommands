function Start-MSBuildRelease {
    <#
    .SYNOPSIS
      Runs MBuild with binary logging enabled by default and with Release configuration

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

    .PARAMETER AdditionalArguments
      Allows you to add additional arguments to the msbuild command.

    .EXAMPLE
      Start-MSBuildRelease
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Switch] $LogToConsole,
        [Switch] $Clean,
        [Switch] $Restore,
        [Switch] $CleanNugetCache,
        $AdditionalArguments = @()
    )
    begin {
    }

    process {

        $splat = @{
            LogToConsole        = $LogToConsole
            Clean               = $Clean
            AdditionalArguments = $AdditionalArguments
            Release             = $true
            Restore             = $Restore
            CleanNugetCache     = $CleanNugetCache
        }
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            Start-MSBuild @splat
        } else {
            wi "Ran 'Start-MSBuild $($splat)'"
        }
    }

    end {
    }
}

