#! /bin/bash

# May need to adjust so-allow on the seconion-managernode
# developer - threathunternotebook
# Last update 04/03/2021

rm -rf /tmp/vault-file

YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

USRMATCH=no
PASSMATCH=no

echo  -e ${YELLOW}
read -p 'What is your name?:' uservar

while [ $PASSMATCH != yes ]; do
  read -sp 'Enter Ansible Vault Password : ' passvar
  echo
  echo -e ${NC}
  read -sp 'Re-Enter Ansible Vault PASSWORD : ' passvar2
  if [ $passvar == $passvar2 ]; then
    PASSMATCH=yes
    echo -e "\nThank you ${RED}$uservar${NC} we now have the vault password to unleash the magic!\n"
    echo $passvar > /tmp/vault-file
  else
    echo -e "${RED}\nPasswords don't match. Press enter to try again.\n${NC}"
#    read -p
  fi
done

## ----------- Deploy SecOnion 2.3.10 virtual machines to vsphere ---------------- ##
echo -e "${RED}Need to add a new disk for the SO managernode for expansion${NC}"
cd /home/devops/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-addDisk-managernode.yml

echo -e "${RED}Let's add the new drive space to the nsm volume group.${NC}"
cd /home/devops/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-expand-managernode.yml

echo -e "${RED}Finally expand the nsm LVM${NC}"
cd /home/devops/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-extendLVM-managernode.yml

echo -e "\nWe are done expanding the SO nsm LVM on the managernode, ${RED}$uservar${NC}! Double-check for any errors. Run ${RED}sudo lvdisplay system/nsm${NC} on the managernode to view the LV Size.\n"

rm -rf /tmp/vault-file
