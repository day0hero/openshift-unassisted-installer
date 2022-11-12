# Generating the artifacts to deploy unassisted single-node-openshift

The very first thing to do is update the vars files (see example below). 

### Variable Table
|parameter|value|description|
|---------|-----|-----------|
|base_domain|`example.com`|This is your dns top level domain|
|cluster_name|`ocp`|Something clever or reasonable to describe your cluster|
|machine_network_cidr|`192.168.1.0/24`|This is the network that your machine is on|
|installationDisk|`/dev/sda`|Disk to install SNO on|
|quay_pull_secret|`~/pullsecret.json`|This is your quay pullsecret you get from: [openshift console](https://console.redhat.com/openshift)|
|ssh_public_key|`~/.ssh/id_rsa.pub`|The pubkey for ssh'ing to SNO|

Run the playbook:
```bash
cd playbook/
ansible-playbook unassisted-sno-deploy.yml -e @uai-vars.yml
```

Variable File
```yaml
# OpenShift mirror root - to simplify downloads
ocp_www: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable

#DNS base domain: ex: example.com
base_domain: example.com

#Add your cluster name
cluster_name: ocp

#Cluster network configuration. The pod and service
#networks are the default ocp/k8s cidrs. The machine 
#cidr will be the network where your SNO will be installed.
cluster:
  pod_network_cidr: 10.128.0.0/16
  pod_host_prefix: '23'
  service_network_cidr: 172.30.0.0/16
  machine_network_cidr: 192.168.1.0/24

#Disk where you want SNO installed
installationDisk: /dev/sda

#Pull secret from console.redhat.com/openshift
quay_pull_secret: "{{ lookup('file', '~/pullsecret.json') | from_json | to_json(separators=(',',':')) |default(omit) }}"

#Full path to Public SSH key for ssh into SNO (core@<sno_ip>), this
#defaults to ~/.ssh/id_rsa.pub
#example: 
#ssh_public_key: /home/testuser/.ssh/ocp_key.pub
ssh_public_key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```
