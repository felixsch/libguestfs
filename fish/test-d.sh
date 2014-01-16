#!/bin/bash -
# libguestfs
# Copyright (C) 2010 Red Hat Inc.
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

# Test guestfish -d option.

set -e

rm -f test-d-{1,2,3,4}.img
rm -f test-d.xml test-d.out

cwd="$(pwd)"

$VG ./guestfish sparse test-d-1.img 1M
$VG ./guestfish sparse test-d-2.img 1M
qemu-img create -f qcow2 test-d-3.img 1M
$VG ./guestfish sparse test-d-4.img 1M

# Libvirt test XML, see libvirt.git/examples/xml/test/testnode.xml
cat > test-d.xml <<EOF
<node>
  <domain type="test">
    <name>guest</name>
    <os>
      <type>hvm</type>
      <boot dev='hd'/>
    </os>
    <memory>524288</memory>
    <devices>
      <disk type="file">
        <source file="$cwd/test-d-1.img"/>
        <target dev="hda"/>
      </disk>
      <disk type="file">
        <driver name="qemu" type="raw"/>
        <source file="$cwd/test-d-2.img"/>
        <target dev="hdb"/>
      </disk>
      <disk type="file">
        <driver name="qemu" type="qcow2"/>
        <source file="$cwd/test-d-3.img"/>
        <target dev="hdc"/>
      </disk>
      <disk type="file">
        <driver name="qemu" type="raw"/>
        <source file="$cwd/test-d-4.img"/>
        <target dev="hdd"/>
        <readonly/>
      </disk>
    </devices>
  </domain>
</node>
EOF

$VG ./guestfish -c "test://$cwd/test-d.xml" --ro -d guest \
  debug-drives </dev/null >test-d.out
grep -sq "test-d-1.img readonly" test-d.out
! grep -sq "test-d-1.img.*format" test-d.out
grep -sq "test-d-2.img readonly format=raw" test-d.out
grep -sq "test-d-3.img readonly format=qcow2" test-d.out
grep -sq "test-d-4.img readonly format=raw" test-d.out

rm test-d-{1,2,3,4}.img
rm test-d.xml test-d.out
