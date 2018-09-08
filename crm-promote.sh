#!/bin/bash
if [ -z $1 ]
then 
echo "Usage: crm-promote OBJECT"
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
wget -P /usr/local/src/crmpromote ftp://ftp.iface.io/CRM-PROMOTE.png 
chown -R $user:$group /usr/local/src/crmpromote
wget -P  $homedir/Desktop ftp://ftp.iface.io/Crm.desktop
chown -R $user:$group $homedir/Desktop/Crm.desktop
chmod +x $homedir/Desktop/Crm.desktop
sed -i "9i rm -rf /tmp/crm_done_task" /etc/init/shutdown.conf
fi
elif [ $1 == "start" ]
then
# resizes the window to full height and 50% width and moves into upper right corner

#define the height in px of the top system-bar:
TOPMARGIN=27

#sum in px of all horizontal borders:
RIGHTMARGIN=10

 #get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

 #new width and height
W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))
H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))
########################################################################################
exit1()
{
if [ $? == "1" ]
then
done_task=()
for i in {0..6}
do
done_task[$i]=${Status[$i]}
done
echo ${done_task[@]} > /tmp/crm_done_task
exit 1
fi
}
#################################################################################################
local_prod()
{
prod_local=$(zenity --list "Production" "Local" --column "Where want to run" 2> /dev/null)
exit1
}
#################################################################################################
dir_selection()
{
if [ ! -s "/usr/local/src/crmpromote/app_folder_status" ]
then
echo "Git_Pull:" >> /usr/local/src/crmpromote/app_folder_status
echo "Change_forntend_config:" >> /usr/local/src/crmpromote/app_folder_status
echo "Change_Backend_Config:" >> /usr/local/src/crmpromote/app_folder_status
echo "Client_Production_Build:" >> /usr/local/src/crmpromote/app_folder_status
echo "Change_Docker_Version:" >> /usr/local/src/crmpromote/app_folder_status
echo "Gulp_Build:" >> /usr/local/src/crmpromote/app_folder_status
echo "Git_Push:" >> /usr/local/src/crmpromote/app_folder_status
fi
}
#################################################################################################
Popup()
{
option=$( zenity --list --column "Select Process" --column "Status" --column "Directory" "Git_Pull" "${Status[0]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Git_Pull | cut -d ":" -f2)"  "Change_forntend_config" "${Status[1]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_forntend_config | cut -d ":" -f2)" "Change_Backend_Config" "${Status[2]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_Backend_Config | cut -d ":" -f2)"  "Client_Production_Build" "${Status[3]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Client_Production_Build | cut -d ":" -f2)" "Change_Docker_Version" "${Status[4]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_Docker_Version | cut -d ":" -f2)" "Gulp_Build" "${Status[5]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Gulp_Build | cut -d ":" -f2)" "Git_Push" "${Status[6]}" "$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Git_Push | cut -d ":" -f2)" "Settings" --width=$W --height=$H 2> /dev/null)
exit1
}
#################################################################################################
config_development()
{
dir_selection
dir1=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Change_forntend_config:"| cut -d ':' -f2  )
if [ -z $dir1 ]
then
dir11=$(zenity --title="Select path for Change_frontend_Config" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Change_forntend_config:|Change_forntend_config:$dir11|g" /usr/local/src/crmpromote/app_folder_status
cd $dir11
else
cd $dir1
fi

file1=$(zenity --file-selection --title="Select config.development.ts" 2> /dev/null)
exit1
config=$(echo $file1 | awk -F/ '{print $NF}')
if [ $config == "config.development.ts" ]
then
local_prod
if [ $prod_local == "Production" ]
then
sed -e "/apiUrl: 'http:/ s|^|//|" -e "/apiUrl: 'https:/ s|/.*.apiUrl|apiUrl|" -i $file1
gnome-terminal -x bash -ic "cat $file1 && sleep 5"
Status[1]="Done"
elif [ $prod_local == "Local" ]
then
sed -i -e "/apiUrl: 'http:/ s|/.*.apiUrl|apiUrl|" -e "/apiUrl: 'https:/ s|^|//|" $file1
gnome-terminal -x bash -ic "cat $file1 && sleep 5"
Status[1]="Done"
fi
else
zenity --title "Worng File Selected"  --error --text="Please Select config.development.ts File" 2> /dev/null
config_development
fi
}
##################################################################################################
server_js()
{
dir_selection
dir2=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Change_Backend_Config:"| cut -d ':' -f2  )
if [ -z $dir2 ]
then
dir21=$(zenity --title="Select path for Change_Backend_Config" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Change_Backend_Config:|Change_Backend_Config:$dir21|g" /usr/local/src/crmpromote/app_folder_status
cd $dir21
else
cd $dir2
fi
file2=$(zenity --file-selection --title="Select Sever.js" 2> /dev/null)
exit1
server=$(echo $file2 | awk -F/ '{print $NF}')
if [ $server == "server.js" ]
then
local_prod
if [ $prod_local == "Production" ]
then
sed -i "s|process.env.NODE_ENV = 'development'|process.env.NODE_ENV = 'production'|" $file2
gnome-terminal -x bash -ic "cat $file2 | grep -i process.env ; sleep 5"
Status[2]="Done"
elif [ $prod_local == "Local" ]
then
sed -i "s|process.env.NODE_ENV = 'production'|process.env.NODE_ENV = 'development'|" $file2
gnome-terminal -x bash -ic "cat $file2 | grep -i process.env ; sleep 5"
Status[2]="Done"
fi
else 
zenity --title "Worng File Selected"  --error --text="Please Select server.js File" 2> /dev/null
server_js
fi
}
##################################################################################################
Production_build()
{
dir_selection
dir3=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Client_Production_Build:"| cut -d ':' -f2  )
if [ -z $dir3 ]
then
dir31=$(zenity --title="Select path for Client_Production_Build" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Client_Production_Build:|Client_Production_Build:$dir31|g" /usr/local/src/crmpromote/app_folder_status
cd $dir21
else
cd $dir3
fi
gnome-terminal -x bash -ic 'node --max_old_space_size=12288 ./node_modules/@angular/cli/bin/ng build --prod ; sleep 86400'
Status[3]="Done"
}
##################################################################################################
app_yaml()
{
dir_selection
dir4=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Change_Docker_Version:"| cut -d ':' -f2  )
if [ -z $dir4 ]
then
dir41=$(zenity --title="Select path for Change_Docker_Version" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Change_Docker_Version:|Change_Docker_Version:$dir41|g" /usr/local/src/crmpromote/app_folder_status
cd $dir41
else
cd $dir4
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
Status[4]="Not_Done"
else
sed -i "s|index.docker.io/itsolvs/iface-crm-app:$version|index.docker.io/itsolvs/iface-crm-app:$new_version|" $file3
gnome-terminal -x bash -ic "cat $file3 | grep -i index.docker.io ; sleep 10"
Status[4]="Done"
fi
fi
}
##########################################################################################################
gulp_build()
{
dir_selection
dir5=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Gulp_Build:"| cut -d ':' -f2  )
if [ -z $dir5 ]
then
dir51=$(zenity --title="Select path for Gulp_Build" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Gulp_Build:|Gulp_Build:$dir51|g" /usr/local/src/crmpromote/app_folder_status
cd $dir51
else
cd $dir5
fi
gnome-terminal -x bash -ic 'gulp build ; sleep 86400'
Status[5]="Done"
}
##########################################################################################################
git_push()
{
if [ -z $dir5 ]
then
dir6=$(zenity --file-selection --directory --title="Directory For Git Push" 2> /dev/null)
exit1
dir61=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Git_Push | cut -d ":" -f2)
sed -i "s|Git_Push:$dir61|Git_Push:$dir6|g" /usr/local/src/crmpromote/app_folder_status
cd $dir6
else
cd $dir5
fi
git_in=$(zenity --forms --title="Git Push" --add-entry="Comment For Commit" --add-entry="Branch Name" 2> /dev/null)
exit1
IFS="|" read -r comment branch  <<< "$git_in"
git add .
git commit -m "$comment"
cred_type=$(zenity --list "BY_SSH" "BY_Credentials" --column "Select Method" 2> /dev/null)
exit1
if [ $cred_type == "BY_SSH" ]
then
gnome-terminal -x bash -ic "git push origin $branch; sleep 86400"
Status[6]="Done"
elif [ $cred_type == "BY_Credentials" ]
then
user=$(zenity --password --username 2> /dev/null)
IFS="|" read -r username password   <<< "$user";
if [[ -z $username  ]] || [[ -z $password ]]
then
zenity --error --text="Please Enter Username and Password" 2> /dev/null
else
gnome-terminal -x bash -ic "git push https://$username:$password@github.com/iface1/dev-iface-crm.git $branch; sleep 86400" 
Status[6]="Done"
fi
fi
}
##########################################################################################################
git_pull()
{
dir_selection
dir7=$(cat /usr/local/src/crmpromote/app_folder_status | grep "Git_Pull:"| cut -d ':' -f2  )
if [ -z $dir7 ]
then
dir71=$(zenity --title="Select path for Git_Pull" --file-selection --directory 2> /dev/null)
exit1
sed -i "s|Git_Pull:|Git_Pull:$dir71|g" /usr/local/src/crmpromote/app_folder_status
cd $dir71
else
cd $dir7
fi
pull_branch=$(zenity --forms --title="Git Pull" --add-entry="Branch Name" 2> /dev/null)
exit1
gnome-terminal -x bash -ic "git pull origin $pull_branch; sleep 86400"
Status[0]="Done"
}
##########################################################################################################
settings()
{
selc_dir=$(zenity --list --title "Settings" --text "Select field for change default Directory" --column "Select" "Git_Pull" "Change_forntend_config" "Change_Backend_Config" "Client_Production_Build" "Change_Docker_Version" "Gulp_Build" --width $W --height $H 2> /dev/null)
exit1
if [ $selc_dir == "Git_Pull" ]
then
Pull_dir=$(zenity --file-selection --directory --title "Git_Pull Default Directory" 2> /dev/null)
exit1
dir42=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Git_pull| cut -d ":" -f2)

sed -i "s|Git_Pull:$dir42|Git_Pull:$Pull_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
if [ $selc_dir == "Change_forntend_config" ]
then
fornt_dir=$(zenity --file-selection --directory --title "Change_forntend_config Default Directory" 2> /dev/null)
exit1 
dir43=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_forntend_config| cut -d ":" -f2)
sed -i "s|Git_Pull:$dir43|Git_Pull:$front_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
if [ $selc_dir == "Change_Backend_Config" ]
then
backend_dir=$(zenity --file-selection --directory --title "Git_Pull Default Directory" 2> /dev/null)
exit1
dir44=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_Backend_Config| cut -d ":" -f2)
sed -i "s|Change_Backend_Config:$dir44|Change_Backend_Config:$backend_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
if [ $selc_dir == "Client_Production_Build" ]
then
prod_dir=$(zenity --file-selection --directory --title "Client_Production_Build Default Directory" 2> /dev/null)
exit1 
dir45=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Client_Production_Build | cut -d ":" -f2)
sed -i "s|Client_Production_Build:$dir45|Client_Production_Build:$prod_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
if [ $selc_dir == "Change_Docker_Version" ]
then
docker_dir=$(zenity --file-selection --directory --title "Change_Docker_Version Default Directory" 2> /dev/null)
exit1
dir46=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Change_Docker_Version| cut -d ":" -f2)
sed -i "s|Change_Docker_Version:$dir46|Change_Docker_Version:$docker_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
if [ $selc_dir == "Gulp_Build" ]
then
gulp_dir=$(zenity --file-selection --directory --title "Gulp_Build Default Directory" 2> /dev/null)
exit1
dir47=$(cat /usr/local/src/crmpromote/app_folder_status | grep -i Gulp_Build| cut -d ":" -f2)
sed -i "s|Change_Docker_Version:$dir47|Change_Docker_Version:$gulp_dir|g" /usr/local/src/crmpromote/app_folder_status
fi
}
##########################################################################################################
all_done()
{
Done=()
for i in {0..6}
do
Done[$i]=Done
done
diff=$(diff <(printf "%s\n" "${Status[@]}") <(printf "%s\n" "${Done[@]}"))
if [[ -z "$diff" ]]
then
Status=(Not_Done Not_Done Not_Done Not_Done Not_Done Not_Done Not_Done)
fi
}

