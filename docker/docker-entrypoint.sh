#!/bin/sh

set -ex

patch_conf() {
    mkdir -p $ROS2_WORKSHOP_TARGET_CODE_DIR/ros2_humble/src && \
    cd $ROS2_WORKSHOP_TARGET_CODE_DIR/ros2_humble && \
    while ! vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src; do echo retrying; done && \
    echo $PASS | sudo -S mkdir -p /etc/ros/rosdep/sources.list.d/ && \
    echo $PASS | sudo -S curl -o /etc/ros/rosdep/sources.list.d/20-default.list https://mirrors.tuna.tsinghua.edu.cn/github-raw/ros/rosdistro/master/rosdep/sources.list.d/20-default.list && \
    export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml && \
    echo $PASS | sudo -S apt-get update && \
    echo $PASS | sudo -S apt-get install -y python3-lark libeigen3-dev \
        libssl-dev libtinyxml2-dev libasio-dev qtbase5-dev python3-pytest-timeout \
        python3-numpy python3-cairo python3-nose libcunit1-dev libspdlog-dev \
        libignition-cmake2-dev doxygen libqt5core5a libqt5gui5 libqt5opengl5 \
        libqt5widgets5 python3-matplotlib pydocstyle qt5-qmake libcurl4-openssl-dev \
        python3-babeltrace libsqlite3-dev python3-lxml python3-cryptography \
        python3-pygraphviz python3-pydot python3-netifaces graphviz tango-icon-theme \
        pybind11-dev libyaml-dev libbenchmark-dev acl libacl1-dev libopencv-dev \
        libconsole-bridge-dev libtinyxml-dev libpyside2-dev libshiboken2-dev \
        pyqt5-dev python3-pyqt5 python3-pyqt5.qtsvg python3-pyside2.qtsvg \
        python3-sip-dev shiboken2 python3-pykdl liborocos-kdl-dev libassimp-dev \
        libignition-math6-dev python3-lttng google-mock libxml2-utils uncrustify \
        python3-psutil clang-format clang-tidy libyaml-cpp-dev libbullet-dev \
        libxaw7-dev libxrandr-dev libgl1-mesa-dev libfreetype6-dev clang-format \
        libgtest-dev python3-mypy python3-pytest-mock cppcheck libzstd-dev && \
    while ! rosdep update;do echo retrying; done && \
    while ! rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers";do echo retrying; done && \
    touch $ROS2_WORKSHOP_TARGET_INITIALIZED_MARK && \
    echo 'export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml' >> ~/.bashrc && \
    echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc && \
    cd $ROS2_WORKSHOP_TARGET_DIR/ros2_humble && \
    while ! colcon build --symlink-install --parallel-workers 16;do echo retrying; done;
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