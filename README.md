## Packer template for Mint Cinnamon 17.3

Not finding an existing ''working' Packer template for Mint Cinnamon, this is a an attempt to create one based upon
the excellent [boxcutter ubuntu templates](https://github.com/boxcutter/ubuntu), mixed with some pieces from the
[StefanScherer mint template](https://github.com/StefanScherer/mint). 

### Avaiable Online ###

This box has been pre-built and uploaded to the [Hashicorp Atlas repository](https://atlas.hashicorp.com/boxes/search). 
Specifically, [it is available there as rapa/mint-17.3-dev](https://atlas.hashicorp.com/rapa/boxes/mint-17.3-dev).
This code relates to the 1.3.2 release of that box.

In order to keep this template simple (and because I
didn't have the capacity to test/verify other versions) the only builder remaining in the scripts is for [VirtualBox](https://www.virtualbox.org/).

### Packer

You can download [Packer here](https://packer.io/). It is used to script the creation of base box files for use by [Vagrant](https://www.vagrantup.com/).

### Mint Cinnamon

Based upon the boxcutter templates, this template retains use of the JSON files containing user variables that enable variations in building specific versions of your box -
although only a single variation remains at this time. You tell`packer`to use a specific JSON file via the `-var-file=` command line
option.  This will add to, and override, the default options in the core`mint.json`packer template - if  no 'var' file is specified, the build will fail.

### Developers

The resultant base image is created with developers in mind. As a consequence, this build has a `developer.sh` script that installs various programming languages and tools.
* Git 2.8.3
* Python 2.7.6
* Oracle Java 1.8.0_91
* Scala 2.11.8
* PHP 5.5.9
* Ruby 2.3.1p112
* Node.js 5.11.1
* Go 1.6.2
* Swift 2.2.1
* Rust 1.9.0
* Haskell GHC 7.6.3
* Maven 3.3.9
* Gradle 2.13
* sbt 0.13.11
* Docker 1.11.1
* docker-compose 1.7.1
* Vagrant 1.8.1
* VirtualBox 5.0.2r102096

### Build Environment

If you are working/experimenting a lot with packer, it can be worth setting a global packer cache location to reduce the duplication of downloads.
Add the following to your `.bashrc` file:

    export PACKER_CACHE_DIR="$HOME/packer_cache"

### Building

To build a Mint Cinnamon 17.3 developers Vagrant base box, execute the following from the base directory:

    $ packer validate -var-file=mint-cinnamon-17.3.json mint.json
    $ packer build -var-file=mint-cinnamon-17.3.json mint.json
    
Once the build has completed, you can create the actual VM image in Vagrant with something like the following:

    $ vagrant box add mintBox box/virtualbox/mint-cinnamon-17.3-box--dev-1.3.2.box
    $ vagrant init mintBox
    $ vagrant up
    




## boxcutter README

The following has been left in verbatim, from the existing [boxcutter README](https://github.com/boxcutter/ubuntu/blob/master/README.md)

### Variable overrides

There are several variables that can be used to override some of the default
settings in the box build process. The variables can that can be currently
used are:

* cm
* cm_version
* cpus
* disk_size
* memory
* update

Changing the value of the `CM` variable changes the target suffixes for
the output of `make list` accordingly.

Possible values for the CM variable are:

* `nocm` - No configuration management tool
* `ansible` - Install Ansible
* `chef` - Install Chef
* `chefdk` - Install Chef Development Kit
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 11.12.4`

The variable `HEADLESS` can be set to run Packer in headless mode.
Set `HEADLESS := true`, the default is false.

The variable `UPDATE` can be used to perform OS patch management.  The
default is to not apply OS updates by default.  When `UPDATE := true`,
the latest OS updates will be applied.

The variable `PACKER` can be used to set the path to the packer binary.
The default is `packer`.

The variable `ISO_PATH` can be used to set the path to a directory with
OS install images. This override is commonly used to speed up Packer builds
by pointing at pre-downloaded ISOs instead of using the default download
Internet URLs.

The variables `SSH_USERNAME` and `SSH_PASSWORD` can be used to change the
 default name & password from the default `vagrant`/`vagrant` respectively.

The variable `INSTALL_VAGRANT_KEY` can be set to turn off installation of the
default insecure vagrant key when the image is being used outside of vagrant.
Set `INSTALL_VAGRANT_KEY := false`, the default is true.




