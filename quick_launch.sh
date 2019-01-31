#!/bin/bash
## This script import and launch minimal KVM linked images with a text console  ##
## Usage : bash define-guest.sh <name> <image>                                  ##
##################################################################################
## Please check all the variables
# parameter as name
name=$1
# Image name : 'debian7', 'debian8', 'centos7', 'ubuntu1604', 'metasploitable', 'kali', 'arch'
imagename="debian7 debian8 debian9 centos7 centos7.5 ubuntu1604 ubuntu1804 metasploitable kali arch"
image="$2.qcow2"
# Generate an unique string
uuid=$(uuidgen -t)
# Nested (default no)
nested=""
#nested="--cpu host-passthrough"
# VCPUs
vcpu="1"
# The new guest disk name
disk="${name}-${uuid:25}.qcow2"
# Diskbus can be 'ide', 'scsi', 'usb', 'virtio' or 'xen'
diskbus="virtio"
size="8"
# Hypervisor can be 'qemu', 'kvm' or 'xen'
hypervisor="kvm"
# RAM in Mb
memory="512"
# Graphics 'none' or 'vnc'
graphics="none"
# Network interface and model 'virtio' or 'rtl8139' or 'e1000'
interface="virbr0"
model="virtio"
# Parameters for metasploitable guests
if [ $image = "metasploitable.qcow2" ]; then
diskbus="scsi"
memory="512"
model="e1000"
fi
# Parameters for Kali guests
if [ $image = "kali.qcow2" ]; then
memory="1024"
fi
if [ $image = "gns3.qcow2" ]; then
memory="2048"
nested="--cpu host-passthrough"
fi

## Download the image dialog function : list, choice, sure, download
usage_message () {
echo "Usage : $0 <name> <image>"
echo "Please download one of those images in /var/lib/libvirt/images :"
for x in $imagename ; do
echo "success."
done
}

## Check parameters
# check "$#" -lt 2
if [ "$#" -ne 2  ] ; then
usage_message
exit
fi
# check a valid image name
if grep -qvw "$2" <<< "$imagename" ; then
usage_message
exit
fi
# check the presence of the image
if [ ! -f /var/lib/libvirt/images/${image}  ] ; then
usage_message
exit
fi
# Check the usage of the requested domain
if grep -qw ${name} <<< $(virsh list --all --name)  ; then
echo "Please provide an other guest name : exit"
exit
fi

## Local image copy to the default storage pool ##
# --> qemu-img linked
#cp /var/lib/libvirt/images/$image /var/lib/libvirt/images/$disk
qemu-img create -f qcow2 -b /var/lib/libvirt/images/$image /var/lib/libvirt/images/$disk

## Customize this new guest disk
if [ $image = "ubuntu1804.qcow2" ]; then
sleep 1
virt-sysprep -a /var/lib/libvirt/images/$disk --operations customize --firstboot-command "sudo hostnamectl set-hostname $name ; sudo dbus-uuidgen > /etc/machine-id 
; sudo reboot"
else
virt-sysprep -a /var/lib/libvirt/images/$disk --hostname $name --selinux-relabel  --quiet
fi
#virt-sysprep -a guest.img --firstboot ./yum-update.sh --firstboot ./set-desktop.sh
#virt-sysprep --script --run-command --upload

## Import and lauch the new guest ##
virt-install \
--virt-type $hypervisor \
--name=$name \
--disk path=/var/lib/libvirt/images/$disk,size=$size,format=qcow2,bus=$diskbus \
--ram=$memory \
--vcpus=$vcpu \
--os-variant=linux \
--network bridge=$interface,model=$model \
--graphics $graphics \
--console pty,target_type=serial \
--import \
--noautoconsole $nested
