#/bin/bash
#set -xv
clear
DATETIME="`date '+%Y%m%d%H%M%S'`"
DEV_LOGS=/tmp/baby-fleming-logs-for-devs
TEST_RUN_LOG=$DEV_LOGS-$DATETIME
WD=/home/$USER/.safe/vault
SAFE_AUTH_PASSWORD="aaaaa"
SAFE_AUTH_PASSPHRASE="aaaaa"
VAULT_RUN_CMD="safe vault run-baby-fleming"

echo "==================================================================================="
echo "=                                                                                 ="
echo "=  This will set up a new Baby Fleming network on your computer.                  ="
echo "=                                                                                 ="
echo "=  Existing logs will be timestamped and archived and the old vaults DELETED      ="
echo "=                                                                                 ="
read -p "=  Are you entirely sure about this? (y/N)                                        =" -n 1 -r
echo "=                                                                                 ="
echo "==================================================================================="


if [[ $REPLY =~ ^[Yy]$ ]]
then
    
    #  Save existing logs, if any

    if [[ ! -e $DEV_LOGS ]]; then
        mkdir -p $DEV_LOGS
    elif [[ ! -d $DEV_LOGS ]]; then
        echo "$DEV_LOGS already exists but is not a directory" 1>&2
    fi

    # set up the destination for this test run logs
    mkdir -p $TEST_RUN_LOG

    # copy the individual vault logs
    for  i in genesis 2 3 4 5 6 7 
    do
            cp  /home/$USER/.safe/vault/baby-fleming-vaults/safe-vault-$i/safe_vault.log  $TEST_RUN_LOG/safe-vault${DATETIME}-$i.log
    done

    # copy the auth log and store it beside the vault logs
    #cp  /home/$USER/.safe/authd/logs/safe-authd.*  $TEST_RUN_LOG/

    echo " Existing logs (if any) Have been backed up to /tmp "

    # create login creds
    cd $WD
    echo "{ \"passphrase\":\"$SAFE_AUTH_PASSPHRASE\", \"password\":\"$SAFE_AUTH_PASSWORD\" }" > $WD/myconfig.json
    
    # Clean up
    safe vault killall
    rm -rf baby-fleming-vaults
    #rm -v ../authd/logs/safe-authd.out
    #rm -v ../authd/logs/safe-authd.err

    # OK    Do stuff .......
    # -y &&
    $VAULT_RUN_CMD &&
    safe networks add my-network &&
    safe networks switch my-network &&
    safe auth restart &&
    #safe auth status
    safe auth create-acc --test-coins -c $WD/myconfig.json &&
    safe auth login --self-auth -c $WD/myconfig.json &&
    safe auth status

   

    # TODO: error checking here
     # if we got this far, it's worked - report success

    echo "==================================================================================="
    echo "=                                                                                 ="
    echo "=      Your new Baby Fleming test network is running                              ="
    echo "=                                                                                 ="
    echo "=      Logs from the previous run are saved in a timestamped directory in /tmp    ="
    echo "=                                                                                 ="
    echo "=      Have fun !!                                                                ="
    echo "=                                                                                 ="
    echo "==================================================================================="

fi
