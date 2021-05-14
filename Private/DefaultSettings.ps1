$Script:StructuredLogViewerPath = "$env:USERPROFILE\AppData\Local\MSBuildStructuredLogViewer\app-2.1.88\StructuredLogViewer.exe"
$Script:msBuildArguments = @('/nologo', '/m', '/nr:false', '/p:TreatWarningsAsErrors="true"', '/p:Platform="x64"')
$Script:vsDefault = "16"


if ($null -ne (Get-Module -Name SimpleSettings)) {
    $Script:StructuredLogViewerPath = Get-SimpleSetting -Name "StructuredLogViewerPath" -Section "DevOpsCommands" -DefaultValue $Script:StructuredLogViewerPath
    $Script:msBuildArguments = Get-SimpleSetting -Name "MsBuildArguments" -Section "DevOpsCommands" -DefaultValue $Script:msBuildArguments
    $Script:vsDefault = Get-SimpleSetting -Name "VsDefault" -Section "DevOpsCommands" -DefaultValue $Script:vsDefault
}