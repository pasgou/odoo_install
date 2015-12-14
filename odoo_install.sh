################################################################################
# Script for Installation: ODOO Saas4/Trunk server on Ubuntu 14.04 LTS
# Author: André Schenkels, ICTSTUDIO 2014
# Tuned by Pascal GOUHIER , 2015
# ---> Adapted for OCB from OCA
# ---> Directory Structure easier to backup to another server
# ---> Adding option "auto_reload" and python-pyinotify dependencie
# ---> Setting automated password for Odoo Superadmin and Odoo Postgres User
# ---> Updating paramiko and resolving bug due to Python 2.7.6 and SSL
#-------------------------------------------------------------------------------
#
# This script will install ODOO Server on
# clean Ubuntu 14.04 Server
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

OE_VERSION="8.0"

echo "\n##Odoo version\n" >> odoo_install.log
echo "OE_VERSION=$OE_VERSION" >> odoo_install.log

#set the superadmin password
OE_SUPERADMIN=`python -c 'import base64, os; print(base64.b64encode(os.urandom(24)))'`
OE_CONFIG="$OE_USER-server"

echo "\n##Superadmin password\n" >> odoo_install.log
echo "OE_SUPERADMIN=$OE_SUPERADMIN" >> odoo_install.log
echo "OE_CONFIG=$OE_CONFIG" >> odoo_install.log

#set database configuration (to be adapted)
DB_HOST="127.0.0.1"
DB_PORT="5432"
DB_USER="$OE_USER"
DB_PASSWORD=`python -c 'import base64, os; print(base64.b64encode(os.urandom(24)))'`

echo "\n##Database configuration\n" >> odoo_install.log
echo "DB_HOST=$DB_HOST" >> odoo_install.log
echo "DB_PORT=$DB_PORT" >> odoo_install.log
echo "DB_USER=$DB_USER" >> odoo_install.log
echo "DB_PASSWORD=$DB_PASSWORD" >> odoo_install.log

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = 'localhost'"/g /etc/postgresql/9.3/main/postgresql.conf

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $DB_USER" 2> /dev/null || true
sudo su - postgres -c "psql -U postgres -d postgres -c \"alter user $DB_USER with password '$DB_PASSWORD';\""

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget subversion git bzr bzrtools python-pip -y

echo -e "\n---- Install python packages ----"
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid -y
sudo apt-get install python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz -y
sudo apt-get install python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil -y
sudo apt-get install python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y
sudo apt-get install python-pyinotify python-unicodecsv python-geoip python-cups python-gevent python-imaging -y

echo -e "\n---- Install python libraries ----"
sudo pip install gdata
sudo pip install --upgrade 'requests[security]'
sudo pip install --upgrade paramiko
sudo pip install erppeek

echo -e "\n---- Install wkhtml and place on correct place for ODOO 8 ----"
sudo wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER

echo -e "\n---- Create directory structure ----"
sudo mkdir $OE_HOME_EXT $OE_LOGDIR $OE_IMPORTED_ADDONS $OE_CUSTOM_ADDONS $OE_BACKUP $OE_PRIVATE_ADDONS $OE_FILESTORE $OE_CONFDIR
sudo touch $OE_LOGDIR/$OE_CONFIG.log
sudo chown -R $OE_USER:$OE_USER $OE_HOME

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo su odoo -c "git clone --branch $OE_VERSION https://github.com/OCA/OCB.git $OE_HOME_EXT/"

sudo su odoo "git clone --branch $OE_VERSION https://github.com/clouder-community/clouder.git $OE_IMPORTED_ADDONS/"

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
sudo su root -c "echo 'logfile = $OE_LOGDIR/$OE_CONFIG$1.log' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'logrotate = True' >> $OE_CONFDIR/$OE_CONFIG.conf"
sudo su root -c "echo 'data_dir = $OE_FILESTORE' >> $OE_CONFDIR/$OE_CONFIG.conf"

sudo cp $OE_CONFDIR/$OE_CONFIG.conf $OE_CONFIG.conf

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=$OE_CONFDIR/$OE_CONFIG.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

