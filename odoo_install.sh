################################################################################
# Script for Installation: ODOO 12
# Author: Pascal GOUHIER , 2019
# ---> Adapted for OCB from OCA
# ---> Directory Structure easier to backup to another server
# ---> Adding option "auto_reload" and python-pyinotify dependencie
# ---> Setting automated password for Odoo Superadmin and Odoo Postgres User
#-------------------------------------------------------------------------------
#
# This script will install ODOO Server with SAAS tools on
# clean Ubuntu 18.04 Server
#
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# ./odoo-install
#
################################################################################

ODOO_INSTALL_DIR=`pwd`

touch odoo_install.log

echo `date` > odoo_install.log

#------------------------------#
#                              #
#####   Odoo installation  #####
#                              #
#------------------------------#
#
##fixed parameters
#openerp

OE_USER="odoo"
OE_HOME="/home/$OE_USER"
OE_HOME_EXT="$OE_HOME/$OE_USER"

echo "#fixed parameters\n##odoo parameters\n" >> odoo_install.log
echo "OE_USER=$OE_USER" >> odoo_install.log
echo "OE_HOME=$OE_HOME" >> odoo_install.log
echo "OE_HOME_EXT=$OE_HOME_EXT" >> odoo_install.log

#Directory Structure

echo "\n##Directory Structure\n" >> odoo_install.log

OE_LOGDIR="$OE_HOME/log"
OE_IMPORTED_ADDONS="$OE_HOME/imported_addons"
OE_CUSTOM_ADDONS="$OE_HOME/custom_addons"
OE_PRIVATE_ADDONS="$OE_HOME/private_addons"
OE_CONFDIR="$OE_HOME/conf"
OE_BACKUP="$OE_HOME/backup"
OE_FILESTORE="$OE_HOME/filestore"

echo "OE_LOGDIR=$OE_LOGDIR" >> odoo_install.log
echo "OE_IMPORTED_ADDONS=$OE_IMPORTED_ADDONS -> Receive addons from others (OCA, Clouder, ...)" >> odoo_install.log
echo "OE_CUSTOM_ADDONS=$OE_CUSTOM_ADDONS -> Receive customizations of addons" >> odoo_install.log
echo "OE_PRIVATE_ADDONS=$OE_PRIVATE_ADDONS -> Receive addons created for us" >> odoo_install.log
echo "OE_CONFDIR=$OE_CONFDIR" >> odoo_install.log
echo "OE_BACKUP=$OE_BACKUP" >> odoo_install.log
echo "OE_FILESTORE=$OE_FILESTORE" >> odoo_install.log

#Enter version for checkout "8.0" for version 8.0, "7.0 (version 7), saas-4, saas-5 (opendays version) and "master" for trunk

OE_VERSION="12.0"

echo "\n##Odoo version\n" >> odoo_install.log
echo "OE_VERSION=$OE_VERSION" >> odoo_install.log

#set the superadmin password
OE_SUPERADMIN=`python3 -c 'import base64, os; print(base64.b64encode(os.urandom(24)))'`
OE_CONFIG="$OE_USER-server"

echo "\n##Superadmin password\n" >> odoo_install.log
echo "OE_SUPERADMIN=$OE_SUPERADMIN" >> odoo_install.log
echo "OE_CONFIG=$OE_CONFIG" >> odoo_install.log

#set database configuration (to be adapted)
DB_HOST="127.0.0.1"
DB_PORT="5432"
DB_USER="$OE_USER"
DB_PASSWORD=`python3 -c 'import base64, os; print(base64.b64encode(os.urandom(24)))'`

echo "\n##Database configuration\n" >> odoo_install.log
echo "DB_HOST=$DB_HOST" >> odoo_install.log
echo "DB_PORT=$DB_PORT" >> odoo_install.log
echo "DB_USER=$DB_USER" >> odoo_install.log
echo "DB_PASSWORD=$DB_PASSWORD" >> odoo_install.log

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt update
sudo apt upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt install postgresql -y

#echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
#sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = 'localhost'"/g /etc/postgresql/9.3/main/postgresql.conf

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $DB_USER" 2> /dev/null || true
sudo su - postgres -c "psql -U postgres -d postgres -c \"alter user $DB_USER with password '$DB_PASSWORD';\""

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt install git python3-pip build-essential wget python3-dev python3-venv \
					python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev \
					python3-setuptools node-less

# echo -e "\n---- Install python packages ----"
# sudo apt install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid -y
# sudo apt install python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz -y
# sudo apt install python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil -y
# sudo apt install python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y
# sudo apt install python-pyinotify python-unicodecsv python-geoip python-cups python-gevent python-imaging -y
# 
# echo -e "\n---- Install python libraries ----"
# sudo pip install gdata
# sudo pip install --upgrade 'requests[security]'
# sudo pip install --upgrade paramiko
# sudo pip install erppeek

