lib_fn_hello () {
	echo "Hello World"
}

###########################################################
# FUNCTIONS
###########################################################
lib_fn_print_db_usage () {
    echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 15432)"
    echo "  Host: localhost"
    echo "  Port: 15432"
    echo "  Database: $APP_DB_NAME"
    echo "  Username: $APP_DB_USER"
    echo "  Password: $APP_DB_PASS"
    echo ""
    echo "Admin access to postgres user via VM:"
    echo "  vagrant ssh"
    echo "  sudo su - postgres"
    echo ""
    echo "psql access to app database user via VM:"
    echo "  vagrant ssh"
    echo "  sudo su - postgres"
    echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost $APP_DB_NAME"
    echo ""
    echo "Env variable for application development:"
    echo "  DATABASE_URL=postgresql://$APP_DB_USER:$APP_DB_PASS@localhost:15432/$APP_DB_NAME"
    echo ""
    echo "Local command to access the database via psql:"
    echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost -p 15432 $APP_DB_NAME"
}



lib_fn_install_postgres () {
    # INSTALL POSTGRES

		APP_DB_NAME=`fn_cfg_from_json db_name`
		APP_DB_USER=`fn_cfg_from_json db_user`
		APP_DB_PASS=`fn_cfg_from_json db_password`
		PG_VERSION=`fn_cfg_from_json postgres_version`

		POSTGRES_SETUP="CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS'; \
		    CREATE DATABASE $APP_DB_NAME WITH OWNER $APP_DB_USER;"

		echo "*********** USING THIS CONFIGURATION FOR POSTGRES SETUP *****************"
		echo $POSTGRES_SETUP
		echo "*************************************************************************"

    echo "********* INSTALLING POSTGRES *****************"
    sudo apt-get -y install "postgresql" "postgresql-contrib"

    PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
    PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
    PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

    # Edit postgresql.conf to change listen address to '*':
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

    # Append to pg_hba.conf to add password auth:
    echo "host    all             all             all                     md5" >> "$PG_HBA"

    # Restart so that all new config is loaded:
   service postgresql restart

   echo $POSTGRES_SETUP | su - postgres -c psql
   echo "Successfully created PostgreSQL dev virtual machine."
}

lib_fn_install_go () {
    #golang go 1.7
    sudo mkdir /opt/go
    sudo chown -R ubuntu:ubuntu /opt
    wget -O - https://storage.googleapis.com/golang/go1.7.6.linux-amd64.tar.gz | tar xzf - -C /opt/

		echo "export GOPATH=/home/ubuntu/code" >> /home/ubuntu/.profile
    echo "export GOROOT=/opt/go" >> /home/ubuntu/.profile
    echo "export PATH=$PATH:/opt/go/bin" >> /home/ubuntu/.profile
    sudo -s source /home/ubuntu/.profile
}

lib_fn_install_system_apps () {

    echo "********* UPDATING SYSTEM APPS *****************"
    sudo apt-get update
    sudo locale-gen en_US.UTF-8
    sudo apt-get -y install build-essential libssl-dev # g++, make, etc.
    sudo apt-get -y install git
    sudo apt-get -y install mercurial
    sudo apt-get -y install curl
    sudo apt-get -y install zip unzip
    sudo apt-get -y install x11-apps
    sudo apt-get -y install nodejs
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo apt-get -y install npm
}


lib_fn_install_dev_tools () {
    # This directory is set in Vagrantfile (config.vm.synced_folder)
    echo "********* INSTALLING DEV TOOLS ***************"
    sudo npm update
    sudo npm install gulp --global
    sudo npm install gulp-cli --global

    echo "********* NOW WE SETUP APP ***************"
    cd /home/ubuntu/code
    npm install
}

lib_fn_check_for_previous_install () {

    # Installation checks, EXITS if already provisioned!!!
    if [ -f "$PROVISIONED_ON" ]
    then
        echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
        echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
        echo ""
        lib_fn_print_db_usage
        exit
    fi

    if [ ! -f "$PG_REPO_APT_SOURCE" ]
    then
        # Add PG apt repo:
        echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > "$PG_REPO_APT_SOURCE"

        # Add PGDG repo key:
        wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
    fi
}
