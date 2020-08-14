# backup-restore-configs

## make sure you have console access to the switch otherwise don't perform this upgrade
### backup your licence 
```
cumulus@leaf01:mgmt-vrf:~$ cl-license
das@yahoo.com|this is the fake license
cumulus@leaf01:mgmt-vrf:~$

```
1. Make sure to update the license in  `backup-restore-configs/roles/install_license/tasks/main.yml` 
2. make sure to update the `hosts` file with the correct IP addresses of the switches 
3. Before the change backup the existing configs (! make sure you backup all important configs)

`ansible-playbook fetch_configs.yml -i hosts -u cumulus -kKb`

Also capture the before change state. 

`ansible-playbook validation.yml -i hosts -u cumulus -kkb --extra-vars '{"validationstate":"before"}'`

Note: the backups would be made in `~/configs` directory , before change state capture would be backed up in `../../changevalidationXX` directory 
4. Make sure to make extra backup copy of the configs and the prechange validation states 

`cp -r configs configs-backup` 

`cp -r changevalidationxx changevalidationxx-backup` 

5. Make sure and confirm the backup configs look good 
6. We can also use adhoc commands like the one below to capture the current status  (! Optional)

`ansible -i hosts  -m shell -a ' cl-license; uname -m; net show bgp vrf all summary;net show bgp evpn vni ; net show bgp evpn vni ; net show clag; net show inter | grep DN; systemctl status frr.service; systemctl status networking.service; net show configuration commands; cat /etc/snmp/snmpd.conf; cat /etc/frr/frr.conf; cat /etc/network/interfaces; cat /etc/cumulus/ports.conf; cat  /etc/cumulus/acl/policy.d/* ;  cat /etc/hostapd.conf ' -u cumulus   all -kKb` 

7. Make sure the image is right version for your switches CPU, to check the version of your CPU if its x64 or arm use the following command

`cumulus@leaf01:mgmt-vrf:~$ uname -m
x86_64
` 
8. Make sure if its clag peer switch the switch has the secondary roles and uplinks are shutdown

```
net add interface peerlink.4094 clag priority 32000  
net pending 
net commit 
``` 

Verify switch has seconday role 

`net show clag` 

```
cumulus@leaf01:mgmt-vrf:~$ net show clag
The peer is alive
     Our Priority, ID, and Role: 32000 44:38:39:00:00:26 secondary   <<<<<<<<<<<<<< secondary ~~
    Peer Priority, ID, and Role: 200 44:38:39:00:00:27 primary
          Peer Interface and IP: peerlink.4094 169.254.1.2
               VxLAN Anycast IP: 10.0.0.112
                      Backup IP: 10.0.0.12 (active)
                     System MAC: 44:39:39:ff:40:94

CLAG Interfaces
Our Interface      Peer Interface     CLAG Id   Conflicts              Proto-Down Reason
----------------   ----------------   -------   --------------------   -----------------
           vni13   vni13              -         -                      -
       vxlan4001   vxlan4001          -         -                      -
          bond01   bond01             1         -                      -
           vni24   vni24              -         -                      -
          bond02   bond02             2         -                      -
cumulus@leaf01:mgmt-vrf:~$

```

Shutdown the uplinks and the peerlink

```
net add inter swpxx,swpxx link down
net add bond peerlink link down
net pending 
net commit 
```
9. copy the new image to the system 
10. Install the new image using console access 

#### IMPORTANT: Make sure all the configs are backed up before you perform this step

`onie-install –f -a -i <image-location>`

11. Using console access configure the Management IP address and gateway 

```
net add interface eth0 ip address 10.250.25.x/21
net add interface eth0 ip gateway 10.250.31.254
net pending 
net commit 
```

12. Restore the backup configs 
`ansible-playbook restore_configs.yml -i switchname -u cumulus -kKb`
13. Make sure the CLAG ID config ping the backup IP on the `mgmt` vrf  (! Note: only if previous Cumulus OS verision did not have mgmt VRF by default)

```
net add interface peerlink.4094 clag backup-ip <peer backup ip here> vrf mgmt
```

14. Make sure the license has been installed and configs have been restored 
```
cl-license 
cat /etc/frr/daemons
cat /etc/frr/frr.config 
cat /etc/network/interfaces 
# ..... other config files as necessary 
``` 
15. reboot the switch so the new configs get applied 
16. Check and Make sure all the interfaces are up as expected and the routing is working as expected 

`ansible -i hosts  -m shell -a ' cl-license; uname -m; net show bgp vrf all summary; net show bgp evpn vni ; net show clag; net show inter | grep DN; systemctl status frr.service; systemctl status networking.service; ' -u cumulus   all -kKb` 

17. Do the final post change verifications 

`ansible-playbook validation.yml -i hosts -u cumulus -kkb --extra-vars '{"validationstate":"after"}'`

Check if there is change in state run the showdiff.sh script 

`./showdiff.sh` 


18. Change the CLAG state of the switch if needed. Lower priority value is preferred, when setting clag priority. 
```
net add interface peerlink.4094 clag priority 32000  
net pending 
net commit 
``` 


