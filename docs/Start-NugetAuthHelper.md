---
external help file: DevOpsCommands-help.xml
Module Name: DevOpsCommands
online version:
schema: 2.0.0
---

# Start-NugetAuthHelper

## SYNOPSIS
Installs the Microsoft.VisualStudio.Services.NuGet.AuthHelper nuget and runs it.

## SYNTAX

```
Start-NugetAuthHelper [[-NugetConfigPath] <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Installs the Microsoft.VisualStudio.Services.NuGet.AuthHelper nuget in a '.tools'
folder in your profile.
It then runs it against a nuget.config in the directory
you executed the command in.
This will auth you against all the endpoints in
the nuget.config and cache them.
This allows for faster and simpler restore
from the command line.

## EXAMPLES

### EXAMPLE 1
```
Start-NugetAuthHelper
```

## PARAMETERS

### -NugetConfigPath
Location of 'nuget.config' to get external feeds from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: .\NuGet.config
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