##########################################################################################################
check_done_task()
{
if [ -s "/tmp/crm_done_task" ]
then
i=0
Status=()
for x in $(cat /tmp/crm_done_task)
do
Status[$i]=$x
i=`expr $i + 1`
done
else
Status=(Not_Done Not_Done Not_Done Not_Done Not_Done Not_Done Not_Done)
fi
}
###########################################################################################################
dir_selection
check_done_task
all_done
while [ $? == "0" ]
do
Popup
exit1
##########################
if [ $option == "Change_forntend_config" ]
then
if [ ${Status[1]} == "Done" ]
then 
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      config_development ;;
esac
else
config_development
fi
fi
###########
if [ $option == "Change_Backend_Config" ]
then
if [ ${Status[2]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      server_js ;;
esac
else
server_js
fi
fi
##########
if [ $option == "Client_Production_Build" ]
then
if [ ${Status[3]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      Production_build ;;
esac
else
Production_build
fi
fi
##########
if [ $option == "Change_Docker_Version" ]
then
if [ ${Status[4]} == "Done" ]
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
#########
if [ $option == "Settings" ]
then 
settings
fi
#########
if [ $option == "Gulp_Build" ]
then
if [ ${Status[5]} == "Done" ]
then
zenity --question --text="Are you sure want to edit again?" --title="Aready Done!" --ok-label="Yes" --cancel-label="No" 2> /dev/null
case $? in
    "1")
      Popup ;;
    "0")
      gulp_build ;;
esac
else
gulp_build
fi
fi
#########
if [ $option == "Git_Push" ]
then
if [ ${Status[6]} == "Done" ]
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
rm -rf crmpromote
rm -rf $homedir/Desktop/Crm.desktop
sed -i "9 s|rm -rf /tmp/crm_done_task| |" /etc/init/shutdown.conf
dpkg -P crm-promote
fi
else
echo "Usage: crm-promote OBJECT"
echo "where  OBJECT := { install | start | uninstall }"
echo "install: For install desktop icon"
echo "start: Use app by CLI"
echo "uninstall: For uninstall app"
fi
