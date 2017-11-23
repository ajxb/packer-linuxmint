# Packer templates for Mint Cinnamon

## Overview

This repository contains Packer templates for creating Linux Mint Cinnamon Vagrant boxes.

## Current boxes

* [Linux Mint 18.2 (64-bit)](https://app.vagrantup.com/ajxb/boxes/mint-18.2)
* [Linux Mint 18.3 (64-bit)](https://app.vagrantup.com/ajxb/boxes/mint-18.3)

## Building the Vagrant boxes with Packer

To build all the boxes, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

We make use of JSON files containing user variables to build specific versions of Linux Mint.
You tell `packer` to use a specific user variable file via the `-var-file=` command line
option.  This will override the default options on the core `core_template.json` packer template.

For example, to build Linux Mint 18.2, use the following:

    $ packer build -var-file=mint-cinnamon-18.2.json core_template.json

## Building the Vagrant boxes with the build script

We've also provided a wrapper script `bin\build.sh` for ease of use, so alternatively, you can use
the following to build Linux Mint 18.2 for all providers:

    $ ./bin/build.sh mint-cinnamon-18.2.json

## Contributing

1. Fork and clone the repo.
2. Create a new branch, please don't work in your `master` branch directly.
3. Fix stuff.
4. Update `README.md` and `AUTHORS` to reflect any changes.
5. If you have a large change in mind, it is still preferred that you split them into small commits.  Good commit messages are important.  The git documentation project has some nice guidelines on [writing descriptive commit messages](http://git-scm.com/book/ch5-2.html#Commit-Guidelines).
6. Push to your fork and submit a pull request.

### Acknowledgments

[r-a-p-a](https://github.com/r-a-p-a) for their work in providing the code on which this is based.
