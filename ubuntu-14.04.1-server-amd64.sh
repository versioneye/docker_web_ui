#!/bin/bash

# 
# This script installs everything what is needed to run the docker-web-ui application from VersionEye. 
# docker-web-ui is completely open source: https://github.com/versioneye/docker_web_ui. 
# The dependencies are: 
# 
#  - UTF-8
#  - Git 
#  - Python software properites 
#  - Oracle JDK 8 
#  - MRI Ruby 2.2.2 with gem & bundler
#  - Docker 1.7.1 
# 
# This script is tested with ubuntu-14.04.1-server-amd64.iso 
# 

# Set encoding to UTF-8
echo LC_ALL=en_US.UTF-8 >> /etc/environment 
export LC_ALL=en_US.UTF-8

# Update the system
apt-get update 
apt-get upgrade -y -q 

# Install Git. Needed to checkout docker-web-ui from GitHub.
apt-get install -y git 

# Install software-properties. Needed for Gem dependencies. 
apt-get install -y software-properties-common python-software-properties

# Install Oracle Java 8 with JDK. Needed for Gem dependencies.
add-apt-repository -y ppa:webupd8team/java 
apt-get update 
apt-get upgrade -y -q
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections; echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get -y -q install oracle-java8-installer 

# Install mandatory dependencies for Ruby 2.2.2
apt-get -y -q install wget gcc g++ make autoconf automake libssl-dev libcurl4-openssl-dev git build-essential ruby-dev rake libreadline6 libreadline6-dev libssl-dev libncurses5-dev zlib1g zlib1g-dev libyaml-dev libxml2-dev libc6-dev libtool bison curl

# Install Ruby 2.2.2
mkdir -p /opt 
wget -O /opt/ruby-2.2.2.tar.gz http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
cd /opt; tar -xzf ruby-2.2.2.tar.gz; 
cd /opt/ruby-2.2.2; ./configure; make; make install
gem install bundler 

# Install Docker 1.7.1 
apt-get -y install linux-image-extra-$(uname -r)
sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sh -c "echo deb http://get.docker.io/ubuntu docker main\ > /etc/apt/sources.list.d/docker.list"
apt-get update
apt-get -y install lxc-docker


# Install docker-web-ui
mkdir -p /var/www
mkdir -p /var/www/docker_web_ui
mkdir -p /var/www/docker_web_ui/releases
mkdir -p /var/www/docker_web_ui/releases/init
mkdir -p /var/www/docker_web_ui/shared
mkdir -p /var/www/docker_web_ui/shared/log
mkdir -p /var/www/docker_web_ui/shared/pids
chown -R ubuntu:ubuntu /var/www/docker_web_ui

cp unicorn.sh /etc/init.d/unicorn.sh
chown ubuntu:ubuntu /etc/init.d/unicorn.sh
chmod u+rwx /etc/init.d/unicorn.sh
update-rc.d unicorn.sh defaults

ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone https://github.com/versioneye/docker_web_ui.git /var/www/docker_web_ui/releases/init

rm -Rf /var/www/docker_web_ui/releases/init/log
ln -s  /var/www/docker_web_ui/shared/log /var/www/docker_web_ui/releases/init/log
ln -s  /var/www/docker_web_ui/shared/pids /var/www/docker_web_ui/releases/init/pids

cd /var/www/docker_web_ui/releases/init/; bundle install 
cd /var/www/docker_web_ui/releases/init/; bundle exec rake assets:precompile --trace

ln -s /var/www/docker_web_ui/releases/init /var/www/docker_web_ui/current 

/etc/init.d/unicorn.sh stop
/etc/init.d/unicorn.sh start
