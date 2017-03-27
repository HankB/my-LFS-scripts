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
* execute `fetch-sources.sh`
* execute `final-prep.sh`
* Set up MAKEFLAGS if desired (http://www.linuxfromscratch.org/lfs/view/stable/chapter04/aboutsbus.html)
  Maybe put in the .bashrc for lfs
* Add the location of the scripts to the $PATH in ~lfs/.bashrc
* su to lfs (`su - lfs`) for next step
* execute `build-stage1.sh` (See Errata about executing last command in the script.)

## Errata

* Chapter 5.22 Findutils `test-lock` hangs using 100% processor.
* At end of build-stage1.sh the user must execute the `chown` command in whatever manner
  is permitted given the root user setup. (On my system there is no root and 'lfs' does
  not have `sudo` privileges.)