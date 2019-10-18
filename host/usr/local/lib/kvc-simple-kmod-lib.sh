#!/bin/bash

# The MIT License

# Copyright (c) 2019 Dusty Mabe

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -eux

CONTAINER_RUNTIME=/usr/bin/podman

c_run()   { $CONTAINER_RUNTIME run -it --rm $@; }
c_build() { $CONTAINER_RUNTIME build  $@; }
c_images(){ $CONTAINER_RUNTIME images $@; }
c_rmi()   { $CONTAINER_RUNTIME rmi    $@; }

build_kmod_container() {
    kver=$1; image=$2
    echo "Building ${image} kernel module container..."
    c_build -t ${image} --label="name=${name}" \
        --build-arg KVER=${kver} \
        --build-arg KMODVER=a8c6682 \
        /var/b/shared/code/github.com/dustymabe/kvc-simple-kmod/
        git://github.com/dustymabe/kvc-simple-kmod

}

build_kmods() {
    # Image name will be modname-version
    # Image tag will be kernel version
    name=$1
    version='a8c6682'
    kver=$2
    image="${name}-${version}:${kver}"

    # Check to see if it's already been built
    if [ ! -z "$(c_images $image --quiet 2>/dev/null)" ]; then
        echo "The ${image} kernel module container is already built"
    else
        build_kmod_container $kver $image
    fi

    # Sanity check to make sure the built kernel modules were really
    # built against the correct module software version
    # Note the tr to delete the trailing carriage return
    x=$(c_run $image modinfo -F version "/lib/modules/${kver}/simple-kmod.ko" | \
                                                                        tr -d '\r')
    if [ "${x}" != "${version}" ]; then
        echo "Module version mismatch within container.. rebuilding ${image}..."
        build_kmod_container $kver $image
    fi
    # Sanity check to make sure the built kernel modules were really
    # built against the desired kernel version
    x=$(c_run $image modinfo -F vermagic "/lib/modules/${kver}/simple-kmod.ko" | \
                                                                    cut -d ' ' -f 1)
    if [ "${x}" != "${kver}" ]; then
        echo "Module not built against ${kver}.. rebuilding ${image}..."
        build_kmod_container $kver $image
    fi

    # get rid of any dangling containers if they exist
    rmi1=$(c_images -q -f label="name=${name}" -f dangling=true)
    # keep around any non-dangling images for only the most recent 3 kernels
    rmi2=$(c_images -q -f label="name=${name}" -f dangling=false | tail -n +4)
    if [ ! -z "${rmi1}" -o ! -z "${rmi2}" ]; then
        echo "Cleaning up old kernel module container builds..."
        c_rmi -f $rmi1 $rmi2
    fi
}

load_kmods() {
    # Image name will be modname-version
    # Image tag will be kernel version
    name=$1
    version='a8c6682'
    kver=$2
    image="${name}-${version}:${kver}"

    echo "Loading kernel modules using the kernel module container..."
    if lsmod | grep simple_kmod &>/dev/null; then
        echo "Kernel module already loaded"
    else
        c_run $image insmod /usr/lib/modules/${kver}/simple-kmod.ko
    fi
}

unload_kmods() {
    # Image name will be modname-version
    # Image tag will be kernel version
    name=$1
    version='a8c6682'
    kver=$2
    image="${name}-${version}:${kver}"

    echo "Unloading kernel modules..."
    if lsmod | grep simple_kmod &>/dev/null; then
        rmmod simple_kmod
    else
        echo "Kernel module already unloaded"
    fi
}
