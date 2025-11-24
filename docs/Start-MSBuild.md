---
external help file: DevOpsCommands-help.xml
Module Name: DevOpsCommands
online version:
schema: 2.0.0
---

# Start-MSBuild

## SYNOPSIS
Runs MSBuild with binary logging enabled by default

## SYNTAX

```
Start-MSBuild [[-AdditionalArguments] <Object>] [-LogToConsole] [-Clean] [-Restore] [-CleanNugetCache]
 [-Release] [-Nuke] [-GitNuke] [-ShowBuildSummary] [-SkipToolsRestore] [-LogVerbosity <String>]
 [-NukeFolders <Object>] [-MessageCallback <ScriptBlock>] [-ErrorCallback <ScriptBlock>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Wraps the call to MSBuild using common settings to make command line building repeatable.
By default, uses binary logging for better performance and structured log output that can be viewed with the MSBuild Structured Log Viewer.

## EXAMPLES

### EXAMPLE 1
```
Start-MSBuild
```

Runs a basic debug build with binary logging enabled.

### EXAMPLE 2
```
Start-MSBuild -Release -Clean
```

Runs a clean release build.

### EXAMPLE 3
```
Start-MSBuild -LogToConsole -LogVerbosity detailed
```

Runs a build with detailed console output instead of binary logging.

### EXAMPLE 4
```
Start-MSBuild -Restore -Clean -Release
```

Performs a complete build: restore packages, clean artifacts, then build in release mode.

### EXAMPLE 5
```
Start-MSBuild -Nuke -AdditionalArguments @("/p:PublishProfile=FolderProfile", "/p:PublishUrl=bin\Release\Publish")
```

Deletes build folders and runs build with additional MSBuild arguments.

### EXAMPLE 6
```
Start-MSBuild -CleanNugetCache -Restore
```

Clears the NuGet cache and restores packages before building.

### EXAMPLE 7
```
Start-MSBuild -LogToConsole -ShowBuildSummary -LogVerbosity normal
```

Runs build with console logging, showing build performance summary with normal verbosity.

## PARAMETERS

### -AdditionalArguments
Allows you to add additional arguments to the MSBuild command.
Can be a string or array of strings.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogToConsole
Enables console logging, which will slow down the build process but give you immediate visual feedback.
Handy for debugging build issues.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Clean
Runs the build with the Clean target before the main build to remove all build artifacts.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Restore
Runs the build with the Restore target before the main build to restore NuGet packages.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CleanNugetCache
Calls 'dotnet nuget locals all --clear' to remove all cached packages.
You will need to restore after this.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Release
Sets the build configuration to Release instead of Debug.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Nuke
Deletes all folders with names specified in NukeFolders parameter (default: bin, obj, node_modules, out, TestResults).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitNuke
Performs a complete git reset: deletes all extra files, resets the git repo to the last commit, and pulls the latest changes.
WARNING: This will permanently delete uncommitted changes.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowBuildSummary
Shows the build performance summary in the console output when LogToConsole is enabled.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipToolsRestore
By default, 'dotnet tool restore' is run before the build.
This switch skips that step.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogVerbosity
Sets the verbosity level for MSBuild logging.
Valid values: quiet, minimal, normal, detailed, diagnostic.
Default is 'minimal'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Minimal
Accept pipeline input: False
Accept wildcard characters: False
```

### -NukeFolders
Specifies which folder names to delete when using the Nuke parameter.
Default folders: bin, obj, node_modules, out, TestResults.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @("bin", "obj", "node_modules", "out", "TestResults")
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageCallback
A ScriptBlock that handles informational messages during the build process.
Default writes to Write-Information.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: { param($message) Write-Information "$message" }
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorCallback
A ScriptBlock that handles error messages during the build process.
Default writes to Write-Error.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: { param($exception) Write-Error $exception }
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
