#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR="$(dirname ${SCRIPT})"
TAG="${TAG:-$USER/vim}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

source "${DIR}/../common.sh"

ctr="vim-working-container"

get_fedora $ctr
buildah run $ctr -- dnf install -y vim fzf git ripgrep
buildah run $ctr -- dnf clean all

# We don't want to inherit cmd from fedora
buildah config --cmd "" --entrypoint '[ "/usr/bin/vim" ]' $ctr

# Configure vim
buildah copy $ctr $XDG_CONFIG_HOME/vim /root/.vim
buildah run $ctr -- vim +PlugInstall +qall

buildah config --label maintainer="David Zager <david.j.zager@gmail.com>" \
               --env FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null' \
               $ctr
buildah commit --rm $ctr ${TAG}
