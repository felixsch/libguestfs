#!/bin/bash -
# libguestfs
# Copyright (C) 2016 Red Hat Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Test the find-inode command.

if [ -n "$SKIP_TEST_FIND_INODE_SH" ]; then
    echo "$0: test skipped because environment variable is set."
    exit 77
fi

# Skip if TSK is not supported by the appliance.
if ! guestfish add /dev/null : run : available "libtsk"; then
    echo "$0: skipped because TSK is not available in the appliance"
    exit 77
fi

if [ ! -s ../../test-data/phony-guests/windows.img ]; then
    echo "$0: skipped because windows.img is zero-sized"
    exit 77
fi

output=$(
guestfish --ro -a ../../test-data/phony-guests/windows.img <<EOF
run
find-inode /dev/sda2 0
EOF
)

# test $MFT is in the list
echo $output | grep -zq '{ tsk_inode: 0
tsk_type: r
tsk_size: .*
tsk_name: \$MFT
tsk_flags: 1
tsk_atime_sec: .*
tsk_atime_nsec: .*
tsk_mtime_sec: .*
tsk_mtime_nsec: .*
tsk_ctime_sec: .*
tsk_ctime_nsec: .*
tsk_crtime_sec: .*
tsk_crtime_nsec: .*
tsk_nlink: 1
tsk_link:
tsk_spare1: 0 }'
if [ $? != 0 ]; then
    echo "$0: \$MFT not found in files list."
    echo "File list:"
    echo $output
    exit 1
fi