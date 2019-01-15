#!/bin/bash -x

ctr1=`buildah from ${1:-fedora}`

## Get all updates and install our Ansible
buildah run $ctr1 -- dnf update -y
buildah run $ctr1 -- dnf install -y python
buildah run $ctr1 -- dnf clean all
buildah run $ctr1 -- pip install ansible openshift

## Run our server and expose the port
buildah config --cmd "/usr/bin/ansible-playbook" $ctr1

## Commit this container to an image name
buildah commit $ctr1 ${2:-$USER/ansible}
