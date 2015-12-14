#!/bin/bash
#----------------------------------------------------
#
# Script from Pascal GOUHIER
#
# Installing Python V 2.7.11
#
#----------------------------------------------------

echo "Installing Python V 2.7.11" >> odoo_install.log
# install dependencies
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
sudo apt-get install checkinstall

# download and extract python 2.7.11 source
mkdir ~/python/ && mkdir ~/python/source
cd ~/python/source
wget http://python.org/ftp/python/2.7.11/Python-2.7.11.tgz
tar -xvf Python-2.7.11.tgz
sudo mv Python-2.7.11 python-current
#cd Python-2.7.11
cd python-current

# compile python source to new directory
sudo mkdir /opt/python-current
sudo ./configure --prefix=/opt/python-current
sudo make altinstall

# use checkinstall to create and install deb package
sudo checkinstall --pkgname=python-current --pkgversion=2.7.11 -y

# display python version
/opt/python-current/bin/python -V

# install setuptools
curl https://bootstrap.pypa.io/ez_setup.py -o - | sudo /opt/python-current/bin/python

# use setuptools to install pip
sudo /opt/python-current/bin/easy_install -s /opt/python-current/bin -d /opt/python-current/lib/python2.7/site-packages/ pip

# update PATH to include the new version of python first
export PATH="/opt/python-current/bin:$PATH"
