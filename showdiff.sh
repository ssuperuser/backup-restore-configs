#!/bin/bash
bold=$(tput bold setaf 5)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
magenta=$(tput setaf 5)
read_var() {
  if [ -z "$1" ]; then
    echo "environment variable name is required"
    return
  fi
  local ENV_FILE='.cumulusenv'
  if [ ! -z "$2" ]; then
    ENV_FILE="$2"
  fi
  local VAR=$(grep $1 "$ENV_FILE" | xargs)
  IFS="=" read -ra VAR <<< "$VAR"
  echo ${VAR[1]}
}
changefldr_Date=$(read_var changefldr_Date)
directory="../../$changefldr_Date"
if [ -d "../../$changefldr_Date" ] 
then
    echo "Directory $changefldr_Date exists." 
else
    echo "${red} Error: Directory $changefldr_Date does not exists.${normal}"
    exit 1 
fi
cd ../../$changefldr_Date
echo "Getting diff data from following directory:"
pwd
echo "getting variables from .envcumulus file, saved by ansible run before and after" 
for d in */; do 
echo "######################################################################################"
echo "####                                                                             #####"
echo "   Below  the DIFFs of ${magenta}  $d ${normal} SWITCH"
echo "####                                                                             #####" 
echo "######################################################################################"
cd $d
pwd 
if ls *after 1> /dev/null 2>&1; then
if ls *before 1> /dev/null 2>&1; then
# keep it going
echo " ";
else
    echo "${red} BEFORE CHANGE VERIFICATION FILES DON'T EXIT for $d Switch. ${normal}"
   echo "Looks like before change diffs were not found in '../../$changefldr_Date/$d' directory ${red}  make sure date on the computer has not changedin last few minutes. ${normal}  Example from 1/1/2020 to 1/2/2020 this would cause before change state output to be saved in different folder vs after change commands outputs. Use ${red} date ${normal} command to verify system date did not change in last few minutes"
    exit 1
fi
else
# if diff fails one device we just want to keep going
echo "${magenta} No after diffs found for $d Switch.${normal} , skipping diff check"; 
cd ..
continue; 
fi
echo "# ${magenta} $d  ${normal} Before After ${green} 'net show interface pluggables'  ${red}#"
diff verifypluggablesfpsbefore verifypluggablesfpsafter
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show lldp'  ${red}#"
diff verifylldpbefore verifylldpafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show vhf '  ${red}#"
diff verifyvrfbefore verifyvrfafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show bgp vrf all summary'  ${red}#"
diff verifybgpbefore verifybgpafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show route vrf all static'  ${red}#"
diff verifystaticroutesbefore verifystaticroutesafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show bgp evpn vni'  ${red}#"
diff verifybgpvniinterfacesbefore verifybgpvniinterfacesafter
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show interface'  ${red}#"
echo "${normal}"
diff verifyinterfacesbefore verifyinterfacesafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After ${green} After Below diff 'net show clag'  ${red}#"
diff verifyclagbefore verifyclagafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show ipv4 prefix-list'  ${red}#"
diff verifyipv4prefixbefore verifyipv4prefixafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After diff ${green} 'net show ipv6 prefix-list'  ${red}#"
diff verifyipv6prefixbefore verifyipv6prefixafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before After ${green} neigh.conf EVPN ARP ND enteries 'cat /etc/sysctl.d/neigh.conf'  ${red}#"
diff verifyneighconffilebefore verifyneighconffileafter
echo "${normal}"
echo "# ${magenta} $d ${normal} Before after DHCP-relay diff ${green} 'cat /etc/default/isc-dhcp-rela*'  ${red}#"
diff verifydhcprelaybefore verifydhcprelayafter
echo "${normal}"
cd ..
echo "######################################################################################"
echo "####                                                                              ####"
echo "       Above  the DIFFs of $d SWITCH"
echo "####                                                                              ####" 
echo "######################################################################################"
done 
