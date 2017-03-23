# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# === Start Shellib ===

source $HOME/.shellib/shellib.sh # generated by shellib (do not edit manually)

# === Load Bash Utils + Defaults ===
# adapted from Ubuntu's default .profile
if test -n "$BASH_VERSION" && test -f "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi
# set PATH so it includes user's private bin directories
addPATH $HOME/bin
addPATH $HOME/.local/bin

# === Custom Settings ===
