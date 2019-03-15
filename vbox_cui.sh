#!/usr/bin/env bash
: '
When you use virtualbox without desktop environment,
maybe a pure command-line is not easy to manage or start
a virtual machine. 
This script provides a user interface for virtualbox so that
easy to use.

Author: Edwin Lee
License: MIT
Version: 19.03.01 (Calendar Versioning)
'
: ${backtitle="VirtualBox Command-line User Interface"}

os_list=(`VBoxManage list ostypes | grep "^ID:" | tr -d "ID:"`)
for(( i=0; i<${#os_list[@]}; i++ ))
   do
     item=$i' '${os_list[i]}' off ' 
     item_list=$item_list' '$item
done

# trap and delete temp file
#trap "rm $choice; rm $output; exit" 0 1 2 5 15

function RadioList() {
    local height=20
    local width=50
    local radiolist_height=10
    exec 3>&1
    rl_choice=$(dialog --clear --radiolist "$1" $height $width \
     $radiolist_height $2 2>&1 1>&3)
    exec 3>&-
}

function FileSelect() {
    FILE=$(dialog --stdout --title "$1" --fselect $HOME/ 14 48)
}

function CreateVM() {
       # select an OS type
       RadioList "Select OS type: " "$item_list"
       
       vmname=""
       cpus=""
       memory=""
       harddisk=""
       local title="VM creation"

       exec 3>&1

       VALUES=$(dialog --ok-label "Submit" \
          --title "$title" \
          --form "Input VM info" \
       15 50 0 \
        "VMname:" 1 1   "$vmname"       1 12 10 0 \
        "CPUs:"    2 1  "$cpus"         2 12 15 0 \
        "Memory(MB):"  3 1 "$memory"    3 12 8 0 \
        "H.D(MB):"  4 1 "$harddisk"    4 12 8 0 \
       2>&1 1>&3)

       exec 3>&-

       FileSelect "Please choose ISO source:"

       vmname=`echo "$VALUES" | sed -n 1p`
       cpus=`echo "$VALUES" | sed -n 2p`
       memory=`echo "$VALUES" | sed -n 3p`
       harddisk=`echo "$VALUES" | sed -n 4p`
       ostype=`echo ${os_list[rl_choice]}`
       mediapath=`echo $FILE`
       nic1=`ifconfig | grep "flags" | grep -v "lo:" | \
             awk '{print $1}' | tr -d ':'`
       
       # beging to create virtualbox VM
       VBoxManage createvm --name $vmname --ostype "$ostype" --register
       VBoxManage createhd --filename ~/VirtualBox\ VMs/$vmname/$vmname.vdi \
       --size $harddisk
       VBoxManage storagectl $vmname --name "SATA Controller" --add sata \
       --controller IntelAHCI
       VBoxManage storageattach $vmname --storagectl "SATA Controller" --port 0 \
       --device 0 --type hdd --medium ~/VirtualBox\ VMs/$vmname/$vmname.vdi
       VBoxManage storagectl $vmname --name "IDE Controller" --add ide
       VBoxManage storageattach $vmname --storagectl "IDE Controller" --port 0 \
       --device 0 --type dvddrive --medium $mediapath
       VBoxManage modifyvm $vmname --ioapic on
       VBoxManage modifyvm $vmname --boot1 dvd --boot2 disk --boot3 none \
       --boot4 none
       VBoxManage modifyvm $vmname --memory $memory --vram 128
       VBoxManage modifyvm $vmname --nic1 bridged --bridgeadapter1 $nic1

}

function ListVM() {
      true
}

function ConfigVM() {
      true
}

function SnapshotVM() {
      true
}

function StartVM() {
     get_vm_list=(`VBoxManage list vms | awk '{print $1}'`)
     vm_item=""
     vm_list=""
     for(( i=0; i<${#get_vm_list[@]}; i++ ))
       do
          vm_item=$i' '${get_vm_list[i]}' off ' 
          vm_list=$vm_list' '$vm_item
     done 
     echo $vm_list > /tmp/list
     RadioList "Select a VM to start:" "$vm_list"

     vm_choice=`echo ${get_vm_list[$rl_choice]} | tr -d '"'`
     (VBoxHeadless -s ${vm_choice} -v on -e "TCP/Ports=2034" &) | echo -ne "\n"
     
}

# display main menu
function MainMenu() {
    mychoice=""
    local title="[VirtualBox task menu]"
    local menu_title="Choose one:"
    local height=20
    local width=50
    local menu_height=6
    local menu_item1="1 建立虛擬機器"
    local menu_item2="2 虛擬機器清單"
    local menu_item3="3 虛擬機器配置"
    local menu_item4="4 虛擬機器快照"
    local menu_item5="5 啟動虛擬機器"
    local menu_item6="6 離開"
    
   exec 3>&1 
   mychoice=$(dialog  --clear --backtitle "$backtitle" --title "$title" --menu \
        "$menu_title" $height $width $menu_height $menu_item1 $menu_item2 \
        $menu_item3 $menu_item4 $menu_item5 $menu_item6 2>&1 1>&3)
   exec 3>&-
}




function Main() {
    while true
    do
      MainMenu
      
      case $mychoice in 
          1) CreateVM;;
          2) true;;
          3) true;;
          4) true;;
          5) StartVM;;
          6) echo "Have a nice day!"; break;;
      esac
    done
}

#---------------------------------------------------
Main
