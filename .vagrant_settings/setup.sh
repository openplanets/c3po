#!/bin/bash

##
# NOTES:
##

# [1] the main tasks of this script:
#     --> it installs c3po and assembles the command-line app
#     --> it installs and runs a mongodb server
#     --> it installs and runs the playframework
#     --> it creates a port-forwarded static welcome page with links
#         to all the functionalities above
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
PLAY_GUEST_PORT=$1
MONGOD_GUEST_PORT=$2
MONGOADMIN_GUEST_PORT=$3
WELCOME_GUEST_PORT=$4

##
# variables to be set
##

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
OPEN_JDK=openjdk-7-jdk

PLAY_VERSION=play-2.0.4
PLAY_URL=http://download.playframework.org/releases/$PLAY_VERSION.zip

C3PO_LIB=/opt/c3po
mkdir $C3PO_LIB
C3PO_SHARE=$C3PO_LIB/welcome

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
    if [ -f /vagrant/.vagrant_settings/proxy_settings.conf ]
    then
        echo "[setup.sh] found proxy_settings, installing cntlm.."
        apt-get install -y cntlm
        cp /vagrant/.vagrant_settings/proxy_settings.conf /etc/cntlm.conf
        service cntlm restart
        PROXY_HOST=127.0.0.1
        # copy the 'Listen' port-number from cntlm.conf to use as proxy port
        PROXY_PORT=`grep Listen /vagrant/.vagrant_settings/proxy_settings.conf |grep -o -P '\d*'`
        export HTTP_PROXY=$PROXY_HOST:$PROXY_PORT
    fi
}

function setupMaven {
    echo "[setupt.sh] installing maven.."
    apt-get install -y maven

    # checks whether there's a maven settings file in /vagrant/.vagrant_settings and copies it
    # over if so (in case of proxy settings, etc)

    if [ -f /vagrant/.vagrant_settings/maven_settings.xml ]
    then
        if [ ! -d /home/vagrant/.m2 ]
        then
            mkdir /home/vagrant/.m2 && chown vagrant:vagrant /home/vagrant/.m2
        fi
        echo "[setup.sh] found maven_settings, linking to the settings file.."
        ln -s /vagrant/.vagrant_settings/maven_settings.xml /home/vagrant/.m2/settings.xml
    fi
}

function createCliJar {
    echo "[setup.sh] installing c3po with maven.."
    cd /vagrant
    sudo -u vagrant mvn clean install -DskipTests=true
    echo "[setup.sh] assembling jar-with-dependencies"
    cd c3po-cmd
    sudo -u vagrant mvn assembly:assembly
    echo "[setup.sh] copying cmd jar and creating executable file /usr/local/bin/c3po.."
    cp target/c3po-cmd-*-jar-with-dependencies.jar $C3PO_SHARE/c3po-cmd.jar
    cp /vagrant/.vagrant_settings/c3po /usr/local/bin/
    # replace placeholder for C3PO_SHARE in shellscript with real value
    sed -i.bak s/C3PO_SHARE/$(echo $C3PO_SHARE | sed 's/\//\\\//g')/g /usr/local/bin/c3po
    chmod +x /usr/local/bin/c3po
}

function setupC3poShare {
    echo [setup.sh] setting up http-server for shared files in $C3PO_SHARE

    echo "[setup.sh] ..installing nginx.."
    apt-get install -y nginx

    echo [setup.sh] ..copying nginx defaults to /etc/nginx/sites-available/default..
    cp /vagrant/.vagrant_settings/nginx.default /etc/nginx/sites-available/default
    # replace the placeholder with real c3po_share location
    sed -i.bak s/C3PO_SHARE/$(echo $C3PO_SHARE | sed 's/\//\\\//g')/g /etc/nginx/sites-available/default
    # replace the placeholder with real port for the welcome pages
    sed -i.bak s/WELCOME_GUEST_PORT/$(echo $WELCOME_GUEST_PORT | sed 's/\//\\\//g')/g /etc/nginx/sites-available/default

    echo [setup.sh] ..restarting server..
    service nginx restart
}

function setupWelcomePages {
    echo "[setup.sh] setting up the welcome pages with links to c3po-play, the commandline-jar download and mongoadmin pages"
    cp -r /vagrant/.vagrant_settings/welcome $C3PO_SHARE # this is meant to *create* the directory, so it shouldn't exist yet
    createCliJar
    setupC3poShare
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

function installPlay {
    cd /home/vagrant
    echo "[setup.sh] installing the playframework"
    wget $PLAY_URL
    apt-get install -y unzip
    unzip $PLAY_VERSION.zip
    rm $PLAY_VERSION.zip
    chown -R vagrant /home/vagrant/$PLAY_VERSION
    export PATH=$PATH:/home/vagrant/$PLAY_VERSION
    echo export PATH=$PATH:/home/vagrant/$PLAY_VERSION >> /home/vagrant/.bashrc
    play -h
    echo "[setup.sh] if the play logo is displayed above and it complains about there being no play application it should be installed now"
}

function runPlay {
    echo "[setup.sh] running C3PO on Netty (playframework)"
    echo "[setup.sh] (1) compiling.."
    cd /vagrant/c3po-webapi

    PROXY_ARGS=""
    if [ $HTTP_PROXY ]; then
        PROXY_ARGS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT"
        echo "[setup.sh] set proxy args to $PROXY_ARGS"
    fi

    play $PROXY_ARGS clean compile stage

    echo [setup.sh] \(2\) copying the compiled files to $C3PO_LIB
    mkdir $C3PO_LIB/web_target
    cp -r target/* $C3PO_LIB/web_target

    echo "[setup.sh] (3) starting the server.."
    $C3PO_LIB/web_target/start &
    echo [setup.sh] play started in the vm at localhost:$PLAY_GUEST_PORT/c3po
}

function addAllToNativeStartup {
    # This makes mongodb, play and the welcome pages run on startup of the created
    # vm, which is then independent of a vagrant environment.
    addCustomRcLocal

    # adds nginx, which serves the welcome pages, to startup
    update-rc.d nginx defaults

}

function addCustomRcLocal {
    echo "copying a custom version of rc.local over to vm"
    cp /vagrant/.vagrant_settings/rc.local.custom /etc/rc.local
    # replace the placeholder with real c3po_lib location
    sed -i.bak s/C3PO_LIB/$(echo $C3PO_LIB | sed 's/\//\\\//g')/g /etc/rc.local
    # replace the placeholder with real mongo version
    sed -i.bak s/MONGO_VERSION/$(echo $MONGO_VERSION | sed 's/\//\\\//g')/g /etc/rc.local
}

function installGit {
    echo "[setup.sh] installing git"
    apt-get install -y git tig
}

function installC3poEnv {
    echo "[setup.sh] installing C3PO environment"
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
installPlay
runPlay
setupWelcomePages
addAllToNativeStartup
