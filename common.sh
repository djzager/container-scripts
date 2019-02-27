#!/usr/bin/env bash

get_fedora(){
	local name=$1
	local updated="fedora_updated"

	if buildah images $updated > /dev/null 2>&1; then
		buildah from --name $name fedora_updated
	else
		buildah from --name $name --pull-always fedora
		buildah run $name -- dnf update -y
		buildah commit $name $updated
	fi
}
