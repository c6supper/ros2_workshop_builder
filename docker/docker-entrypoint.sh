#!/bin/sh

set -ex

patch_conf() {
    mkdir -p $ROS2_WORKSHOP_TARGET_CODE_DIR/ros2_humble/src &&
        cd $ROS2_WORKSHOP_TARGET_CODE_DIR/ros2_humble &&
        while ! vcs import --input https://raw.githubusercontent.com/c6supper/ros2/humble_workshop/ros2.repos src; do echo retrying; done &&
        colcon_ignore &&
        echo $PASS | sudo -S mkdir -p /etc/ros/rosdep/sources.list.d/ &&
        echo $PASS | sudo -S curl -o /etc/ros/rosdep/sources.list.d/20-default.list https://mirrors.tuna.tsinghua.edu.cn/github-raw/ros/rosdistro/master/rosdep/sources.list.d/20-default.list &&
        export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml &&
        echo $PASS | sudo -S apt-get update &&
        echo $PASS | sudo -S apt-get install -y libtinyxml-dev python3-pytest libeigen3-dev libssl-dev \
            libtinyxml2-dev python3-dev libasio-dev cmake python3-pytest-timeout \
            python3-argcomplete python3-importlib-metadata python3-netifaces \
            python3-packaging python3-pkg-resources python3-catkin-pkg-modules \
            python3-psutil python3-rosdistro-modules python3-pytest-mock \
            python3-mypy libspdlog-dev pyflakes3 pkg-config python3-pytest-cov \
            python3-yaml libignition-math6-dev git graphviz libopencv-dev \
            python3-pycodestyle python3-lxml python3-cryptography \
            python3-minimal python3-numpy libyaml-dev acl libacl1-dev \
            libatomic1 python3-lark libbullet-dev libbenchmark-dev pydocstyle \
            python3-nose libsqlite3-dev python3-lttng pybind11-dev \
            libconsole-bridge-dev python3-empy clang-tidy libignition-cmake2-dev \
            doxygen google-mock python3-babeltrace clang-format cppcheck \
            libyaml-cpp-dev libxml2-utils liborocos-kdl-dev python3-setuptools \
            python3-flake8 python3-pykdl libzstd-dev libcurl4-openssl-dev \
            curl file uncrustify libgtest-dev &&
        while ! rosdep update; do echo retrying; done &&
        while ! rosdep install --rosdistro humble --from-paths src --ignore-src -y --skip-keys "rmw_cyclonedds_cpp fastcdr cyclonedds rmw_opensplice_cpp rosidl_typesupport_opensplice_c rosidl_typesupport_opensplice_cpp rti-connext-dds-6.0.1 urdfdom_headers"; do echo retrying; done &&
        touch $ROS2_WORKSHOP_TARGET_INITIALIZED_MARK &&
        echo 'export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml' >>~/.bashrc &&
        echo "export PATH=$PATH:/usr/local/bin" >>~/.bashrc &&
        welcome_message="ROS2 Target is ready. Please chek ROS2 source code in $ROS2_WORKSHOP_TARGET_CODE_DIR
        How to Build?
        Run cd $ROS2_WORKSHOP_TARGET_CODE_DIR/ros2_humble && colcon build --symlink-install --parallel-workers 16" &&
        cat <<EOT >>~/.bashrc
export welcome_message="$welcome_message"
echo "$welcome_message"
EOT
    echo "done!"
}

colcon_ignore() {
    # echo 'Ignoring CycloneDDS'
    # touch src/eclipse-cyclonedds/COLCON_IGNORE
    # touch src/ros2/rmw_cyclonedds/COLCON_IGNORE

    # echo 'Ignoring ros-visualization'
    # touch src/ros-visualization/COLCON_IGNORE

    # echo 'Ignoring ros-perception'
    # touch src/ros-perception/COLCON_IGNORE

    # echo 'Ignoring ros-planning'
    # touch src/ros-planning/COLCON_IGNORE

    # echo 'Ignoring rviz'
    # touch src/ros2/rviz/COLCON_IGNORE

    echo 'Ignoring turtlesim'
    touch src/ros/ros_tutorials/turtlesim/COLCON_IGNORE
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
