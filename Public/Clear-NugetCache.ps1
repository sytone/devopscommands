function Clear-NugetCache {
    <#
  .SYNOPSIS
      Clears all NuGet cache files from the machine.
  .DESCRIPTION
      Runs 'dotnet nuget locals all --clear' to clear all files from the NuGet caches
      on the machine. This includes the global packages cache, HTTP cache, and temp
      cache folders.
  .PARAMETER WhatIf
      Shows what would happen if the command runs without actually clearing the cache.
  .PARAMETER Confirm
      Prompts for confirmation before clearing the cache.
  .EXAMPLE
      Clear-NugetCache

      Clears all NuGet cache files from the machine.
  .EXAMPLE
      Clear-NugetCache -WhatIf

      Shows what cache files would be cleared without actually clearing them.
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ()

    begin {
        wi (Get-ModuleHeaderInfo)
    }

    process {
        if (Get-Command dotnet -ErrorAction SilentlyContinue) {
            wv '.NET CLI found in path.'

            if ($PSCmdlet.ShouldProcess('NuGet Cache', 'Clear all cache files')) {
                wi 'Clearing all NuGet cache files...'
                & dotnet nuget locals all --clear
                wi 'NuGet cache cleared successfully.'
            } else {
                wi "Would run: 'dotnet nuget locals all --clear'"
            }
        } else {
            throw '.NET CLI (dotnet) not found in path. Please install the .NET SDK.'
        }
    }

    end {
    }
}
