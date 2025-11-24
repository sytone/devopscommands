<div align="center">

![Logo.](./images/msbuild.png "Logo")

# DevOps Commands

![Downloads][powershell-gallery-downloads-shield][![Contributors][contributors-shield]][contributors-url][![Forks][forks-shield]][forks-url][![Stargazers][stars-shield]][stars-url][![Issues][issues-shield]][issues-url][![MIT License][license-shield]][license-url]

A PowerShell module to help with developing locally using MSBuild.

**[Explore the docs »](https://github.com/sytone/devopscommands)**

[View Demo](https://github.com/sytone/devopscommands) · [Report Bug](https://github.com/sytone/devopscommands/issues) · [Request Feature](https://github.com/sytone/devopscommands/issues)

</div>

<details open="open">
  <summary>Table of Contents</summary>

- [DevOps Commands](#devops-commands)
  - [About The Project](#about-the-project)
    - [Built With](#built-with)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [Usage](#usage)
    - [Global Settings](#global-settings)
      - [Default Settings](#default-settings)
      - [Update Default Settings](#update-default-settings)
    - [Commands](#commands)
  - [Roadmap](#roadmap)
  - [Development](#development)
    - [Prerequisites for Development](#prerequisites-for-development)
    - [Available Build Tasks](#available-build-tasks)
    - [Common Development Workflows](#common-development-workflows)
    - [VS Code Integration](#vs-code-integration)
  - [Contributing](#contributing)
  - [License](#license)
  - [Contact](#contact)
  - [Acknowledgements](#acknowledgements)

</details>

## About The Project

To make development simpler in PowerShell using MSBuild this module wraps the commands and defaults to the binary logger which provides far better log output for looking at builds.

### Built With

- [PowerShell Core](https://docs.microsoft.com/powershell/)
- [Visual Studio Code](https://code.visualstudio.com/)

## Getting Started

To get a local copy up and running follow these simple example steps.

### Prerequisites

- PowerShell Core 7.x+

### Installation

To install this module to use you have three options

- Download the zip and extract to a local modules directory
- Install from the [PowerShell Gallery](https://www.powershellgallery.com/)

```powershell
# To install for the first time.
Install-Module -Name DevOpsCommands -Scope CurrentUser

# To update if already installed
Update-Module -Name DevOpsCommands -Scope CurrentUser
```

## Usage

To run with defaults just use the `msb` alias at the root of your project. This will run MSBuild with binary logging enabled and will produce a x64 Debug build.

### Global Settings

If you want to override the default settings put these variables at the end of your profile with the values you want to use. If you are happy with these defaults do not worry about them.

#### Default Settings

| Setting                 | Value                                                                                          | Description                                   |
| ----------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------- |
| StructuredLogViewerPath | "$env:\AppData\Local\MSBuildStructuredLogViewer\app-2.1.88\StructuredLogViewer.exe" | Viewer for the Binary log produced by MSBuild |
| MsBuildArguments | '/noLogo', '/m', '/nr:false', '/p:TreatWarningsAsErrors="true"', '/p:Platform="x64"' | Arguments passed to MSBuild on every execution |
| VsDefault | 17 | Version of Visual Studio to import the console settings from |

#### Update Default Settings

Settings are controlled by the SimpleSettings commands, this is a dependency of this module. To update the default you can use commands like below with your values.

``` PowerShell
Set-SimpleSetting -Name "StructuredLogViewerPath" -Section "DevOpsCommands" -Value "$env:USERPROFILE\AppData\Local\MSBuildStructuredLogViewer\app-2.0.64\StructuredLogViewer.exe"

Set-SimpleSetting -Name "MsBuildArguments" -Section "DevOpsCommands" -Value @('/noLogo', '/m', '/nr:false', '/p:TreatWarningsAsErrors="true"', '/p:Platform="x64"')

# 15 == VS 2017
# 16 == VS 2019
# 17 == VS 2022
Set-SimpleSetting -Name "VsDefault" -Section "DevOpsCommands" -Value "17"
```

### Commands

To list commands run `Get-Command -Module DevOpsCommands`
To get help on commands run `Get-Command -Module DevOpsCommands | Get-Help`

## Roadmap

See the [open issues](https://github.com/sytone/devopscommands/issues) for a list of proposed features (and known issues).

## Development

This project uses PSake for build automation. The build tasks are defined in `psakefile.ps1` and provide a modular, dependency-driven build pipeline.

### Prerequisites for Development

- PowerShell 5.1 or PowerShell Core 6+
- PSake module: `Install-Module PSake -Scope CurrentUser`
- Pester module (for testing): `Install-Module Pester -Scope CurrentUser`
- PlatyPS module (for documentation): `Install-Module PlatyPS -Scope CurrentUser`
- PlatyPS module (for documentation): `Install-Module SimpleSettings -Scope CurrentUser`

### Available Build Tasks

You can run PSake tasks using: `Invoke-PSake psakefile.ps1 -taskList <TaskName>`

**Primary Tasks:**

- `Default` - Runs the Build task (default when no task specified)
- `Build` - Complete build process (validate → update version → update manifest → generate docs → package)
- `Test` - Run build and all tests
- `Publish` - Full pipeline with publishing to PowerShell Gallery
- `Clean` - Clean all build artifacts
- `FullBuild` - Complete pipeline (clean → build → test)

**Individual Tasks:**

- `ValidateManifest` - Validate the module manifest
- `UpdateVersion` - Update version information
- `UpdateManifest` - Update the module manifest with current functions
- `GenerateDocumentation` - Generate markdown and XML help files
- `RunTests` - Execute Pester tests
- `PackageModule` - Package module for publishing

### Common Development Workflows

```powershell
# Quick build and test
Invoke-PSake psakefile.ps1 -taskList Test

# Clean build from scratch
Invoke-PSake psakefile.ps1 -taskList FullBuild

# Build with specific version
Invoke-PSake psakefile.ps1 -taskList Build -properties @{"SemVer"="1.4.0"}

# Publish to PowerShell Gallery (requires API key setup)
Invoke-PSake psakefile.ps1 -taskList Publish -properties @{"Publish"=$true}

# Show all available tasks
Invoke-PSake psakefile.ps1 -taskList ShowHelp
```

### VS Code Integration

The project includes VS Code tasks that integrate with the PSake build system:

- **Ctrl+Shift+P** → **Tasks: Run Task** → **Build** (or use **Ctrl+Shift+B**)
- **Ctrl+Shift+P** → **Tasks: Run Task** → **Test** (or use **Ctrl+Shift+T**)

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
   Note: Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format for the commit/Pull Request
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the GNU GPLv3 License. See `LICENSE` for more information.

## Contact

Project Link: [https://github.com/sytone/devopscommands](https://github.com/sytone/devopscommands)

## Acknowledgements

- [Img Shields](https://shields.io)
- [Choose an Open Source License](https://choosealicense.com)

[contributors-shield]: https://img.shields.io/github/contributors/sytone/devopscommands.svg?style=for-the-badge
[contributors-url]: https://github.com/sytone/devopscommands/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/sytone/devopscommands.svg?style=for-the-badge
[forks-url]: https://github.com/sytone/devopscommands/network/members
[stars-shield]: https://img.shields.io/github/stars/sytone/devopscommands.svg?style=for-the-badge
[stars-url]: https://github.com/sytone/devopscommands/stargazers
[issues-shield]: https://img.shields.io/github/issues/sytone/devopscommands.svg?style=for-the-badge
[issues-url]: https://github.com/sytone/devopscommands/issues
[license-shield]: https://img.shields.io/github/license/sytone/devopscommands?style=for-the-badge
[license-url]: https://github.com/sytone/devopscommands/blob/main/LICENSE
[powershell-gallery-downloads-shield]: https://img.shields.io/powershellgallery/dt/DevOpsCommands?style=for-the-badge
