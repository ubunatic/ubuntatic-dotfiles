My Dotfiles
===========

Feel free to copy or use my scripts for your own customization.

Copyright (c) 2011-2016 Uwe Jugel, Licensed under the MIT license (see LICENSE file)

Installation
============

Clone dotfiles

    $ git clone https://github.com/ubunatic/dotfiles.git

Install symlinks to dotfiles

    $ install.sh

Install and update existing files (creates backups as FILENAME~)

    $ install.sh --force

Install and update and remove all backup files

    $ install.sh --clean

Install or update includig additional links to `.profile` and `.ctags`

    $ install.sh --clean --all


Shellib
=======

The `shellib` library contains some utility functions and common profile setup.
It is installed by default to `.shellib` when running `install.sh`,
which also adds a `source .shellib/shellib.sh` line to your `.profile`.


