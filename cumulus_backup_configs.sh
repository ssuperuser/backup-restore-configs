#!/bin/bash


# NOTE LIMITED SCOPE, used only as backup if ansible is not available 
# This script needs to run on the switch, then the content of the directory needs to be backed up using SCP, this script is not preferred if ansible is available. 
# This script has very limited functionalities. All the configs would have to be restored manually.
#



host=$(hostname)
mkdir $host
cd $host
/usr/cumulus/bin/cl-license > license
cp /etc/network/interfaces .
cp /etc/frr/frr.conf .
cp /etc/frr/daemons .
cp /etc/cumulus/ports.conf .
cp /etc/cumulus/acl/policy.d/* .
cp /etc/snmp/snmpd.conf .
