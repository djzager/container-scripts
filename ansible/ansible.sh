#!/usr/bin/env bash
set -e
set -o pipefail

TAG=${1:-$USER/ansible}

ctr=`buildah from fedora`
buildah run $ctr -- dnf update -y
buildah run $ctr -- dnf install -y python
buildah run $ctr -- dnf clean all

buildah run $ctr -- pip install ansible${ANSIBLE_VERSION:+==$ANSIBLE_VERSION} openshift jmespath
buildah copy $ctr ansible.cfg /etc/ansible/ansible.cfg
buildah config --entrypoint '[ "/usr/bin/ansible-playbook" ]' \
               --workingdir "/opt/ansible/" $ctr

## Commit this container to an image name
buildah commit $ctr ${TAG}${ANSIBLE_VERSION:+:$ANSIBLE_VERSION}
buildah rm $ctr
