#!/bin/bash
if [ -z $1 ]
then
echo "Usage: crm-api-promote OBJECT/usr/local/src/usr/local/src"
echo "where  OBJECT := { install | start | uninstall }"
echo "install: For install desktop icon"
echo "start: Use app by CLI"
echo "uninstall: For uninstall app"
elif [ $1 == "install" ]
then
if [ $(whoami) != "root" ]
then
echo " ____  __    ____   __   ____  ____        ____  _  _  __ _         __   ____        ____   __    __   ____ 
(  _ \(  )  (  __) / _\ / ___)(  __)      (  _ \/ )( \(  ( \       / _\ / ___)      (  _ \ /  \  /  \ (_  _)
 ) __// (_/\ ) _) /    \\___ \ ) _)         )   /) \/ (/    /      /    \\___ \        )   /(  O )(  O )  )(  
(__)  \____/(____)\_/\_/(____/(____)      (__\_)\____/\_)__)      \_/\_/(____/      (__\_) \__/  \__/  (__) "
else
user=$(who|awk '{print $1}')
homedir=$(cat /etc/passwd | grep -i $user | cut -d ":" -f6)
user1=$(echo $homedir | awk -F/ "{print $3}")
group=$(cat /etc/group | grep -i $user1 | awk -F: {"print $1"})
wget -P /usr/local/src/crmapipromote ftp://ftp.iface.io/API-promote.png
chown -R $user:$group /usr/local/src/crmapipromote
wget -P  $homedir/Desktop ftp://ftp.iface.io/Api.desktop
chown -R $user:$group $homedir/Desktop/Api.desktop
chmod +x $homedir/Desktop/Api.desktop
sed -i "9i rm -rf /tmp/api_done_task" /etc/init/shutdown.conf
fi
elif [ $1 == "start" ]
then
# resizes the window to full height and 50% width and moves into upper right corner

#define the height in px of the top system-bar:
TOPMARGIN=27

#sum in px of all horizontal borders:
RIGHTMARGIN=10

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# new width and height
W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))
H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))
#########################################################################################
exit1()
{
if [ $? == "1" ]
then
echo ${Status[@]} > /tmp/api_done_task
exit 1
fi
}
##################################################################################################
local_prod()
{
prod_local=$(zenity --list "Production" "Local" --column "Where want to run" 2> /dev/null)
exit1
}
##################################################################################################
Popup()
{
option=$( zenity --list --column "Select Process" --column "Status" --column "Diectory"  "Git_Pull" "${Status[0]}" "$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Git_Pull | cut -d ":" -f2)"  "Change_Backend_Config" "${Status[1]}" "$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Change_Backend_Config |  cut -d ":" -f2)" "Change_Docker_Version" "${Status[2]}" "$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Change_Docker_Version |  cut -d ":" -f2)"  "Git_Push" "${Status[3]}" "$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Git_Push |  cut -d ":" -f2)" "Settings" --width=$W --height=$H 2> /dev/null)
exit1
}
##################################################################################################
dir_selection()
{
if [ ! -s "/usr/local/src/crmapipromote/api_folder_status" ]
then
echo "Git_Pull:" >> /usr/local/src/crmapipromote/api_folder_status
echo "Change_Backend_Config:" >> /usr/local/src/crmapipromote/api_folder_status
echo "Change_Docker_Version:" >> /usr/local/src/crmapipromote/api_folder_status
echo "Git_Push:" >> /usr/local/src/crmapipromote/api_folder_status
fi
}
##################################################################################################
app_js()
{
dir_selection
dir1=$(cat /usr/local/src/crmapipromote/api_folder_status | grep "Change_Backend_Config:"| cut -d ':' -f2  )
if [ -z $dir1 ]
then
dir11=$(zenity --title="Select path for Change_Backend_Config" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Change_Backend_Config:|Change_Backend_Config:$dir11|g" /usr/local/src/crmapipromote/api_folder_status
cd $dir11
else
cd $dir1
fi
file2=$(zenity --file-selection --title="Select app.js" 2> /dev/null)
exit1
server=$(echo $file2 | awk -F/ '{print $NF}')
if [ $server == "app.js" ]
then
local_prod
if [ $prod_local == "Production" ]
then
sed -i "s|process.env.NODE_ENV = 'development'|process.env.NODE_ENV = 'production'|" $file2
gnome-terminal -x bash -c "cat server.js | grep -i process.env && sleep 1"
Status[1]="Done"
elif [ $prod_local == "Local" ]
then
sed -i "s|process.env.NODE_ENV = 'production'|process.env.NODE_ENV = 'development'|" $file2
gnome-terminal -x bash -c "cat $file2 | grep -i process.env && sleep 1"
Status[1]="Done"
fi
else
zenity --title "Worng File Selected"  --error --text="Please Select app.js File" 2> /dev/null
app_js
fi
}
################################################################################################
app_yaml()
{
dir_selection
dir2=$(cat /usr/local/src/crmapipromote/api_folder_status | grep "Change_Docker_Version:"| cut -d ':' -f2  )
if [ -z $dir2 ]
then
dir21=$(zenity --title="Select path for Change_Docker_Version" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Change_Docker_Version:|Change_Docker_Version:$dir21|g" /usr/local/src/crmapipromote/api_folder_status
cd $dir21
else
cd $dir2
fi
file3=$(zenity --file-selection --title="Select app.yaml" 2> /dev/null)
exit1
app=$(echo $file3 | awk -F/ '{print $NF}')
if [ $app == "app.yaml" ]
then
version=$(cat $file3 | grep -i image: | awk -F: {'print $3'})
new_version=$(zenity --entry --title="Version Intake" --text="Current Version: "$version 2> /dev/null )
if [ $version == "$new_version" ]
then
zenity --error --text="Same version Please change version" 2> /dev/null
Status[2]="Not_Done"
else
sed -i "s|index.docker.io/itsolvs/bloomer-app:$version|index.docker.io/itsolvs/bloomer-app:$new_version|" $file3
gnome-terminal -x bash -c "cat app.yaml | grep -i index.docker.io ; sleep 1000"
Status[2]="Done"
fi
fi
}
################################################################################################################
git_push()
{
dir_selection
dir3=$(cat /usr/local/src/crmapipromote/api_folder_status | grep "Git_Push:"| cut -d ':' -f2  )
if [ -z $dir3 ]
then
dir31=$(zenity --title="Select path for Git_Push" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Git_Push:|Git_Push:$dir31|g" /usr/local/src/crmapipromote/api_folder_status
cd $dir31
else
cd $dir3
fi
git_in=$(zenity --forms --title="Git" --add-entry="Comment For Commit" --add-entry="Branch Name" 2> /dev/null)
exit1
IFS="|" read -r comment branch  <<< "$git_in"
git add .
git commit -m "$comment"
cred_type=$(zenity --list "BY_SSH" "BY_Credentials" --column "Select Method" 2> /dev/null)
exit1
if [ $cred_type == "BY_SSH" ]
then
gnome-terminal -x bash -c 'git push origin $branch ; sleep 1000'
Status[3]="Done"
elif [ $cred_type == "BY_Credentials" ]
then
user=$(zenity --password --username 2> /dev/null)
IFS="|" read -r username password   <<< "$user";
if [[ -z $username  ]] || [[ -z $password ]]
then
zenity --error --text="Please Enter Username and Password" 2> /dev/null
else
gnome-terminal -x bash -c 'git push https://$username:$password@github.com/iface1/iface-crm-api.git $branch ; sleep 1000'
Status[3]="Done"
fi
fi
}
#############################################################################################################
git_pull()
{
dir_selection
dir4=$(cat /usr/local/src/crmapipromote/api_folder_status | grep "Git_Pull:"| cut -d ':' -f2  )
if [ -z $dir4 ]
then
dir41=$(zenity --title="Select path for Git_Pull" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Git_Pull:|Git_Pull:$dir41|g" /usr/local/src/crmapipromote/api_folder_status
cd $dir41
else
cd $dir4
fi
pull_branch=$(zenity --forms --title="Git Pull" --add-entry="Branch Name" 2> /dev/null)
exit1
gnome-terminal -x bash -c 'git pull origin $pull_branch ; sleep 1000'
Status[0]="Done"
}
#############################################################################################################
settings()
{
selc_dir=$(zenity --list --title "Settings" --column "Select feild for change default Directory" "Git_Pull" "Change_Backend_Config" "Change_Docker_Version" "Git_Push" 2> /dev/null)
if [ $selc_dir == "Git_Pull" ]
then
Pull_dir=$(zenity --file-selection --directory --title "Git_Pull Default Directory" 2> /dev/null)
dir42=$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Git_pull| cut -d ":" -f2) 
exit1
sed -i "s|Git_Pull:$dir42|Git_Pull:$Pull_dir|g" /usr/local/src/crmapipromote/api_folder_status
fi
if [ $selc_dir == "Change_Backend_Config" ]
then
backend_dir=$(zenity --file-selection --directory --title "Git_Pull Default Directory" 2> /dev/null)
dir44=$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Change_Backend_Config| cut -d ":" -f2)
exit1
sed -i "s|Change_Backend_Config:$dir44|Change_Backend_Config:$backend_dir|g" /usr/local/src/crmapipromote/api_folder_status
fi
if [ $selc_dir == "Change_Docker_Version" ]
then
docker_dir=$(zenity --file-selection --directory --title "Change_Docker_Version Default Directory" 2> /dev/null)
dir46=$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Change_Docker_Version| cut -d ":" -f2)
exit1
sed -i "s|Change_Docker_Version:$dir46|Change_Docker_Version:$docker_dir|g" /usr/local/src/crmapipromote/api_folder_status
fi
if [ $selc_dir == "Git_Push" ]
then
push_dir=$(zenity --file-selection --directory --title "Git_Push Default Directory" 2> /dev/null)
dir48=$(cat /usr/local/src/crmapipromote/api_folder_status | grep -i Git_Push| cut -d ":" -f2)
exit1
sed -i "s|Git_Push:$dir48|Git_Push:$push_dir|g" /usr/local/src/crmapipromote/api_folder_status
fi
}

#############################################################################################################
all_done()
{
Done=()
for i in {0..3}
do
Done[$i]=Done
done
diff=$(diff <(printf "%s\n" "${Status[@]}") <(printf "%s\n" "${Done[@]}"))
if [[ -z "$diff" ]]
then
Status=(Not_Done Not_Done Not_Done Not_Done)
fi
}
#############################################################################################################
check_done_task()
{
if [ -s "/tmp/api_done_task" ]
then
i=0
Status=()
for x in $(cat /tmp/api_done_task)
do
Status[$i]=$x
i=`expr $i + 1`
done
else
Status=(Not_Done Not_Done Not_Done Not_Done)
fi
}
#############################################################################################################
dir_selection
check_done_task
all_done
while [ $? == "0" ]
do
Popup
exit1
############
if [ $option == "Change_Backend_Config" ]
then
if [ ${Status[1]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
exit1
case $? in
    "1")
      Popup ;;
    "0")
      app_js ;;
esac
else
app_js
fi
fi
###########
if [ $option == "Change_Docker_Version" ]
then
if [ ${Status[2]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      app_yaml;;
esac
else
app_yaml
fi
fi
##########
if [ $option == "Settings" ]
then 
settings
fi
##########
if [ $option == "Git_Pull" ] || [ $option == "Git_Push" ] 
then
if [ $option == "Git_Push" ]
then
if [ ${Status[3]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      git_push ;;
esac
else
git_push
fi
elif [ $option == "Git_Pull" ]
then
if [ ${Status[0]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      git_pull ;;
esac
else
git_pull
fi
fi
fi
done
elif [ $1 == "uninstall" ]
then
if [ $(whoami) != "root" ]
then
echo " ____  __    ____   __   ____  ____        ____  _  _  __ _         __   ____        ____   __    __   ____ 
(  _ \(  )  (  __) / _\ / ___)(  __)      (  _ \/ )( \(  ( \       / _\ / ___)      (  _ \ /  \  /  \ (_  _)
 ) __// (_/\ ) _) /    \\___ \ ) _)         )   /) \/ (/    /      /    \\___ \        )   /(  O )(  O )  )(  
(__)  \____/(____)\_/\_/(____/(____)      (__\_)\____/\_)__)      \_/\_/(____/      (__\_) \__/  \__/  (__) "
else
user=$(who|awk '{print $1}')
homedir=$(cat /etc/passwd | grep -i $user | cut -d ":" -f6)
cd /usr/local/src
rm -rf crmapipromote
rm -rf $homedir/Desktop/Api.desktop
sed -i "9 s|rm -rf /tmp/crm_done_task| |" /etc/init/shutdown.conf
dpkg -P crm-api-promote
fi
else
echo "Usage: crm-api-promote OBJECT"
echo "where  OBJECT := { install | start | uninstall }"
echo "install: For install desktop icon"
echo "start: Use app by CLI"
echo "uninstall: For uninstall app"
fi

