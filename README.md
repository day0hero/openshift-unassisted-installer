# UNDER Development 

# OpenShift un-assisted installer

Use this repo to download and configure the resources required for a single node openshfit deployment
without the assistance of the Assisted Installer. You can either use the shell script or ansible playbook
provided to generate the configs. 

There is an install-config.yaml template in the examples directory, that if you use the script you will 
need to update with your settings and then run the script. The ansible playbook will take the values from 
the <insert_variables_file_name>.yml to create the file from jinja template. 

### Deploying Single Node OpenShift with the generated artifacts:

Once the iso has been generated, you will need to create a bootable media device (DVD,USB) with the ISO. 

Free/OpenSource tools that you can use:
balenaEtcher
fedoraMediaWriter
dd

Once you have your iso copied to your removable media, plug the device into your potential SNO
machine and boot from the ISO. If you are creating a virtual machine you can boot directly 
from the iso without the need to burn to removable media.


### Staging/ To Do:
- link videos to SNO demo
- link to adding worker to SNO cluster
- link to unassisted installer demo

