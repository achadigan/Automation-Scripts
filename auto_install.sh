#!/bin/bash
#Centos 7, Debian Jessie or Ubuntu Xenial fully automatic installation by HTTP Repos and response file 
via local HTTP.
image=$1 # centos, debian, ubuntu
name=$2
fr_ubuntu_mirror=http://fr.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/
fr_debian_mirror=http://ftp.debian.org/debian/dists/jessie/main/installer-amd64/
ovh_ubuntu_mirror=http://mirror.ovh.net/ubuntu/dists/xenial/main/installer-amd64/
ovh_debian_mirror=http://debian.mirrors.ovh.net/debian/dists/jessie/main/installer-amd64/
ovh_centos_mirror=http://centos.mirrors.ovh.net/ftp.centos.org/7/os/x86_64
belnet_ubuntu_mirror=http://ftp.belnet.be/ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/
belnet_debian_mirror=http://ftp.belnet.be/debian/dists/jessie/main/installer-amd64/
belnet_centos_mirror=http://ftp.belnet.be/ftp.centos.org/7/os/x86_64
local_ubuntu_iso=/var/lib/iso/ubuntu-16.04.1-server-amd64.iso
url_ubuntu_iso=http://releases.ubuntu.com/16.04/ubuntu-16.04.1-server-amd64.iso
local_debian_iso=/var/lib/iso/debian-8.6.0-amd64-netinst.iso
url_debian_iso=http://cdimage.debian.org/debian-cd/8.6.0/amd64/iso-cd/debian-8.6.0-amd64-netinst.iso
local_centos_iso=/var/lib/iso/CentOS-7-x86_64-DVD-1611.iso
url_centos_iso=http://ftp.belnet.be/ftp.centos.org/7/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso
ubuntu_mirror=$belnet_ubuntu_mirror
debian_mirror=$fr_debian_mirror
centos_mirror=$belnet_centos_mirror
autoconsole=""
#autoconsole="--noautoconsole"

check_guest_name () {
if [ -z "${name}" ]; then
echo "Centos 7, Debian Jessie or Ubuntu Xenial fully automatic installation by HTTP Repos and response 
file via local HTTP."
echo "Usage : $0 [ centos | debian | ubuntu ] nom_de_vm"
echo "Please provide one distribution centos, debian, ubuntu and one guest name: exit"
exit
fi
if grep -qw ${name} <<< $(virsh list --all --name)  ; then
echo "Usage : $0 [ centos | debian | ubuntu ] nom_de_vm"
echo "Please provide a defined guest name that is not in use : exit"
exit
fi
}

