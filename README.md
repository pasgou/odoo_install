odoo_install
a script to install Odoo on a fresh server

Author: Pascal GOUHIER , 2019
- Adapted for OCB from OCA
- Directory Structure easier to backup to another server
- Adding option "auto_reload" and python-pyinotify dependencie
- Setting automated password for Odoo Superadmin and Odoo Postgres User
#-------------------------------------------------------------------------------
#
This script will install ODOO Server with SAAS tools on
clean Ubuntu 18.04 Server
#
#-------------------------------------------------------------------------------
USAGE:
#
odoo-install
#
EXAMPLE:
./odoo-install
#
