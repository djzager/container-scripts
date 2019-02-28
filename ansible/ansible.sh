#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR="$(dirname ${SCRIPT})"

DEFAULT_TAG="${TAG:-$USER/ansible}"

install_ansible() {
	local ctr=$1

	buildah run $ctr -- dnf install -y python
	buildah run $ctr -- dnf clean all
	buildah run $ctr -- pip install ansible${ANSIBLE_VERSION:+==$ANSIBLE_VERSION} openshift jmespath
	buildah copy $ctr "${DIR}/ansible.cfg" /etc/ansible/ansible.cfg
}

build_ansible() {
	local ctr=$1
	local tag=${2:-$DEFAULT_TAG}
	source "${DIR}/../fedora/fedora.sh"

	container_from_fedora $ctr
	install_ansible $ctr
	buildah config --entrypoint '[ "/usr/bin/ansible-playbook" ]' \
		       --workingdir "/opt/ansible/" $ctr
	buildah commit $ctr $tag
}

# If run as script, then build it
if ! $(return >/dev/null 2>&1); then
	ctr="ansible-working-container"
	TAG="${TAG:-$DEFAULT_TAG}"
	buildah rm $ctr >/dev/null 2>&1 || true
	build_ansible $ctr $TAG
	buildah rm $ctr >/dev/null 2>&1
fi