sudo cp $OE_HOME_EXT/start.sh start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONFIG
echo '### BEGIN INIT INFO' >> ~/$OE_CONFIG
echo '# Provides: $OE_CONFIG' >> ~/$OE_CONFIG
echo '# Required-Start: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Required-Stop: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Should-Start: $network' >> ~/$OE_CONFIG
echo '# Should-Stop: $network' >> ~/$OE_CONFIG
echo '# Default-Start: 2 3 4 5' >> ~/$OE_CONFIG
echo '# Default-Stop: 0 1 6' >> ~/$OE_CONFIG
echo '# Short-Description: Enterprise Business Applications' >> ~/$OE_CONFIG
echo '# Description: ODOO Business Applications' >> ~/$OE_CONFIG
echo '# X-Interactive : true' >> ~/$OE_CONFIG
echo '### END INIT INFO' >> ~/$OE_CONFIG
echo '. /lib/lsb/init-functions' >> ~/$OE_CONFIG
echo 'PATH=/bin:/sbin:/usr/bin' >> ~/$OE_CONFIG
echo "DAEMON=$OE_HOME_EXT/openerp-server" >> ~/$OE_CONFIG
echo "NAME=$OE_CONFIG" >> ~/$OE_CONFIG
echo "DESC=$OE_CONFIG" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify the user name (Default: odoo).' >> ~/$OE_CONFIG
echo "USER=$OE_USER" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify an alternate config file (Default: /etc/openerp-server.conf).' >> ~/$OE_CONFIG
echo "CONFIGFILE=\"$OE_CONFDIR/$OE_CONFIG.conf\"" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# pidfile' >> ~/$OE_CONFIG
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONFIG
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONFIG
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONFIG
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONFIG
echo 'checkpid() {' >> ~/$OE_CONFIG
echo '[ -f $PIDFILE ] || return 1' >> ~/$OE_CONFIG
echo 'pid=`cat $PIDFILE`' >> ~/$OE_CONFIG
echo '[ -d /proc/$pid ] && return 0' >> ~/$OE_CONFIG
echo 'return 1' >> ~/$OE_CONFIG
echo '}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'case "${1}" in' >> ~/$OE_CONFIG
echo 'start)' >> ~/$OE_CONFIG
echo 'echo -n "Starting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo 'stop)' >> ~/$OE_CONFIG
echo 'echo -n "Stopping ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'restart|force-reload)' >> ~/$OE_CONFIG
echo 'echo -n "Restarting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'sleep 1' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo 'status)'>> ~/$OE_CONFIG
echo 'echo -n "Status of ${DESC}: "'>> ~/$OE_CONFIG
echo 'start-stop-daemon --status --quiet --pidfile $PIDFILE && echo "running" || echo "stopped"'>> ~/$OE_CONFIG
echo ';;'>> ~/$OE_CONFIG
echo '*)' >> ~/$OE_CONFIG
echo 'N=/etc/init.d/${NAME}' >> ~/$OE_CONFIG
echo 'echo "Usage: ${NAME} {start|stop|restart|force-reload|status}" >&2' >> ~/$OE_CONFIG
echo 'exit 1' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'esac' >> ~/$OE_CONFIG
echo 'exit 0' >> ~/$OE_CONFIG

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

sudo cp /etc/init.d/$OE_CONFIG $OE_CONFIG

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults
 
sudo service $OE_CONFIG start

#----------------------------------------------------------
#Setting up SSL Mode with Apache2
#----------------------------------------------------------

APACHE_INSTALL_DIR=`pwd`

echo -e "##Installing packages"

sudo apt-get update
sudo apt-get install apache2
sudo a2enmod ssl proxy_http headers rewrite

echo -e "##Creating self-signed certificate"

sudo mkdir /etc/ssl/odoo
cd /etc/ssl/odoo/
openssl genrsa -des3 -out oeserver.pkey 4096
openssl rsa -in oeserver.pkey -out oeserver.key
openssl req -new -key oeserver.key -out oeserver.csr
openssl x509 -req -days 365 -in oeserver.csr -signkey oeserver.key -out oeserver.crt

cd $APACHE_INSTALL_DIR

echo -e "##Creating sites-available file"

sudo touch /etc/apache2/sites-available/openerp.conf

MY_NETWORK_IP=`ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}'` 

echo '<VirtualHost *:443>' > /etc/apache2/sites-available/openerp.conf
echo '' >> /etc/apache2/sites-available/openerp.conf
echo ' SSLEngine on' >> /etc/apache2/sites-available/openerp.conf
echo ' SSLCertificateFile /etc/ssl/odoo/oeserver.crt' >> /etc/apache2/sites-available/openerp.conf
echo ' SSLCertificateKeyFile /etc/ssl/odoo/oeserver.key' >> /etc/apache2/sites-available/openerp.conf
echo '' >> /etc/apache2/sites-available/openerp.conf
echo ' ProxyRequests Off' >> /etc/apache2/sites-available/openerp.conf
echo '' >> /etc/apache2/sites-available/openerp.conf
echo ' <Proxy *>' >> /etc/apache2/sites-available/openerp.conf
echo '  Order deny,allow' >> /etc/apache2/sites-available/openerp.conf
echo '  Allow from all' >> /etc/apache2/sites-available/openerp.conf
echo ' </Proxy>' >> /etc/apache2/sites-available/openerp.conf
echo ' ProxyVia On' >> /etc/apache2/sites-available/openerp.conf
echo ' ProxyPass / http://$MY_NETWORK_IP:8069/' >> /etc/apache2/sites-available/openerp.conf
echo ' <location />' >> /etc/apache2/sites-available/openerp.conf
echo '  ProxyPassReverse /' >> /etc/apache2/sites-available/openerp.conf
echo ' </location>' >> /etc/apache2/sites-available/openerp.conf
echo '' >> /etc/apache2/sites-available/openerp.conf
echo ' RequestHeader set "X-Forwarded-Proto""https"' >> /etc/apache2/sites-available/openerp.conf
echo '' >> /etc/apache2/sites-available/openerp.conf
echo ' SetEnv proxy-nokeepalive 1' >> /etc/apache2/sites-available/openerp.conf
echo '</VirtualHost>' >> /etc/apache2/sites-available/openerp.conf

sudo a2ensite openerp.conf
sudo service apache2 reload

sudo cp /etc/apache2/sites-avaible/openerp.conf openerp_apache2_Vhost


echo "Done! The ODOO server can be started with: service $OE_CONFIG start"
echo "You can create your first Database with this SuperAdmin Password : $OE_SUPERADMIN (copy/paste it)."
