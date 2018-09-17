#!/bin/bash

Status()
{
	zenity --info --text=$host" is "$(sudo virsh list --all | grep -i $host | awk '{print $3  $4}') --width 150 --height 100
}
Start()
{
	cd /var/lib/libvirt/images
	saved="$host-save"
	if [ -e $saved ]
        then
            sudo virsh restore $host-save
	    sudo rm -rf $host-save
	else
        status=$(sudo virsh list --all | grep -i $host | awk '{print $3  $4}')
	if [ $status == "shutoff" ]
	then
	    sudo virsh start $host
	    zenity --info --text=$host" is Started"
	else
	    zenity --info --text=$host" is "$status
	fi
        fi

}
Poweroff()
{
	status=$(sudo virsh list --all | grep -i $host | awk '{print $3 $4}')
	if [ $status == "running" ]
	then
		sudo virsh destroy $host
		zenity --info --text=$host" is Forced Stoped"
	else
		zenity --info --text=$host" is "$status
	fi
}
Stop()
{
        status=$(sudo virsh list --all | grep -i $host | awk '{print $3 $4}')
        if [ $status == "running" ]
        then
                sudo virsh Shutdown $host
                zenity --info --text=$host" is Stopped"
        else
                zenity --info --text=$host" is "$status
        fi
}

View()
{
	sudo virt-viewer $host
}

Create()
{
	vmdetail=$(zenity --forms --title="VM Details" --add-entry="VM Name" --add-entry="RAM" --add-entry="Disk Size" )
	iso=$(zenity --file-selection --title "Select ISO image")
	IFS="|" read -r vmname ram size <<< "$vmdetail"
	cd /var/lib/libvirt/images/
	sudo qemu-img create -f qcow2 $vmname.qcow2 "$size"G
	sudo virt-install -n $vmname -r $ram --os-type=linux --os-variant=generic --disk  path=/var/lib/libvirt/images/"$vmname".qcow2,device=disk,bus=virtio,size=$size,format=raw -w bridge=br0,model=virtio --vnc --noautoconsole -c $iso 
	sudo virt-viewer $vmname
}

Delete()
{
	zenity --question --text="Want to Delete "$host"?"
	case $? in 
		0)	
		sudo virsh undefine $host --remove-all-storage
		;;
		1)
		exit 1
		;;
 	esac
}
Save()
{
	zenity --question --text="Want to save "$host"?"
	case $? in
		0)
                status=$(sudo virsh list --all | grep -i $host | awk '{print $3  $4}')
		if [ $status == "running" ]
		then
	           cd /var/lib/libvirt/images
		   sudo virsh save $host $host-save
	        else
		   zenity --info --text=$host" is "$status
	         fi
		   ;;
		1)
			exit 1
			;;
	esac
}
host=$2
case $1 in
	"status") 
		Status
		;;
	"start")
                Start
		;;
	"stop")
	       Stop
	       ;;
       "poweroff")
		Poweroff
		;;
       "view")
	       View
	       ;;
       "create")
	       Create
	       ;;
       "delete")
	       Delete
	       ;;
       "save")
	       Save
	       ;;
esac
