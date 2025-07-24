function Install-MSBuildStructuredLogViewer {
    <#
  .SYNOPSIS
      Installs the latest MSBuild Structured Log Viewer from https://github.com/KirillOsenkov/MSBuildStructuredLog
  .DESCRIPTION
      Installs the latest MSBuild Structured Log Viewer from https://github.com/KirillOsenkov/MSBuildStructuredLog. Make sure the install location is in your path to use it.
  .EXAMPLE
      Install-MSBuildStructuredLogViewer
  #>
    begin {
        Write-HeadingBlock (Get-ModuleHeaderInfo)
    }

    process {
        $latestVersion = (Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/KirillOsenkov/MSBuildStructuredLog/releases/latest).Content | ConvertFrom-Json
        $downloadUrl = ($latestVersion.assets | Where-Object { $_.name -eq "MSBuildStructuredLogSetup.exe" }).browser_download_url
        $downloadName = ($latestVersion.assets | Where-Object { $_.name -eq "MSBuildStructuredLogSetup.exe" }).name
        $versionTag = $latestVersion.tag_name
        Write-Information "Update `$Global:StructuredLogViewerPath to point to $versionTag"
        Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile "./$downloadName"
        Start-Process -FilePath "./$downloadName" -Wait
        Remove-Item "./$downloadName" -ErrorAction SilentlyContinue | Out-Null
    }

    end {
    }
}


