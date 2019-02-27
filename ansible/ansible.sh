#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR="$(dirname ${SCRIPT})"
TAG="${TAG:-$USER/ansible}"

source "${DIR}/../common.sh"
ctr="ansible-working-container"

get_fedora $ctr
buildah run $ctr -- dnf install -y python
buildah run $ctr -- dnf clean all

buildah run $ctr -- pip install ansible${ANSIBLE_VERSION:+==$ANSIBLE_VERSION} openshift jmespath
buildah copy $ctr "${DIR}/ansible.cfg" /etc/ansible/ansible.cfg
# We don't want to inherit the cmd from fedora
buildah config --cmd "" \
               --entrypoint '[ "/usr/bin/ansible-playbook" ]' \
               --workingdir "/opt/ansible/" $ctr

## Commit this container to an image name
buildah config --label maintainer="David Zager <david.j.zager@gmail.com>" $ctr
buildah commit --rm $ctr ${TAG}${ANSIBLE_VERSION:+:$ANSIBLE_VERSION}
