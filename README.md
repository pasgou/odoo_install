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
hostnames
fichier /etc/hosts

nginx

letenscrypt

Certbot plugin for authentication using Gandi LiveDNS

This is a plugin for Certbot that uses the Gandi LiveDNS API to allow Gandi customers to prove control of a domain name.
Usage

    Obtain a Gandi API token (see Gandi LiveDNS API)

    Install the plugin using pip install certbot-plugin-gandi

    Create a gandi.ini config file with the following contents and apply chmod 600 gandi.ini on it:

    # live dns v5 api key
    certbot_plugin_gandi:dns_api_key=APIKEY

    # optional organization id, remove it if not used
    certbot_plugin_gandi:dns_sharing_id=SHARINGID

    Replace APIKEY with your Gandi API key and ensure permissions are set to disallow access to other users.

    Run certbot and direct it to use the plugin for authentication and to use the config file previously created:

    certbot certonly -a certbot-plugin-gandi:dns --certbot-plugin-gandi:dns-credentials gandi.ini -d domain.com

    Add additional options as required to specify an installation plugin etc.

Please note that this solution is usually not relevant if you're using Gandi's web hosting services as Gandi offers free automated certificates for all simplehosting plans having SSL in the admin interface. Huge thanks to Michael Porter for its original work !

Be aware that the plugin configuration must be provided by CLI, configuration for third-party plugins in cli.ini is not supported by certbot for the moment. Please refer to #4351, #6504 and #7681 for details.
Distribution

    PyPI: https://pypi.org/project/certbot-plugin-gandi/
    Archlinux: https://aur.archlinux.org/packages/certbot-dns-gandi-git/

Wildcard certificates

This plugin is particularly useful when you need to obtain a wildcard certificate using dns challenges:

certbot certonly -a certbot-plugin-gandi:dns --certbot-plugin-gandi:dns-credentials gandi.ini -d domain.com -d \*.domain.com --server https://acme-v02.api.letsencrypt.org/directory

Automatic renewal

You can setup automatic renewal using crontab with the following job for weekly renewal attempts:

0 0 * * 0 certbot renew -q -a certbot-plugin-gandi:dns --certbot-plugin-gandi:dns-credentials /etc/letsencrypt/