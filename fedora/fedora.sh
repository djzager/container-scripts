#!/usr/bin/env bash
set -e
set -o pipefail

DEFAULT_TAG="${USER}/fedora"

build_fedora() {
	local ctr=$1
	local tag="${2:-$DEFAULT_TAG}"

	buildah from --name $ctr --pull-always fedora
	buildah run $ctr -- dnf update -y
	buildah config --label maintainer="David Zager <david.j.zager@gmail.com>" $ctr
	# We don't want to inherit cmd from fedora
	buildah config --cmd "" $ctr
	buildah commit $ctr $tag
}

container_from_fedora() {
	local ctr=$1
	local tag="${2:-$DEFAULT_TAG}"

	if buildah images $tag >/dev/null 2>&1; then
		buildah from --name $ctr $tag
	else
		build_fedora $ctr
	fi
}

# If run as script, then build it
if ! $(return >/dev/null 2>&1); then
	ctr="fedora-working-container"
	TAG="${TAG:-$DEFAULT_TAG}"
	buildah rm $ctr >/dev/null 2>&1 || true
	build_fedora $ctr $TAG
	buildah rm $ctr >/dev/null 2>&1
fi
