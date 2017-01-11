# ESXI-VMS

Launch VMs on ESXI (Ubuntu Xenial in an _as-automated-as-possible_ fashion).

### **To Run:**

```
ansible-playbook main.yml -i hosts --ask-pass
```

when prompted, enter

* _**up**_: to spin up a new set of VMs
* _**down**_: to destroy an existing set of VMs

VMs are defined under `vars/vms.yml`

ESXI hosts are defined under `hosts` > `esxi`. If you'd rather not store the admin/root ESXI user on the local _"hosts"_ file, pass it as a parameter during execution:

```
ansible-playbook main.yml -i hosts --ask-pass --user=USERNAME
```

### **VM sample config:**
```
---
vm_list:
  -
    hostname: web01
    fqdn:     web01.home.local
    ip:       192.168.1.50
    clone_vm: ubuntu_xenial                 #  Pre-existing "clone" VM
    os:       ubuntu-64                     #  VM OS Version
    up:       true                          #  Whether VM is ON/OFF
    hardware:
      cpus:   1                             #  Limited by host specs
      disk:   8                             #  Large enough to store pkgs + data
      memory: 2048                          #  Limited by host specs
```


### **Download Ubuntu Xenial (16.04):**

**via Ansible:**

```
ansible-playbook get_iso.yml -i hosts --ask-pass
```

**Manually:**

Run these commands on each ESXI box (with "root" level privileges)

```
mkdir -p /vmfs/volumes/datastore1/images
cd !$ 
wget -q http://releases.ubuntu.com/xenial/ubuntu-16.04.1-server-amd64.iso
```

## **Create stand-alone "clone":**

This is the portion that can't be currently automated. It involves spinning up a very _resource-limited_ VM.

### **Install cloud-Init and leave "clone" alone:**
Login to the "clone" and execute the following commands:

```
sudo apt-get update
sudo apt-get install -y cloud-init
sudo shutdown now
```

## **What's going on here?!?:**

The basic premise here is quite simple, but a bit tricky:

**Manual Steps**

1. Manually create a "virgin" VM with _cloud-init_ pre-installed (this will become obvious in a bit) and use it as the on-going _"clone"_ VM
2. Ensure there's at least a _"sudo"_-enabled user that you can use to login to the VM and that the default "OpenSSH Server" is installed during initial provisioning
3. Keep _memory_, _cpu_ and _disk size_ to a minimun

**Automated Steps**

1. Create a VM folder on the ESXI host
2. Locally create a _cloud-init_ valid _user-data file_, package this file into an ISO image and upload it to the ESXI folder created in the previous step
3. Use the built-in _vmkfstools_ tool to **a)** clone the pre-existing VM's disk and **b)** resize it
4. Create a new _.vmx_ with the new VM specs (_memory_, _cpu_), ensure that the file "attaches" a CD drive pointed to the physical location of the newly uploaded ISO image
5. Register the newly create VM with the _vim-cmd_ tool, use the same tool to automatically start the VM
4. On first-boot, the VM will _"execute"_ the instructions on the _user-data_ file found on the ISO on the attached CD (i.e., create the ansible user, grant it "sudo" rights, assign a fixed IP address and a hostname, etc.). These steps are enough to get the VM to be visible on the network and for Ansible to take over and manage
5. For the newly-assigned IP address to be active a reboot is in order, hence the last step of the _user-data_ instructions is to perform a reboot
6. Your new VMs are now ready



## **Pre-requisites:**

* An ESXI host (doh!) with _ssh access_ enabled
* An Ansible-ready local machine
* A `vars/vms.yml` file listing VM specs



## **Oh god, why?!?:**

I've been a fan of **ESXI** for the longest time, but I've never had a chance to work with it on the job. I'm also a **Mac mini** fan and have accumulated a few over the years: they look sleek, consume little physical space, consume even less energy and are extremely quiet -- hence, they are the ideal home server lab nodes. 

A few years ago, I found out that you could run the free version of **[ESXI](http://www.virtuallyghetto.com/apple)** on a Mac mini and have managed to run pretty much everything on it (from _Windows XP_ clients, to _OSX Lion_ as local DNS servers, with a few _Linux distros_ thrown in for good measure). 

However, the VMWare mantra --like the mantra of traditional IT vendors-- is to still do things in a **"point-n-click"** way (the _"pets"_ vs _"cattle"_ argument). I've been using the **AWS cloud** and **Vagrant** for years and wanted a way to (as much as possible) drive the creation of VMs in a _"cloud-like"_, _"code-driven"_ fashion. Hence, this is a _"pet"_ project (no pun intended) to get ESXI to behave as much as possible as my personal home cloud, and in the process combine the tech artifacts that I love (_Mac Minis_, _Ansible_, _Ubuntu_, & some good-old _Bash_). 

There are a few [solutions](https://github.com/nsidc/vagrant-vsphere) out there that do something similar but require a licensed-copy of vCenter -- it proved to be quite a challenge to get all these pieces to work together just using free ESXI, so I'm quite satisfied with the current results. There's always room for improvement so I'll continue _"polishing up"_ what I have so far.