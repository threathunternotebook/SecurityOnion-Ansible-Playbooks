# SecurityOnion-Ansible-Playbooks
Ansible Playbooks for Security Onion Deployment to VMware ESXi
In this repo, we are going to present a method to deploy a custom Security Onion 2.3 distributed environment to ESXi using ansible playbooks and SO 2.3 automation configuration files. Note that the playbooks also correct some issues found during the implementation of this process.
## Ansible Playbook Order

Run the playbooks in the following order

seconion-distributed-cluster-playbook.yml

seconion-custom-config-managernode.yml

seconion-custom-config-sosetup-managernode.yml

seconion-custom-config-cleanup-managernode.yml

seconion-custom-config-searchnode.yml

seconion-custom-config-sosetup-searchnode.yml

seconion-custom-config-forwardnode.yml

seconion-custom-config-sosetup-forwardnode.yml
