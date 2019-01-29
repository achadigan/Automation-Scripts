#!/bin/bash
# Outdated !
#Get latest iso of Centos 7, Debian Jessie and Ubuntu Xenial.
os=$1
parameters="$#"
location=/var/lib/iso
url_ubuntu_iso=http://releases.ubuntu.com/16.04/ubuntu-16.04.2-server-amd64.iso
url_debian_iso=http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-8.7.1-amd64-netinst.iso
url_centos_iso=http://ftp.belnet.be/ftp.centos.org/7/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso

check_parameters () {
if [ "$parameters" -ne 1 ] ; then
echo "Get latest iso of Centos 7, Debian Jessie and Ubuntu Xenial."
echo "$location is the destination directory"
echo "Usage : $0 [ centos | debian | ubuntu ]"
exit
fi
}

fix_url () {
if [ "$os" = "centos" ] ; then
url=$url_centos_iso
elif [ "$os" = "debian" ] ; then
url=$url_debian_iso
elif [ "$os" = "ubuntu" ] ; then
url=$url_ubuntu_iso
else
echo "Get latest iso of Centos 7, Debian Jessie and Ubuntu Xenial."
echo "$location is the destination directory"
echo "Usage : $0 [ centos | debian | ubuntu ]"
exit
fi
}

validation () {
echo "Do you want download ${url##*\/}"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        get_iso
        ;;
    *)
        exit
        ;;
esac
}

get_iso () {
mkdir -p $location
cd $location
wget $url
}

check_parameters
fix_url
validation
