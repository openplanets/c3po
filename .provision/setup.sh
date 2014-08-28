#!/bin/bash

##
# NOTES:
##

# [1] the main tasks of this script:
#     --> it installs and runs a mongodb server
#     --> it adds all above to the native ubuntu startup, so that an
#         image of the vm can theoretically be run independently from
#         the vagrant environment

# [2] in case you're behind a proxy:
#     --> have a look at http://tmatilai.github.io/vagrant-proxyconf/
#     --> for some authenticated proxies the only working solution I've
#         found is cntlm; put a proxy_settings.conf in the root dir,
#         it will be found and copied over to /etc/cntlm.conf; in this
#         case maven settings.xml has to point to localhost and the port
#         specified in cntlm.conf, without username and password!

##
# variables from Vagrantfile
##
MONGOD_GUEST_PORT=$1
MONGOADMIN_GUEST_PORT=$2

##
# variables to be set
##
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
OPEN_JDK=openjdk-7-jdk
MONGO_VERSION=mongodb-linux-x86_64-2.0.5

##
# function definitions
##

function updateSource {
    echo "[setup.sh] retrieving ubuntu updates.."
    apt-get update
}

function installJavaDevEnv {
    echo "[setup.sh] installing java dev environment"
	echo "[setup.sh] ..open jdk.."
	apt-get install -y $OPEN_JDK
}

function checkProxy {
    # in case you're behind a (e.g. nmlt) proxy, this is a way to have maven working
    if [ -f /vagrant/.provision/proxy_settings.conf ]
    then
        echo "[setup.sh] found proxy_settings, installing cntlm.."
        apt-get install -y cntlm
        cp /vagrant/.provision/proxy_settings.conf /etc/cntlm.conf
        service cntlm restart
        PROXY_HOST=127.0.0.1
        # copy the 'Listen' port-number from cntlm.conf to use as proxy port
        PROXY_PORT=`grep Listen /vagrant/.provision/proxy_settings.conf |grep -o -P '\d*'`
        export HTTP_PROXY=$PROXY_HOST:$PROXY_PORT
    fi
}

function setupMaven {
    echo "[setupt.sh] installing maven.."
    apt-get install -y maven

    # checks whether there's a maven settings file in /vagrant/.provision and copies it
    # over if so (in case of proxy settings, etc)

    if [ -f /vagrant/.provision/maven_settings.xml ]
    then
        if [ ! -d /home/vagrant/.m2 ]
        then
            mkdir /home/vagrant/.m2 && chown vagrant:vagrant /home/vagrant/.m2
        fi
        echo "[setup.sh] found maven_settings, linking to the settings file.."
        ln -s /vagrant/.provision/maven_settings.xml /home/vagrant/.m2/settings.xml
    fi
}


function setupMongoDB {
    echo "[setup.sh] installing mongodb.."
    setupMongoDB_2_0_5
}

function setupMongoDB_2_0_5 {
    # doesn't work with default ubuntu packages, manual install is one way of doing it
    cd /home/vagrant
    echo "[setup.sh] installing mongodb 2.0.5 (manual install).."
    wget http://downloads.mongodb.org/linux/$MONGO_VERSION.tgz
    tar xvfz $MONGO_VERSION.tgz
    rm $MONGO_VERSION.tgz
    export PATH=$PATH:/home/vagrant/$MONGO_VERSION/bin/
    mkdir -p /data/db
    chown -R vagrant /data/db
    echo "[setup.sh] starting the mongodb server.."
    mongod & >> /home/vagrant/mongod.log
}

function ensureCorrectJavaVersion {
    echo [setup.sh] setting $JAVA_HOME as default
    echo setting java to $JAVA_HOME
    sudo update-alternatives --set java $JAVA_HOME/jre/bin/java
}


function addAllToNativeStartup {
    # This makes mongodb, play and the welcome pages run on startup of the created
    # vm, which is then independent of a vagrant environment.
    addCustomRcLocal
}

function addCustomRcLocal {
    echo "copying a custom version of rc.local over to vm"
    cp /vagrant/.provision/rc.local.custom /etc/rc.local
    # replace the placeholder with real mongo version
    sed -i.bak s/MONGO_VERSION/$(echo $MONGO_VERSION | sed 's/\//\\\//g')/g /etc/rc.local
}


##
# calling the functions..
##

updateSource
installJavaDevEnv
checkProxy
setupMaven
setupMongoDB
ensureCorrectJavaVersion
addAllToNativeStartup
