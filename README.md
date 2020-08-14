# backup-restore-configs

## make sure you have console access to the switch otherwise don't perform this upgrade
1. Make sure to update the license in  `backup-restore-configs/roles/install_license/tasks/main.yml` 
2. make sure to update the `hosts` file with the correct IP addresses of the switches 
3. Before the change backup the existing configs (! make sure you backup all important configs)
`ansible-playbook fetch_configs.yml -i hosts -u cumulus -kKb`
`ansible-playbook validation.yml -i hosts -u cumulus -kkb --extra-vars '{"validationstate":"before"}'`
Note: the backups would be made in `~/configs` directory , before change state capture would be backed up in `../../changevalidationXX` directory 
4. Make sure to make extra backup copy of the configs and the prechange validation states 

`cp -r configs configs-backup` 

`cp -r changevalidationxx changevalidationxx-backup` 

5. Make sure and confirm the backup configs look good 
6. We can also use adhoc commands like the one below to capture the current status  (! Optional)

`ansible -i hosts  -m shell -a ' cl-license; uname -m; net show bgp vrf all summary;net show bgp evpn vni ; net show bgp evpn vni ; net show clag; net show inter | grep DN; systemctl status frr.service; systemctl status networking.service; net show configuration commands; cat /etc/snmp/snmpd.conf; cat /etc/frr/frr.conf; cat /etc/network/interfaces; cat /etc/cumulus/ports.conf; cat  /etc/cumulus/acl/policy.d/* ;  cat /etc/hostapd.conf ' -u cumulus   all -kKb` 

6. Make sure the image is right version for your switches CPU, to check the version of your CPU if its x64 or arm use the following command

`cumulus@leaf01:mgmt-vrf:~$ uname -m
x86_64
` 

7. copy the new image to the system 
8. Install the new image 
`onie-install –f -a -i <image-location>`
9. configure the Management IP address and gateway 
10. Make sure the CLAG ID config ping the backup IP on the `mgmt` vrf 



