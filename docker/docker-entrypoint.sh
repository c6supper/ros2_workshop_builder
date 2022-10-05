#!/bin/sh

set -ex

patch_conf() {
    
    if [ ! -d "/opt/ros2_workshop_target704/target/ros2_workshop_target7" ]; then
        cd /opt/ && echo $PASS | sudo -S tar -xf ros2_workshop_target700_host.tar.xz;echo $PASS | sudo -S rm -f ros2_workshop_target700_host.tar.xz;
        cd /opt/ && echo $PASS | sudo -S tar -xf ros2_workshop_target_license.tar.gz;echo $PASS | sudo -S rm -f ros2_workshop_target_license.tar.gz;
        echo $PASS | sudo -S mkdir -p /opt/ros2_workshop_target704/target/;
        echo $PASS | sudo -S ln -s /opt/ros2_workshop_target700_host/target/ros2_workshop_target7/aarch64le /opt/ros2_workshop_target704/target/ros2_workshop_target7
        echo $PASS | sudo -S chown -R $APP_USER:$APP_USER /opt/*;
        echo $PASS | sudo -S chown -R $APP_USER:$APP_USER /opt/.ros2_workshop_target/*;
        echo $PASS | sudo -S ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime;
    fi
    export DEBIAN_FRONTEND=noninteractive;
    DEBIAN_FRONTEND=noninteractive echo $PASS | sudo -S apt install -y sudo rename locales \
    autoconf wget libtool libtool-bin autopoint openjdk-8-jdk \
    subversion astyle gettext python3 libdbus-1-dev unzip bison \
    nano git g++ golang libssl-dev build-essential && \
    echo $PASS | sudo -S dpkg-reconfigure --frontend noninteractive tzdata && \
    echo $PASS | sudo -S locale-gen en_US.UTF-8 && \
    echo "export GOPATH=$HOME/go" >> ~/.bashrc && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java" >> ~/.bashrc  && \
    cd /tmp && wget https://cmake.org/files/v3.23/cmake-3.23.0.tar.gz --retry-connrefused -qO - | tar xz && \
    cd cmake-3.23.0 && ./configure && make -j16 && echo $PASS | sudo -S make install && \
    cd / && rm -rf /tmp/cmake* && \
    touch $ROS2_WORKSHOP_TARGET_INITIALIZED_MARK && \
    echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc && \
    echo "source /opt/setenv_64.sh --external /opt/ros2_workshop_target700_host" >> ~/.bashrc;

    # go get -u github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc;
}

if [ ! -f "$ROS2_WORKSHOP_TARGET_INITIALIZED_MARK" ]; then
    patch_conf
    echo
    echo 'building env init process complete; ready for start up.'
    echo
else
    echo
    echo 'Skipping initialization'
    echo
    echo 'done'
    echo
    
fi

/bin/sh -c "$@"