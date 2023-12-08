function Start-NugetAuthHelper {
    <#
  .SYNOPSIS
      Installs the Microsoft.VisualStudio.Services.NuGet.AuthHelper nuget and runs it.
  .DESCRIPTION
      Installs the Microsoft.VisualStudio.Services.NuGet.AuthHelper nuget in a '.tools'
      folder in your profile. It then runs it against a nuget.config in the directory
      you ececuted the command in. This will auth you against all the endpoints in
      the nuget.config and cache them. This allows for faster and simpler restore
      from the command line.
  .PARAMETER NugetConfigPath
      Location of 'nuget.config' to get external feeds from.
  .EXAMPLE
      Start-NugetAuthHelper
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [String] $NugetConfigPath = '.\NuGet.config'
    )

    begin {
        wi (Get-ModuleHeaderInfo)
        if (!(Test-Path $NugetConfigPath)) {
            throw "Unable to find $NugetConfigPath"
        }
    }

    process {

        if (Get-Command nuget.exe -ErrorAction SilentlyContinue) {
            wv 'Nuget found in path.'
        } else {
            wi 'Nuget not found in path. Downloading to dotnet tools.'
            if ( -not (Test-Path -Path '~\.dotnet\tools')) {
                New-Item -Path '~\.dotnet\tools' -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
                $env:path += ";$env:USERPROFILE\.dotnet\tools"
            }
            Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile "$env:USERPROFILE\.dotnet\tools\Nuget.exe"
        }

        if (Get-Command nuget.exe) {
            if (!(Test-Path '~\.tools')) { New-Item -Path '~\.tools' -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null }
            wi 'Installing/Updating Microsoft.VisualStudio.Services.NuGet.AuthHelper'
            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                nuget install 'Microsoft.VisualStudio.Services.NuGet.AuthHelper' -source 'https://nuget.org/api/v2/' -OutputDirectory (Resolve-Path ~/.tools).Path -Prerelease -NonInteractive -Verbosity quiet

                & "$((Get-ChildItem '~\.tools\Microsoft.VisualStudio.Services.NuGet.AuthHelper*')[-1].FullName)\tools\VSS.NuGet.AuthHelper.exe" -V Detailed -C $NugetConfigPath
            } else {
                wi "Ran 'nuget install `"Microsoft.VisualStudio.Services.NuGet.AuthHelper`" -source `"https://nuget.org/api/v2/`" -OutputDirectory $(Resolve-Path ~/.tools).Path -Prerelease -NonInteractive -Verbosity quiet'"
                wi "Ran '& `"$((Get-ChildItem '~\.tools\Microsoft.VisualStudio.Services.NuGet.AuthHelper*')[-1].FullName)\tools\VSS.NuGet.AuthHelper.exe`" -C $NugetConfigPath'"
            }
        }
    }

    end {
    }
}

