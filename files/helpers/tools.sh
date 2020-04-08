#!/usr/bin/env bash
# a few bash helpers for provision scripts

sayHello() {
    echo "Hello!"
}

loadBoxCustomizersFromDirectory() {
    if [ -e $1 ]; then
        for file in $1*
        do
            if [ -f $file ]; then 
                echo "Running post-provisions script: $file"
                source $file
            fi
        done
    fi
}

exitIfPackageIsMissing() {
    if ! (apt-cache pkgnames | grep $1); then
        echo "Stopped bootstrap. Cannot install everything. Unable find this package: $1"
        exit 1;
    fi
}

addLineOnce() {
    TARGET_LINE=$1 #eg: 'include "/configs/projectname.conf"'
    TARGET_FILE=$2 #eg: 'foo.bar'
    if ! (grep -qxF "$TARGET_LINE" $TARGET_FILE); then 
        echo "$TARGET_LINE" >> $TARGET_FILE
        echo "Added new line to $TARGET_FILE"
    fi
}

setupSqlAdminUser() {
    DBUSER=$1
    PASSWORD=$2
    DOMAIN=$3

    # @TODO -- figure out how to avoid errors when user does not exist
    sudo mysql -f "REVOKE ALL PRIVILEGES, GRANT OPTION FROM $DBUSER"
    
    # works only for mysql 57
    sudo mysql -e "DROP USER IF EXISTS '$DBUSER'"

    # setup vagrant as db user
    sudo mysql -e "CREATE USER '$DBUSER'@'$DOMAIN' IDENTIFIED BY '$PASSWORD'"

    # give all privileges to that user
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'$DOMAIN';"
}

createDatabase() {
    sudo mysql -e "DROP DATABASE IF EXISTS $1";
    sudo mysql -e "CREATE DATABASE $1"
}

replaceInFile() {
    local SEARCH=$1
    local REPLACE=$2
    local TARGET_FILE=$3

    #called parameter expansion to escape the sed delimiter: https://stackoverflow.com/a/27788661
    sed -i "s/${SEARCH}/${REPLACE//\//\\/}/g" $TARGET_FILE
}
