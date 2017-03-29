### my LFS scripts

## Prerequisites

This is run on a Debian Stretch Linux host (Stretch is a release candidate
at this point.

## Usage

* Edit set-LFS.sh to point to where you plan to mount the LFS partition. Also set LFS_DEV to
  point to the partition where the LFS partition will be mounted. If it is not mounted, the script
  `prep.sh` will format the partition as EXT4 using the instructions at
  http://www.linuxfromscratch.org/lfs/view/6.5/chapter02/creatingfilesystem.html.
* It may be convenient to symlink the scripts to your `~/bin` directory
  or add the directory they're in to your `$PATH`
* execute `prep.sh`
* mount the lsf file system created by `prep.sh`
* execute `fetch-sources.sh`
* execute `final-prep.sh`
* su to lfs (`su - lfs`) for next steps
* execute `final-prep-as-lfs.sh` (This should only be done once after the `lfs` user has been created.)
* verify that the PATH includes the location of the scripts in this package. (Or the scripts are put somewhere in the existing PATH.)
* Set up MAKEFLAGS if desired (http://www.linuxfromscratch.org/lfs/view/stable/chapter04/aboutsbus.html)
  Maybe put in the .bashrc for user lfs
* Add the location of the scripts to the $PATH in ~lfs/.bashrc
* execute `build-stage1.sh` (See Errata about executing last command in the script.)

(More to come)

## Errata

* Chapter 5.17 Bison `make check` fails on

    `g++: error: ./examples/calc++/calc++-scanner.cc: No such file or directory`

* Chapter 5.22 Findutils `test-lock` hangs using 100% processor. (But not on the second go 'round.)
* Chapter 5.23 Gawk-4.1.4 - also fails `make check`.
* Chapter 5.28. Make-4.2.1 also fails `make check`.
* At end of build-stage1.sh the user must execute the `chown` command in whatever manner
  is permitted given the root user setup. (On my system there is no root and 'lfs' does
  not have `sudo` privileges.)

## TODO
  
  * Check for `/tools` before linking to it in `final-prep.sh`
  * Set perms on `/tools`
