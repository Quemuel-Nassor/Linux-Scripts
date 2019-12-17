#!/bin/bash
echo -e "\n\n\n\t\t\tArch Linux installer script\n\n\n"
echo -e "Select an keyboard layout\n1 - english-US(default)\n2 - portuguese-BR:\n"
read layout
if [ $layout = $2 ]
    loadkeys br-abnt2
fi
echo -e "\n\nUpdate system clock"
timedatectl set-ntp true
echo -e "\n\nChecking timedatectl status"
timedatectl status
echo -e "\n\nUpdate system and sorts the mirrorlist"
(echo Y) | pacman -Syyu
main(){    
    echo -e "\n\nSelect an option:\n"
    echo -e "1 - Create partitions in disks"
    echo -e "2 - Delete partitions in disks"
    echo -e "3 - Mount partitions"
    echo -e "4 - Install base packages"
    echo -e "5 - Exit\n"
    read option        
    case $option in
        "1")
         disk_create_partition
         ;;
        "2")
         disk_remove_partition
         ;;
        "3")
         prepare_partition
         ;;
        "4")
         install_base
         ;;
        "5")
         exit
         ;;
    esac    
    main
}
disk_create_partition(){
    echo -e "\n\nInform the disk for installation:(ex: /dev/sdx)"
    read disk

    echo -e "\n\nPreparing BOOT partition"
    (echo n; echo 1; echo ; echo +512M; echo t; echo 1; echo w) | fdisk $disk
    mkfs.fat -F32 -n BOOT $disk"1"

    echo -e "\n\nPreparing ROOT partition"
    (echo n; echo 2; echo ; echo +30G; echo t; echo 2; echo 24; echo w) | fdisk $disk
    mkfs.ext4 -L ROOT $disk"2"

    echo -e "\n\nPreparing HOME partition"
    (echo n; echo 3; echo ; echo +30G; echo t; echo 3; echo 28; echo w) | fdisk $disk
    mkfs.ext4 -L HOME $disk"3"

    echo -e "\n\nPreparing SWAP partition"
    (echo n; echo 4; echo ; echo +8G; echo t; echo 4; echo 19; echo w) | fdisk $disk
    mkswap -L SWAP $disk"4"

    echo -e "\n\nSuccessfully created partitions on $disk"
    (echo p) | fdisk $disk
}
disk_remove_partition (){  
    echo -e "\n\nInform the disk to remove partitions:(ex: /dev/sdx)"
    read disk       
    echo -e "\n\nRemoving partition from $disk"
    (echo d; echo ; echo w) | fdisk $disk
}
prepare_partition (){
    echo -e "\n\nCreating directory and mounting BOOT"
    mkdir -p /mnt/boot/efi && mount $disk"1" /mnt/boot/efi

    echo -e "\n\nCreating directory and mounting ROOT"
    mkdir /mnt && mount $disk"2" /mnt

    echo -e "\n\nCreating directory and mounting HOME"
    mkdir /mnt/home && mount $disk"3" /mnt/home

    echo -e "\n\nMounting SWAP"
    swapon $disk"4"

    echo -e "\n\nSuccessfully created and assembled directories"
    lsblk
}
install_base(){
	echo -e "\n\nInstalling base packages"
	pacstrap -i /mnt base base-devel linux linux-firmware
	
	echo -e "\n\nAdd mounted disks on FSTAB file"
	genfstab -U -p /mnt >> /mnt/etc/fstab
	cat /mnt/etc/fstab
	
	echo -e "\n\nEntering new system and instaling base packages"
	arch-chroot /mnt
	pacman -S grub-efi-x86_64 efibootmgr os-prober ntfs-3g intel-ucode alsa-utils pulseaudio pulseaudio-alsa xorg-server xorg-xinit mesa xf86-video-intel net-tools networkmanager wireless_tools screenfetch vlc p7zip firefox noto-fonts
	
	
		    
}
main