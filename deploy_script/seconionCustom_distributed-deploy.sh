#! /bin/bash

# May need to adjust so-allow on the seconion-managernode
# developer - threathunternotebook
# Last update 08/04/2021

rm -rf /tmp/vault-file

cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-manager /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-search /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-sensor /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/secrets.yml /home/ansible/ansible/secOnion-custom/vars/

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

# Set usernames and passwords in SO automation scripts
while [ $USRMATCH != yes ]; do
  echo -e ${YELLOW}
  read -sp 'Set admin username for security onion : ' adminvar
  echo
  echo -e ${NC}
  read -sp 'Re-enter admin username for security onion nodes : ' adminvar2
  if  [ $adminvar == $adminvar2 ]; then
    USRMATCH=yes
    echo -e "\nThank you ${RED}$uservar${NC} we now have the username and password for SO deployment!\n"
  else
    echo -e "${RED}\nThe security onion usernames did not match. Press enter to try again.\n${NC}"
  fi
done

echo -e The security onion vm administrator is ${RED}$adminvar${NC}
echo

# Get zeek processor count
echo  -e ${YELLOW}
read -p 'How many processors do you want to assign to Zeek? (if you do not know, put 10) : ' zeekvar

#Get suricata processor count
echo  -e ${YELLOW}
read -p 'How many processors do you want to assign to Suricata? (if you do not know, put 10) : ' surivar

#Get Elasticsearch Java Heap space memory configuration
echo  -e ${YELLOW}
read -p 'How much memory do you want for Elasticsearc Heap memory? (Example: 16384m. if you do not know, put 16384m) : ' esheapvar
echo -e ${NC}

# Write processor count and heap requirement to secrets.yml file
cd /home/ansible/ansible/secOnion-custom/vars && sed -i "s/8192m/$esheapvar/g" "secrets.yml"
cd /home/ansible/ansible/secOnion-custom/vars && sed -i "s/zeek_lbprocs: 3/zeek_lbprocs: $zeekvar/g" "secrets.yml"
cd /home/ansible/ansible/secOnion-custom/vars && sed -i "s/suriprocs: 3/suriprocs: $surivar/g" "secrets.yml"

# Write ESHEAP to secrets.yml file
cd /home/ansible/ansible/secOnion-custom/vars && sed -i 's/esheap.*/esheap: '\"\'$esheapvar\'\"'/g' secrets.yml

# Set usernames and password in the SO managernode automation configuration file
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/AUSERNAME/$adminvar/g" "distributed-airgap-manager"
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/WUSERNAME/$adminvar@hostname.domain/g" "distributed-airgap-manager"
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/PASSWORD/$passvar/g" "distributed-airgap-manager"

# Set usernames and password in the SO searchnode automation configuration file
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/AUSERNAME/$adminvar/g" "distributed-airgap-search"
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/PASSWORD/$passvar/g" "distributed-airgap-search"

# Set usernames and password in the SO sensornode automation configuration file
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/AUSERNAME/$adminvar/g" "distributed-airgap-sensor"
cd /home/ansible/ansible/secOnion-custom/files && sed -i "s/PASSWORD/$passvar/g" "distributed-airgap-sensor"


## ----------- Deploy SecOnion 2.3.10 virtual machines to vsphere ---------------- ##
echo -e "${RED}Deploying and Configuring Security Onion 2.3.30 Custom Cluster VMs${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-distributed-cluster-playbook.yml

echo -e "${RED}Configuring Security Onion Manager Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-managernode.yml

echo -e "${RED}Running sosetup on Security Onion Manager Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-sosetup-managernode.yml

sleep 180

echo -e "${RED}Cleaning up Security Onion Manager Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-cleanup-managernode.yml

echo -e "${RED}Configuring Security Onion Search Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-searchnode.yml

echo -e "${RED}Running sosetup on Security Onion Search Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-sosetup-searchnode.yml

sleep 180

echo -e "${RED}Cleaning up Security Onion Search Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-cleanup-searchnode.yml

echo -e "${RED}Configuring Security Onion Sensor Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-sensornode.yml

echo -e "${RED}Running sosetup on Security Onion Sensor Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-sosetup-sensornode.yml

sleep 180

echo -e "${RED}Cleaning up Security Onion Sensor Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-config-cleanup-sensornode.yml


echo -e "${RED}Configuring and updating Suricata rules on Security Onion Manager Node${NC}"
cd /home/ansible/ansible/secOnion-custom
ansible-playbook -i hosts --vault-id /tmp/vault-file seconion-custom-ruleupdate-managernode.yml

echo -e "\nWe are done deploying, ${RED}$uservar${NC}! Double-check for any errors. You may need to run ${RED}sudo salt \\* state.highstate${NC} on the managernode.\n"

rm -rf /tmp/vault-file

cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-manager /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-search /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/distributed-airgap-sensor /home/ansible/ansible/secOnion-custom/files/
cp /home/ansible/ansible/secOnion-custom/files/backup/secrets.yml /home/ansible/ansible/secOnion-custom/vars/
