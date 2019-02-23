#!/bin/bash -x

ctr1=`buildah from ${1:-fedora}`

# Install RPMFusion repos + ffmpeg
buildah run $ctr1 -- dnf update -y
buildah run $ctr1 -- dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
buildah run $ctr1 -- dnf install -y alsa-lib xorg-x11-server-Xorg ffmpeg
buildah run $ctr1 -- dnf clean all

# Set entrypoint
buildah config --entrypoint '[ "/usr/bin/ffmpeg" ]' $ctr1

## Commit this container to an image name
buildah commit $ctr1 ${2:-$USER/ffmpeg}
