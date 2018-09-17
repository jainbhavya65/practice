#!/bin/bash
exit1()
{
if [ $? == "1" ]
then
exit 1
fi
}
opration=$(zenity --list --radiolist --width 500 --height 500 --column "" --column "Operation" --column "Description" \
          		TRUE  'status'    'Display the current state of a VM' \
			FALSE 'create'    'Create VM' \
			FALSE 'view'      'Connect to the graphical console of a VM' \
                        FALSE 'start'     'Start a VM' \
                        FALSE 'reset'     'Reset a VM to its last saved state' \
                        FALSE 'stop'      'Gracefully stop a VM' \
                        FALSE 'poweroff'  'Forcefully shutdown a VM' \
                        FALSE 'fullreset' 'Reset a VM to its original state' \
                        FALSE 'save'      'Save the state of a VM' \
                        FALSE 'reboot'    'Reboot a VM' \
			FALSE 'resume'    'Resumes a paused guest.' \
                        FALSE 'suspend'   'Pauses a guestVM. ' \
                        FALSE 'delete'    'Delete a guestVM. '
				)
exit1
case $? in
	0)
		if [ $opration != "create" ]
		then
		host=$(
			for host in $(sudo virsh list --all | awk '{print $2}' | tail -n +2)
			do
				host_list="$host_list FALSE $host"
			done
			zenity --list --radiolist --title "Select Virtual Machine" --width 500 --height 500 --column "" --column "Host" \
				--hide-header $host_list
			exit1
		) 
	       fi	
	    case $? in
		    0) 
			    ./virsh.sh $opration $host

	    esac
	    ;;
esac
