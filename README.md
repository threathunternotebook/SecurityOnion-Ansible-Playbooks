# SecurityOnion-Ansible-Playbooks
Ansible Playbooks for Security Onion Deployment to VMware ESXi
In this repo, we are going to present a method to deploy a custom Security Onion 2.3 distributed environment to ESXi using ansible playbooks and SO 2.3 automation configuration files. Note that the playbooks also correct some issues found during the implementation of this process.\

#### Update - Ansible playbooks work for SO 2.3.30, 2.3.60, 2.3.100 for offline AIRGAP install

## Prerequisities
In order for the Ansible playbooks to deploy the Security Onion Nodes to ESXi, we need the following:
1. An ESXi server configured with datastore.  
2. Within the datastore, an 'iso' folder to hold our customized Security Onion ISO
3. A platform to create a Security Onion custom ISO
4. A customized Security Onion ISO
5. A DHCP server with DHCP reservations for our Security Onion node MAC addresses
6. A platform configured to run Ansible Playbooks

## Ansible Playbook Order

Run the playbooks in the following order

seconion-distributed-cluster-playbook.yml

seconion-custom-config-managernode.yml

seconion-custom-config-sosetup-managernode.yml

seconion-custom-config-cleanup-managernode.yml

seconion-custom-config-searchnode.yml

seconion-custom-config-sosetup-searchnode.yml

seconion-custom-config-sensornode.yml

seconion-custom-config-sosetup-sensornode.yml

seconion-custom-ruleupdate-managernode.yml
