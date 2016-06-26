My Dotfiles
===========

Feel free to copy or use my scripts for your own customization.

Copyright (c) 2011-2016 Uwe Jugel, Licensed under the MIT license (see LICENSE file)

Installation
============

Clone dotfiles

    $ git clone https://github.com/ubunatic/dotfiles.git

Install symlinks to dotfiles and create copy-once files

    $ install.sh

Copy-once files are currently `.profile` and `.vimplugins`. They are supposed to be heavily
customized and different on each host, thus we do not want their changes to be seen in git.

Install and update links (creates backups as FILENAME~). Copy-once files are not updated.

    $ install.sh --force

Install, update, copy, and remove all backup files

    $ install.sh --force --clean

Install symlinks, includig links to copy-once files

    $ install.sh --all

Note that using `--force` and thus `--force --all` will overwrite any existing file if it
is not a symlink pointing to the correct target. Be careful not to overwrite you data!

Shellib
=======

The `shellib` library contains some utility functions and common profile setups.
It is installed by default to `.shellib` when running `install.sh`,
which also adds a `source .shellib/shellib.sh` line to your `.profile`.

TODO
====
- add `--copy` option to prevent customizations be visible inside the git repo
- add `--force-copy` option to allow explicit upgrading of copy-once files
- rethink the option names in general: "copy vs. link", "once vs. always"
- write unit tests for shellib
- run tests on other systems: `bash` vs `zsh`, ubuntu, raspian, fedora, arch, etc.

