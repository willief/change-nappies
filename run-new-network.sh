#/bin/bash
set -xv

DATETIME="`date '+%Y%m%d%H%M%S'`"
devlogdir=/tmp/baby-fleming-logs-for-devs
WD=/home/$USER/.safe/vault

#  Save existing logs, if any

if [[ ! -e $devlogdir ]]; then
    mkdir -p $devlogdir
elif [[ ! -d $devlogdir ]]; then
    echo "$devlogdir already exists but is not a directory" 1>&2
fi


for  i in genesis 2 3 4 5 6 7 
 do
        cp -v /home/$USER/.safe/vault/baby-fleming-vaults/safe-vault-$i/safe_vault.log  /tmp/baby-fleming-logs-for-devs/safe-vault${DATETIME}-$$
 done


cd $WD

# Clean up
safe vault killall
rm -vrf baby-fleming-vaults


safe vault run-baby-fleming -y 
safe networks add my-network
safe networks switch my-network
safe auth restart
safe auth status
safe auth create-acc --test-coins 
safe auth login --self-auth

