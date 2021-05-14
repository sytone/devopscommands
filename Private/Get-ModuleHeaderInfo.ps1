function Get-ModuleHeaderInfo {

    begin {
    }

    process {
        $version = (Get-Module DevOpsCommands).Version
        $semVersion = "$($version.Major).$($version.Minor).$($version.Build)"
        return "DevOps Commands version $semVersion"
    }

    end {
    }
}