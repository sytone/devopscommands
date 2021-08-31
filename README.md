<div align="center">

![Logo.](./images/settings_icon.png "Logo")

# Simple Settings

[![Contributors][contributors-shield]][contributors-url][![Forks][forks-shield]][forks-url][![Stargazers][stars-shield]][stars-url][![Issues][issues-shield]][issues-url][![MIT License][license-shield]][license-url]

Simple setting solution for PowerShell and beyond!

**[Explore the docs »](https://github.com/sytone/devopscommands)**

[View Demo](https://github.com/sytone/devopscommands) · [Report Bug](https://github.com/sytone/devopscommands/issues) · [Request Feature](https://github.com/sytone/devopscommands/issues)

</div>

<details open="open">
  <summary>Table of Contents</summary>

  1. [About The Project](#about-the-project)
     - [Built with](#built-with)
  2. [Getting Started](#getting-started)
     - [Prerequisites](#prerequisites)
     - [Installation](#installation)
  3. [Usage](#usage)
  4. [Roadmap](#roadmap)
  5. [Contributing](#contributing)
  6. [License](#license)
  7. [Contact](#contact)
  8. [Acknowledgements](#acknowledgements)

</details>

## About The Project

[![DevOps Commands Screen Shot.][./images/screenshot.png]](https://github.com/sytone/devopscommands)

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
- Clone, build and install

#### Clone, build and install

1. Clone this repo somewhere.
2. Run the build ps1 in this folder to update.
3. Run install.ps1 in this directory to add the loading of this module to your powershell profile. You have to run it in each instance (PowerShell is different to PowerShell Core)

```PowerShell
Install-Module -Name platyPS -Scope CurrentUser
git clone
cd devopscommands
.\build.ps1
.\install.ps1
# open a new instance of powershell now and this module will
# be loaded as part of the profile load.
```

## Usage

To run with defaults just use the `msb` alias at the root of your project. This will run MSBuild with binary logging enabled and will produce a x64 Debug build.

### Global Settings

If you want to override the default settings put these variables at the end of your profile with the values you want to use. If you are happy with these defaults do not worry about them.

``` PowerShell
$Global:StructuredLogViewerPath = "$env:USERPROFILE\AppData\Local\MSBuildStructuredLogViewer\app-2.0.64\StructuredLogViewer.exe"
$Global:msBuildArguments = @('/nologo', '/m', '/nr:false', '/p:TreatWarningsAsErrors="true"', '/p:Platform="x64"')
$Global:vsDefault = "16" #VS2019 use 15 for VS2017
```

### Commands

To list commands run `Get-Command -Module DevOpsCommands`
To get help on commands run `Get-Command -Module DevOpsCommands | Get-Help`

## Roadmap

See the [open issues](https://github.com/sytone/devopscommands/issues) for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the GNU GPLv3 License. See `LICENSE` for more information.

## Contact

Jon Bullen - [@sytone](https://twitter.com/sytone)

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
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[product-screenshot]: images/screenshot.png
