# Set of Hashicorp's `Packer` templates to create Microsoft Hyper-V virtual machines

![UbuntuLinux](https://img.shields.io/badge/Linux-Ubuntu-orange)

![Windows2022](https://img.shields.io/badge/Windows-2022-blue)

<!-- TOC -->

- [Set of Hashicorp's Packer templates to create Microsoft Hyper-V virtual machines](#set-of-hashicorps-packer-templates-to-create-microsoft-hyper-v-virtual-machines)
  - [Requirements](#requirements)
  - [Requirements - Quick Start](#requirements---quick-start)
    - [Install packer from Chocolatey](#install-packer-from-chocolatey)
    - [Install required plugins](#install-required-plugins)
    - [Use account with Administrator privileges for Hyper-V](#use-account-with-administrator-privileges-for-hyper-v)
    - [Add firewal exclusions for TCP ports 8000-9000 default range](#add-firewal-exclusions-for-tcp-ports-8000-9000-default-range)
    - [Adjust Hyper-V settings](#adjust-hyper-v-settings)
    - [Default passwords](#default-passwords)
    - [Enable Packer debug logging](#enable-packer-debug-logging)
  - [Scripts](#scripts)
    - [Windows Machines](#windows-machines)
    - [Linux Machines](#linux-machines)
  - [Templates Windows 2022](#templates-windows-2022)
    - [Hyper-V Generation 2 Windows Server 2022 Standard Image](#hyper-v-generation-2-windows-server-2022-standard-image)
      - [Windows 2022 Standard Generation 2 Prerequisites](#windows-2022-standard-generation-2-prerequisites)
    - [Hyper-V Generation 2 Windows Server 2022 Datacenter Image](#hyper-v-generation-2-windows-server-2022-datacenter-image)
      - [Windows 2022 Datacenter Generation 2 Prerequisites](#windows-2022-datacenter-generation-2-prerequisites)
    - [[Experimental] Hyper-V generation 2 Windows Server 2022 Standard Vagrant support](#experimental-hyper-v-generation-2-windows-server-2022-standard-vagrant-support)
    - [[Experimental] Hyper-V generation 2 Windows Server 2022 Datacenter Vagrant support](#experimental-hyper-v-generation-2-windows-server-2022-datacenter-vagrant-support)
  - [Templates Ubuntu](#templates-ubuntu)
    - [Warnings - Ubuntu 20.x](#warnings---ubuntu-20x)
    - [Hyper-V Generation 2 Ubuntu 22.04 Image](#hyper-v-generation-2-ubuntu-2204-image)
  - [Ansible Provisioning](#ansible-provisioning)
  - [Known issues](#known-issues)
    - [I have general problem not covered here](#i-have-general-problem-not-covered-here)
    - [Infamous UEFI/Secure boot WIndows implementation](#infamous-uefisecure-boot-windows-implementation)
    - [~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~](#when-hyper-v-host-has-more-than-one-interface-packer-sets--httpip--variable-to-inproper-interface)
    - [~~Packer version 1.3.0/1.3.1 have bug with windows-restart provisioner~~](#packer-version-130131-have-bug-with-windows-restart-provisioner)
    - [Packer won't run until VirtualSwitch is created as shared](#packer-wont-run-until-virtualswitch-is-created-as-shared)
    - [I have problem how to find a proper WIM  name in Windows ISO to pick proper version](#i-have-problem-how-to-find-a-proper-wim--name-in-windows-iso-to-pick-proper-version)
    - [On Windows machines, build break during updates phase, when update cycles are interfering with each other](#on-windows-machines-build-break-during-updates-phase-when-update-cycles-are-interfering-with-each-other)
    - [Why don't you use ansible instead of shell scripts for provisioning](#why-dont-you-use-ansible-instead-of-shell-scripts-for-provisioning)
  - [About](#about)

<!-- /TOC -->
## Requirements

- packer <=`1.8.4`. Do not use packer below 1.7.0 version. For previous packer versions use previous releases from this repository
- Microsoft Hyper-V Server 2019 or Microsoft Windows Server 2019/2022 with Hyper-V role installed as host to build your images
- firewall exceptions for `packer` http server (look down below)
- properly constructed virtual switch in Hyper-v allowing virtual machine to get IP from DHCP and contact Hyper-V server on mentioned packer ports. This is a must, if kickstart is reachable over the network.

## Requirements - Quick Start

### Install packer from Chocolatey

```cmd
choco install packer --version=1.8.4 -y
```

### Install required plugins

In root folder of a repository

```cmd
packer init --upgrade config.pkr.hcl
```

### Use account with Administrator privileges for Hyper-V

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000
```

### Adjust Hyper-V settings

To adjust to your Hyper-V, please check variables below and/or in ./variables files

- (variable `vlan_id` in /variables/variables.*.pkvars.hcl) - proper VLAN ID . Look up to find your build server vEthernet setings.
- (variable `switch_name` in /variables/variables.*.pkvars.hcl) - proper Hyper-V Virtual Switch name (access to Internet will be required). Make sure you're using pre-existing switch in your Hyper-V server - creation of new switch by packer, instead of reusing existing one can cause lack of Internet access, thus failing the build.

```yaml
# example of mentioned variables
vlan_id = ""
switch_name = "vSwitch"
```

### Enable Packer debug logging

Soon to be parametrized

In building script set `packet_log`  variable to 1

```powershell
$packer_log=1
```

## Scripts

### Windows Machines

- all available updates will be applied (3 passes)
- latest version of chocolatey
- packages from a list below:

  |Package|Version|
  |-------|-------|
  |conemu|latest|
  |dotnetfx|latest|
  |sysinternals|latest|

- `phase4b-docker.ps1` - Docker settings can be customised
  - `requiredVersion` - which version of docker module to install - defaults to 19.03.1
  - `installCompose` ($true/$false) - install docker-compose from chocolatey packages
  - `dockerLocation` - of set, will default docker images and settings there. On empty, docker location is not being set.
  - `configDockerLocation` - default place for docker's config file

  Example of usage

  `.\phase5b-docker.ps1 -requiredVersion "19.03.1" -installCompose $true -dockerLocation "d:\docker" -configDockerLocation "C:\ProgramData\Docker\config"`

### Linux Machines

- Repositories:

  |Repository|Package|switch|
  |----------|------------|---|
  |Epel 7/8/9|epel-release|can be switched off by setting "install_epel" to `false`|
  |Zabbix 6.0|zabbix-agent|can be switched on by setting "install_zabbix" to `true`|
  |Hyper-V |SCVMM Agent|can be switched off by setting "install_hyperv" to `false`|
  |Neofetch  |neofetch|can be switched off by setting "install_neofetch" to `false`|
  ||||

- [Optional] Linux machine with separated disk for docker
- [Optional] Linux machine for vagrant

## Templates Windows 2022

### Hyper-V Generation 2 Windows Server 2022 Standard Image

Run `hv_win2022_std.ps1` (Windows)

#### Windows 2022 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

- ./extra/files/gen2-2022/std/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2022 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

### Hyper-V Generation 2 Windows Server 2022 Datacenter Image

Run `hv_win2022_dc.ps1` (Windows)

#### Windows 2022 Datacenter Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

- ./extra/files/gen2-2022/dc/autounattend.xml      => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1
- ./extra/scripts/hyper-v/winrm-config.ps1         => /winrm-config.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image. You can use the `unattend-iso-build.ps1` script in the root of the repo to rebuild the ISO incase of any additions/modifications.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2022 SERVERDATACENTER</Value>
    </MetaData>
</InstallFrom>
```

## Templates Ubuntu

### Warnings - Ubuntu 20.x

- if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
- if needed - change `iso_url` variable to a proper iso name
- packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
- credentials for Windows machines: Administrator/password (removed after sysprep)
- credentials for Linux machines: root/password
- for Windows based machines adjust your settings in ./scripts/phase-2.ps1
- for Linux based machines adjust your settings in ./files/gen2-{{os}}/provision.sh and ./files/gen2-{{os}}/puppet.conf

### Hyper-V Generation 2 Ubuntu 20.04 Image

Run `hv_ubuntu2004.ps1`

### Hyper-V Generation 2 Ubuntu 22.04 Image

Run `hv_ubuntu2204.ps1`

## Ansible Proviosning

I use CI with Azure DevOps for building images via Packer. In order to facilitate this I use Ansible to run the packer builds on Hyper-V. 

The `packer_build.yml` file in the root of the repo is the Ansible playbook that can be used. The plays are located in `./roles/packer_build/tasks/main.yml`

The play will need to be modified slightly as it is catered for my own environment where its cloning private git repos and such

## Known issues

### ~~On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react~~

[https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880](https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880)

Fixed in version 1.4.4.  Do not use previous versions

### ~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~

Fixed in version 1.4.4. Do not use lower versions
~~No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.**~~

### ~~Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner~~

[https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)

### Packer won't run until VirtualSwitch is created as shared

[https://github.com/hashicorp/packer/issues/5023](https://github.com/hashicorp/packer/issues/5023)
Will be fixed in 1.4.x revision

### I have problem how to find a proper WIM  name in Windows ISO to pick proper version

You can use number. If you have 4 images on the list of choice - use `ImageIndex` with proper `Value`

```xml
<ImageInstall>
    <OSImage>
        <InstallFrom>
            <MetaData wcm:action="add">
                <Key>/IMAGE/INDEX </Key>
                <Value>2</Value>
            </MetaData>
        </InstallFrom>
        <InstallTo>
            <DiskID>0</DiskID>
            <PartitionID>2</PartitionID>
        </InstallTo>
    </OSImage>
</ImageInstall>
```

### On Windows machines, build break during updates phase, when update cycles are interfering with each other

Increase variable  `update_timeout` in `./variables/*.json` file - this will create longer pauses between stages, allowing cycles to complete before jumping to another one.


