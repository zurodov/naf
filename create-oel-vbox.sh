#!/bin/bash
#
# install type: dvd,tftp
# arch: 32,64
# ram:2G,4G
# release: 5.X,6.X
# netconfig: bridged,nat
# oracle: 10g,11g

# default: dvd,64,4G,5.9,bridged,11g

[ $# -eq 0 ] && { echo "Не заданы параметры!!! Пример: $0 dvd 32 2G 5.10 10G"; exit 1; }

vm=ora11
vmstore=.VirtualBox/Machines
inst=/mnt/inst/oel/oel510_64dvd.iso
flop=/mnt/inst/oel/oel510fdd.img
cd ~

VBoxManage createvm --name "$vm" --register --ostype Oracle_64
VBoxManage modifyvm "$vm" --memory "4096" --vram 16 --acpi on --rtcuseutc on --boot1 dvd --nic1 bridged --macaddress1 bc5ff45b8eac --bridgeadapter1 eth0
VBoxManage createhd --filename "$vmstore/$vm/${vm}_root.vdi" --size 65000
VBoxManage createhd --filename "$vmstore/$vm/${vm}_flash.vdi" --size 10000
VBoxManage storagectl "$vm" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storagectl "$vm" --name "SAS Controller" --add sas --controller LSILogicSAS
VBoxManage storagectl "$vm" --name "Floppy Controller" --add floppy --controller I82078

VBoxManage storageattach "$vm" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $inst
### emptydrive
VBoxManage storageattach "$vm" --storagectl "Floppy Controller" --port 0 --device 0 --type fdd --medium $flop

VBoxManage storageattach "$vm" --storagectl "SAS Controller" --port 0 --device 0 --type hdd --medium "$vmstore/$vm/${vm}_root.vdi"
VBoxManage storageattach "$vm" --storagectl "SAS Controller" --port 1 --device 0 --type hdd --medium "$vmstore/$vm/${vm}_flash.vdi"

echo ""
echo ""
VBoxManage startvm $vm
echo ""
echo "linux ks=floppy"
echo "mount /dev/cdrom /mnt/inst"
echo "mcedit /etc/sysctl.conf"
echo "ssh -XY oracle@ora11"

cat orainst.lst

