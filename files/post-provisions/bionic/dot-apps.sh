#!/usr/bin/env bash

# create the initial database for dot
echo "Linking dot apps to live_code folders"
sudo sh -c '
    WEB_ROOT="/var/www/"
    LIVE_ROOT="/var/live_code/"
    REFERENCE_PATH=${WEB_ROOT}html
    makeLiveAppFolder() {
        APP_NAME=$1
        PUBLIC_NAME=$2
        WEB_PATH=${WEB_ROOT}${APP_NAME}
        CURRENT_CODE_PATH=$WEB_PATH/current_code
        LIVE_CODE_PATH=${LIVE_ROOT}${APP_NAME}

        mkdir -p $WEB_PATH
 
        ln -sfn $LIVE_CODE_PATH $CURRENT_CODE_PATH
        ln -sfn $CURRENT_CODE_PATH/$PUBLIC_NAME $WEB_PATH/public
 
        chmod -R --reference=$REFERENCE_PATH $WEB_PATH
        chown -R --reference=$REFERENCE_PATH $WEB_PATH
    }

    makeLiveAppFolder backend public
'
