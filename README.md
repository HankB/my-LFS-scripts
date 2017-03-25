### my LFS scripts

## Prerequisites

This is run on a Debian Stretch Linux host (Stretch is a release candidate
at this point.

## Usage

* Edit set-LFS.sh to point to where you plan to mount the LFS partition
* Edit prep.sh and set the line `export LFS_DEV=/dev/sda7` to point to
  the partition you plan to use. (The script `prep.sh` will not create the
  partition but will format it as EXT4 if it is not mounted.)
* It may be convenient to symlink the scripts to your `~/bin` directory
  or add the directory they're in to your `$PATH`
* execute `prep.sh`
* execute `fetch-sources.sh`
* execute `final-prep.sh`
* Set up MAKEFLAGS if desired (http://www.linuxfromscratch.org/lfs/view/stable/chapter04/aboutsbus.html)
  Maybe put in the .bashrc for lfs
* Add the location of the scripts to the $PATH in ~lfs/.bashrc
* su to lfs (`su - lfs`) for next step
* execute `build-stage1.sh`