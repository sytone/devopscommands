$Script:StructuredLogViewerPath = "$env:USERPROFILE\scoop\shims\structuredlogviewer.exe"
$Script:msBuildArguments = @('/nologo', '/m', '/nr:false', '/p:TreatWarningsAsErrors="true"', '/p:Platform="x64"')
$Script:vsDefault = "17"


if ($null -ne (Get-Module -Name SimpleSettings)) {
    $Script:StructuredLogViewerPath = Get-SimpleSetting -Name "StructuredLogViewerPath" -Section "DevOpsCommands" -DefaultValue $Script:StructuredLogViewerPath
    $Script:msBuildArguments = Get-SimpleSetting -Name "MsBuildArguments" -Section "DevOpsCommands" -DefaultValue $Script:msBuildArguments
    $Script:vsDefault = Get-SimpleSetting -Name "VsDefault" -Section "DevOpsCommands" -DefaultValue $Script:vsDefault
}