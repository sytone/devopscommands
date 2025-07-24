---
external help file: DevOpsCommands-help.xml
Module Name: DevOpsCommands
online version:
schema: 2.0.0
---

# Clear-NugetCache

## SYNOPSIS
Clears all NuGet cache files from the machine.

## SYNTAX

```
Clear-NugetCache [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs 'dotnet nuget locals all --clear' to clear all files from the NuGet caches
on the machine.
This includes the global packages cache, HTTP cache, and temp
cache folders.

## EXAMPLES

### EXAMPLE 1
```
Clear-NugetCache
```

Clears all NuGet cache files from the machine.

### EXAMPLE 2
```
Clear-NugetCache -WhatIf
```

Shows what cache files would be cleared without actually clearing them.

## PARAMETERS

### -WhatIf
Shows what would happen if the command runs without actually clearing the cache.

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
Prompts for confirmation before clearing the cache.

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