check_apache () {
yum install -y httpd curl || apt-get install apache2 curl
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd
systemctl start httpd
mkdir -p /var/www/html/conf
echo "this is ok" > /var/www/html/conf/ok
local check_value="this is ok"
local check_remote=$(curl -s http://127.0.0.1/conf/ok)
if [ "$check_remote"="$check_value" ] ; then
 echo "Apache is working"
else
 echo "Apache is not working"
 exit
fi
}

ubuntu_install () {
local url=http://192.168.122.1/conf/ubuntu1604-preseed.cfg
local mirror=$ubuntu_mirror

touch /var/www/html/conf/ubuntu1604-preseed.cfg
cat << EOF > /var/www/html/conf/ubuntu1604-preseed.cfg
d-i debian-installer/language                               string      en_US:en
d-i debian-installer/country                                string      US
d-i debian-installer/locale                                 string      en_US
d-i debian-installer/splash                                 boolean     false
d-i localechooser/supported-locales                         multiselect en_US.UTF-8
d-i pkgsel/install-language-support                         boolean     true
d-i console-setup/ask_detect                                boolean     false
d-i keyboard-configuration/modelcode                        string      pc105
d-i keyboard-configuration/layoutcode                       string      be
d-i debconf/language                                        string      en_US:en
d-i netcfg/choose_interface                                 select      auto
d-i netcfg/dhcp_timeout                                     string      5
d-i mirror/country                                          string      manual
d-i mirror/http/hostname                                    string      fr.archive.ubuntu.com
d-i mirror/http/directory                                   string      /ubuntu
d-i mirror/http/proxy                                       string
d-i time/zone                                               string      Europe/Paris
d-i clock-setup/utc                                         boolean     true
d-i clock-setup/ntp                                         boolean     false
d-i passwd/root-login                                       boolean     false
d-i passwd/make-user                                        boolean     true
d-i passwd/user-fullname                                    string      user
d-i passwd/username                                         string      user
d-i passwd/user-password                                    password    testtest
d-i passwd/user-password-again                              password    testtest
d-i user-setup/allow-password-weak                          boolean     true
d-i passwd/user-default-groups                              string      adm cdrom dialout lpadmin 
plugdev sambashare
d-i user-setup/encrypt-home                                 boolean     false
d-i apt-setup/restricted                                    boolean     true
d-i apt-setup/universe                                      boolean     true
d-i apt-setup/backports                                     boolean     true
d-i apt-setup/services-select                               multiselect security
d-i apt-setup/security_host                                 string      security.ubuntu.com
d-i apt-setup/security_path                                 string      /ubuntu
tasksel tasksel/first                                       multiselect openssh-server
d-i pkgsel/include                                          string      openssh-server python-simplejson 
vim
d-i pkgsel/upgrade                                          select      safe-upgrade
d-i pkgsel/update-policy                                    select      none
d-i pkgsel/updatedb                                         boolean     true
d-i partman/confirm_write_new_label                         boolean     true
d-i partman/choose_partition                                select      finish
d-i partman/confirm_nooverwrite                             boolean     true
d-i partman/confirm                                         boolean     true
d-i partman-auto/purge_lvm_from_device                      boolean     true
d-i partman-lvm/device_remove_lvm                           boolean     true
d-i partman-lvm/confirm                                     boolean     true
d-i partman-lvm/confirm_nooverwrite                         boolean     true
d-i partman-auto-lvm/no_boot                                boolean     true
d-i partman-md/device_remove_md                             boolean     true
d-i partman-md/confirm                                      boolean     true
d-i partman-md/confirm_nooverwrite                          boolean     true
d-i partman-auto/method                                     string      lvm
d-i partman-auto-lvm/guided_size                            string      max
d-i partman-partitioning/confirm_write_new_label            boolean     true
d-i grub-installer/only_debian                              boolean     true
d-i grub-installer/with_other_os                            boolean     true
d-i finish-install/reboot_in_progress                       note
d-i finish-install/keep-consoles                            boolean     false
d-i cdrom-detect/eject                                      boolean     true
d-i preseed/late_command in-target sed -i 's/PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/' 
/etc/ssh/sshd_config ; in-target wget 
https://gist.githubusercontent.com/goffinet/f515fb4c87f510d74165780cec78d62c/raw/7cf2c788c1c5600f7433d16f8f352c877a281a6a/ubuntu-grub-console.sh 
; in-target sh ubuntu-grub-console.sh ; in-target shutdown -h now
EOF

virt-install \
--virt-type kvm \
--name=$name \
--disk path=/var/lib/libvirt/images/$name.qcow2,size=8,format=qcow2 \
--ram=512 \
--vcpus=1 \
--os-variant=ubuntusaucy \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "auto=true hostname=$name domain= url=$url text console=ttyS0,115200n8 serial $autoconsole"
}

debian_install () {
local url=http://192.168.122.1/conf/debian8-preseed.cfg
local mirror=$debian_mirror

touch /var/www/html/conf/debian8-preseed.cfg
cat << EOF > /var/www/html/conf/debian8-preseed.cfg
d-i debian-installer/locale string en_US
d-i keyboard-configuration/xkb-keymap select be
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/wireless_wep string
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i passwd/make-user boolean false
d-i passwd/root-password password testtest
d-i passwd/root-password-again password testtest
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Paris
d-i clock-setup/ntp boolean true
d-i partman-auto/method string lvm
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server vim
d-i pkgsel/upgrade select full-upgrade
popularity-contest popularity-contest/participate boolean false
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string /dev/vda
d-i finish-install/keep-consoles boolean true
d-i finish-install/reboot_in_progress note
d-i preseed/late_command string in-target sed -i 's/PermitRootLogin\ without-password/PermitRootLogin\ 
yes/' /etc/ssh/sshd_config; in-target wget 
https://gist.githubusercontent.com/goffinet/f515fb4c87f510d74165780cec78d62c/raw/7cf2c788c1c5600f7433d16f8f352c877a281a6a/ubuntu-grub-console.sh 
; in-target sh ubuntu-grub-console.sh ; in-target shutdown -h now
EOF

virt-install \
--virt-type kvm \
--name=$name \
--disk path=/var/lib/libvirt/images/$name.qcow2,size=8,format=qcow2 \
--ram=512 \
--vcpus=1 \
--os-variant=debianwheezy \
--network bridge=virbr0 \
--graphics none \
--console pty,target_type=serial \
--location $mirror \
-x "auto=true hostname=$name domain= url=$url text console=ttyS0,115200n8 serial $autoconsole"
}

centos_install () {

local url=http://192.168.122.1/conf/centos7.ks
local mirror=$centos_mirror

read -r -d '' packages <<- EOM
@core
wget
EOM

touch /var/www/html/conf/centos7.ks
cat << EOF > /var/www/html/conf/centos7.ks
install
reboot
rootpw --plaintext testtest
keyboard --vckeymap=be-oss --xlayouts='be (oss)'
timezone Europe/Paris --isUtc
#timezone Europe/Brussels
lang en_US.UTF-8
#lang fr_BE
#cdrom
url --url="$mirror"
firewall --disabled
network --bootproto=dhcp --device=eth0
network --bootproto=dhcp --device=eth1
network --hostname=$name
# network --device=eth0 --bootproto=static --ip=192.168.22.10 --netmask 255.255.255.0 --gateway 
$bridgeip4 --nameserver=$bridgeip4 --ipv6 auto
#auth  --useshadow  --passalgo=sha512
text
firstboot --enable
skipx
ignoredisk --only-use=vda
bootloader --location=mbr --boot-drive=vda
zerombr
clearpart --all --initlabel
#autopart --type=thinp # See the bug resolved in 7.3 https://bugzilla.redhat.com/show_bug.cgi?id=1290755
autopart --type=lvm
#part /boot --fstype="xfs" --ondisk=vda --size=500
#part swap --recommended
#part pv.00 --fstype="lvmpv" --ondisk=vda --size=500 --grow
#volgroup local0 --pesize=4096 pv.00
#logvol /  --fstype="xfs"  --size=4000 --name=root --vgname=local0
%packages
$packages
%end
%post
yum -y update && yum -y upgrade
#mkdir /root/.ssh
#curl ${conf}/id_rsa.pub > /root/.ssh/authorized_keys
#sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
%end
EOF


virt-install \
--virt-type=kvm \
--name=$name \
--disk path=/var/lib/libvirt/images/$name.qcow2,size=8,format=qcow2 \
--ram=2048 \
--vcpus=1 \
--os-variant=rhel7 \
--network bridge=virbr0 \
--graphics none \
--noreboot \
--console pty,target_type=serial \
--location $mirror \
-x "auto=true hostname=$name domain= ks=$url text console=ttyS0,115200n8 serial $autoconsole"
}

start_install () {
if [ $image = centos ] ; then
 centos_install
elif [ $image = debian ] ; then
 debian_install
elif [ $image = ubuntu ] ; then
 ubuntu_install
else
 echo "Error : ./auto-install.sh [ centos | debian | ubuntu ] nom_de_vm"
 echo "Please provide one of those distributions"
 exit
fi
}

check_guest_name
check_apache
start_install
