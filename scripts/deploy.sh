#!/usr/bin/bash

###################################################################################################################
# This script will download and install the openshift-client, openshift-install and rhcos-live.iso binaries       #
# which are required to configure an iso file used for single-node openshift without the use of the assisted      #
# installer.                                                                                                      #
#                                                                                                                 #
# This script uses whatever the latest STABLE version of openshift release. If you want to override to a specific #
# version, change the OCP_VER and the OCP_WWW variables to match the specific release.                            #
#                                                                                                                 #
# Example Overrides:                                                                                              #
# OCP_VER=4.11.9                                                                                                  #
# OCP_WWW=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.11.9                                        #
###################################################################################################################

# Define some global variables
OCP_WWW=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable
OCP_VER=$(curl -s ${OCP_WWW}/release.txt | grep Name | awk '{print $2}')
OCP_DEPLOY=${PWD}/${OCP_VER}
ARCH=x86_64

# Just telling you what we're doing
echo -e "\nThe binaries for ${OCP_VER} will be downloaded\n"

# Allowing for alias expansion
shopt -s expand_aliases 
alias coreos-installer='podman run --privileged --pull always --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release'

#########################################
# beginning of artifact gather/creation #
#########################################

function sno_artifact_setup () {
# Make deploy directory if it doesn't exist
echo -e "\nCreate deployment directory (${OCP_DEPLOY}) if it doesn't exist\n"

if [ ! -d ${OCP_DEPLOY} ]; then
  mkdir ${OCP_DEPLOY}
fi

echo -e "\nIn addition to the binaries being downloaded, this script requires podman to run\n"
which podman

if [[ ! $? == 0 ]]; then
  sudo dnf install -y podman
fi

}

# download the binaries for openshift-install and oc 
function get_binaries () {
pushd ${OCP_DEPLOY} > /dev/null

if [[ ! -a ${OCP_DEPLOY}/oc ]]; then
     echo -e "\ndownload and install openshift-client binary"
     curl -LfO# ${OCP_WWW}/openshift-client-linux.tar.gz && \
     tar xvf openshift-client-linux.tar.gz && \
     rm -rf openshift-client-linux.tar.gz 
fi
  
if [[ ! -a ${OCP_DEPLOY}/openshift-install ]]; then
    echo -e "\ndownload and install openshift-linux binary"
    curl -LfO# ${OCP_WWW}/openshift-install-linux.tar.gz && \
    tar xvf openshift-install-linux.tar.gz && \
    rm -rf openshift-install-linux.tar.gz
fi

if [[ ! -a ${OCP_DEPLOY}/rhcos-live.iso ]]; then
     echo -e "\ndownload coreos iso"
     # Retrieve RHCOS ISO URL and download
     ISO_URL=$(./openshift-install coreos print-stream-json | grep location | grep $ARCH | grep iso | cut -d\" -f4)
  
     echo -e "\nDownloading red hat coreos iso\n"
     curl -L# ${ISO_URL} -o rhcos-live.iso
fi
  
for i in openshift-install oc kubectl;
  do
    chmod 755 ${i} ; 
  done
}
  
function generate_ocp_assets() {
pushd ${OCP_DEPLOY} > /dev/null

if [ ! -d ${OCP_DEPLOY}/ocp ]; then
  echo -e "\nCreating ocp manifest directory\n"
  mkdir ocp
fi
cp ../install-config.yaml ocp/

echo -e "\ngenerating manifests for single node\n"
./openshift-install --dir ocp/ create single-node-ignition-config

echo -e "\nembedding ignition files in iso\n" 
coreos-installer iso ignition embed -fi ocp/bootstrap-in-place-for-live-iso.ign rhcos-live.iso
}

#Always run setup
sno_artifact_setup
get_binaries
generate_ocp_assets
