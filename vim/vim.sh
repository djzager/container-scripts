#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR="$(dirname ${SCRIPT})"

DEFAULT_TAG="${TAG:-$USER/vim}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

install_vim() {
	local ctr=$1

	# TODO, pull out (fzf+ripgrep) and git
	buildah run $ctr -- dnf install -y vim fzf git ripgrep
	buildah config --env FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null' $ctr
	buildah copy $ctr $XDG_CONFIG_HOME/vim /root/.vim
	buildah run $ctr -- vim +PlugInstall +qall
}

build_vim() {
	local ctr=$1
	local tag=${2:-$DEFAULT_TAG}
	source "${DIR}/../fedora/fedora.sh"

	container_from_fedora $ctr
	install_vim $ctr
	buildah run $ctr -- dnf clean all
	buildah config --entrypoint '[ "/usr/bin/vim" ]' $ctr
	buildah commit $ctr $tag
}

# If run as script, then build it
if ! $(return >/dev/null 2>&1); then
	ctr="vim-working-container"
	TAG="${TAG:-$DEFAULT_TAG}"
	buildah rm $ctr >/dev/null 2>&1 || true
	build_vim $ctr $TAG
	buildah rm $ctr >/dev/null 2>&1
fi