echo -e "\n---- Install wkhtml and place on correct place for ODOO ----"
sudo apt install -yq fontconfig libjpeg-turbo8 libjpeg-turbo8 libxrender1xfonts-75dpi xfonts-base
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb && sudo apt install -f
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin

echo -e "\n---- Create ODOO system user ----"
sudo useradd -m -d $OE_HOME -U -r -s /bin/bash $OE_USER

echo -e "\n---- Create directory structure ----"
sudo mkdir $OE_HOME_EXT $OE_LOGDIR $OE_IMPORTED_ADDONS $OE_CUSTOM_ADDONS $OE_BACKUP $OE_PRIVATE_ADDONS $OE_FILESTORE $OE_CONFDIR
sudo touch $OE_LOGDIR/$OE_CONFIG.log
sudo chown -R $OE_USER:$OE_USER $OE_HOME

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/OCA/OCB.git $OE_HOME_EXT/"
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/it-projects-llc/saas-addons.git $OE_IMPORTED_ADDONS/saas-addons/"
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/itpp-labs/access-addons.git $OE_IMPORTED_ADDONS/access-addons/"
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/itpp-labs/misc-addons.git $OE_IMPORTED_ADDONS/misc-addons/"
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/OCA/web.git $OE_IMPORTED_ADDONS/web/"
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/OCA/queue.git $OE_IMPORTED_ADDONS/queue/"
sudo pip3 install wheel
sudo pip3 install -r $OE_HOME_EXT/requirements.txt
sudo pip3 install -r $OE_IMPORTED_ADDONS/saas-addons/requirements.txt
sudo pip3 install -r $OE_IMPORTED_ADDONS/misc-addons/requirements.txt
sudo pip3 install -r $OE_IMPORTED_ADDONS/web/requirements.txt
sudo su odoo -c "mv -f $OE_IMPORTED_ADDONS/saas-addons/* $OE_IMPORTED_ADDONS"
sudo su odoo -c "mv -f $OE_IMPORTED_ADDONS/access-addons/* $OE_IMPORTED_ADDONS"
sudo su odoo -c "mv -f $OE_IMPORTED_ADDONS/misc-addons/* $OE_IMPORTED_ADDONS"
sudo su odoo -c "mv -f $OE_IMPORTED_ADDONS/web/* $OE_IMPORTED_ADDONS"
sudo su odoo -c "mv -f $OE_IMPORTED_ADDONS/queue/* $OE_IMPORTED_ADDONS"
sudo pip3 install python-barcode

echo -e "* Create server config file"
sudo touch $OE_CONFDIR/$OE_CONFIG.conf
sudo chown $OE_USER:$OE_USER $OE_CONFDIR/$OE_CONFIG.conf
sudo chmod 640 $OE_CONFDIR/$OE_CONFIG.conf

echo -e "* create default var/lib/$OE_USER directory"
sudo mkdir /var/lib/$OE_USER
sudo chown -R odoo:root /var/lib/$OE_USER

echo -e "* Change server config file"
sudo su root -c "echo '[options]' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo ';This is the password that allows database operations:' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'admin_passwd = $OE_SUPERADMIN' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo '#### Database' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'db_host = $DB_HOST' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'db_port = $DB_PORT' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'db_user = $DB_USER' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'db_password = $DB_PASSWORD' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo '#### Odoo' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'auto_reload = True' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_IMPORTED_ADDONS,$OE_CUSTOM_ADDONS,$OE_PRIVATE_ADDONS' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'syslog = True' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'data_dir = $OE_FILESTORE' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'workers = 2' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'server_wide_modules = web,queue_job,saas' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo '[queue_job]' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'channels = root:2' >> $OE_CONFDIR/$OE_CONFIG.conf"

sudo cp $OE_CONFDIR/$OE_CONFIG.conf $OE_CONFIG.conf

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/odoo-bin --config=$OE_CONFDIR/$OE_CONFIG.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

sudo cp $OE_HOME_EXT/start.sh start.sh

#--------------------------------------------------
# Adding ODOO as a service
#--------------------------------------------------

echo -e "* Create Systemd Unit File"
sudo touch /etc/systemd/system/odoo12.service
sudo su root -c "echo '[Unit]
Description=Odoo12
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo12
PermissionsStartOnly=true
User=$OE_USER
Group=$OE_USER
ExecStart=python3 OE_HOME_EXT/odoo-bin -c $OE_CONFDIR/$OE_CONFIG.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target' >> /etc/systemd/system/odoo12.service"
sudo chmod 755 /etc/systemd/system/odoo12.service

echo -e "* Start ODOO on Startup"
sudo systemctl daemon-reload
sudo systemctl start odoo12
sudo systemctl enable odoo12

echo "Done! The ODOO server can be started with: service $OE_CONFIG start"
echo "You can create your first Database with this SuperAdmin Password : $OE_SUPERADMIN (copy/paste it)."
