#!/bin/bash

set -e
set -u

# Source the configuration directories
. config.sh

list="gcc g++ ld ar as ranlib strip windres nm"
# TODO: Are others needed here?

for name in $list; do
    tool="${targ}-${name}"
    echo "tool = ${tool}"
    sudo update-alternatives --remove-all ${tool} || echo "  no previous ${tool}"
    sudo update-alternatives --install /usr/bin/${tool} ${tool} ${MY_SYS_ROOT}/bin/${tool} 20 || echo "  could not install"
#    sudo update-alternatives --set ${tool} ${MY_SYS_ROOT}/bin/${tool} || echo "could not install"
    sudo update-alternatives --config ${tool} || echo "  when configuring ${tool}"
done
