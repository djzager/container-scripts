#!/usr/bin/env bash
set -e
set -o pipefail

TAG=${1:-$USER/redhat-ddns}

ctr1=`buildah from ${1:-fedora}`

# Install redhat-ddns
buildah run $ctr1 -- dnf update -y
buildah run $ctr1 -- curl -L -o /etc/pki/ca-trust/source/anchors/newca.crt https://password.corp.redhat.com/newca.crt
buildah run $ctr1 -- curl -L -o /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt https://password.corp.redhat.com/RH-IT-Root-CA.crt
buildah run $ctr1 -- update-ca-trust extract
buildah run $ctr1 -- dnf -y install http://hdn.corp.redhat.com/rhel7-csb-stage/RPMS/noarch/redhat-internal-ddns-client-1.3-12.el7.csb.noarch.rpm
buildah run $ctr1 -- dnf clean all

buildah config --entrypoint '["/usr/bin/redhat-internal-ddns-client.sh"]' $ctr1
buildah config --cmd "update" $ctr1

buildah commit $ctr1 ${TAG}
buildah rm $ctr1
