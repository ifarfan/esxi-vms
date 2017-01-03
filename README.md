
To Run:
# use 'up' to spin up a new set of VMs
# use 'down' to destroy set of VMs
```
ansible-playbook main.yml -i hosts --ask-pass
```

```
--user=USERNAME
--ask-pass
```

Install Cloud-Init and leave clone alone:
```
sudo apt-get update
sudo apt-get install -y cloud-init
sudo shutown now
```

VM config:
```
vm_list:
  -
    hostname: web01
    fqdn:     web01.home.local
    ip:       192.168.1.50
    clone_vm: ubuntu_xenial                 #  Clone VM
    os:       ubuntu-64                     #  OS Version
    up:       true                          #  Whether VM is ON/OFF
    hardware:
      cpus:   1                             #  Limited by host specs
      disk:   8                             #  Large enough to store pkgs + data
      memory: 2048                          #  Limited by host specs
```
