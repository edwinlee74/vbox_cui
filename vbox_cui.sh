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
choice="/tmp/menu.choice.$$"
output='/tmp/result.output.$$'

# trap and delete temp file
trap "rm $choice; rm $output; exit" 0 1 2 5 15

# display main menu
function MainMenu() {
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

   dialog  --clear --backtitle "$backtitle" --title "$title" --menu \
        "$menu_title" $height $width $menu_height $menu_item1 $menu_item2 \
        $menu_item3 $menu_item4 $menu_item5 $menu_item6 2>"${choice}"
    
    mychoice=$(<"${choice}")
}


function Main() {
    while true
    do
      MainMenu
      
      case $mychoice in 
          6) echo "Bye"; break;;
      esac
    done
}

#---------------------------------------------------
Main