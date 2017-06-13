#!/bin/bash

############################################################
# INCLUDES
############################################################

. $(dirname $0)/lib_fn.sh

############################################################
# CONFIG
############################################################
PROVISIONED_ON=/etc/vm_provision_on_timestamp
PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
export DEBIAN_FRONTEND=noninteractive

fn_cfg_from_json () {
    temp=`echo $JSON_CFG_OBJ | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $1 | cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
    echo ${temp##*|}
}

JSON_CFG_OBJ=`cat $(dirname $0)/cfg.json`
APPNAME=`fn_cfg_from_json appname`
APPVERSION=`fn_cfg_from_json appversion`

echo "*********** USING THIS CONFIGURATION ************************************"
echo "APPNAME: $APPNAME"
echo "VERSION: $APPVERSION"
echo "*************************************************************************"

############################################################
# MAIN
############################################################

#lib_fn_check_for_previous_install
lib_fn_install_system_apps
lib_fn_install_postgres
lib_fn_install_go
lib_fn_install_dev_tools

# Check installation
echo "Postgresql version: "
psql --version
echo "Node version: "
node --version
echo "NPM version: "
npm -version
echo "Gulp version: "
gulp --version
