My Dotfiles
===========

Collection of scripts and config files used on my Linux systems.
Feel free to copy or use my scripts for your own customization.

Copyright (c) 2011-2017 Uwe Jugel, Licensed under the MIT license (see LICENSE file)


Installation
============

Clone dotfiles

    $ git clone https://github.com/ubunatic/dotfiles.git

Install symlinks to dotfiles and create copy-once files

    $ ./install.sh

Copy-once files are currently `.profile` and `.vimplugins`. They are supposed to be heavily
customized and different on each host, thus we do not want their changes to be seen in git.

Install and update links (creates backups as FILENAME~). Copy-once files are not updated.

    $ ./install.sh --force

Install, update, copy, and remove all backup files

    $ ./install.sh --force --clean


Advanced Installation and Usage
===============================

Install symlinks and copy-once `customized/*` files

    $ ./install.sh --copy-customized
	
Install symlinks including links to `customized/*` files

    $ ./install.sh --link-customized

Safe install and show diff

    $ ./install --diff

Safe install and show diff using the diff.tool configured for `git`

    $ ./install --difftool

Use the above command to manually update changes in the provided dotfiles


Shellib
=======

The `shellib` library contains some utility functions and common profile setups.
It is installed by default to `.shellib` when running `install.sh`,
which also adds a `source .shellib/shellib.sh` line to your `.profile`.


TODO
====
- write unit tests for shellib
- test on Mac
- run tests on other systems: `bash` vs `zsh`, ubuntu, raspian, fedora, arch, etc.

