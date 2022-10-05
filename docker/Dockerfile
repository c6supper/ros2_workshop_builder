ARG UBUNTU_VER=focal
ARG BUILD_DIR=/code/
ARG DEBIAN_FRONTEND=noninteractive
ARG APP_USER=c6supper
ARG PASS="none"

FROM arm64v8/ubuntu:${UBUNTU_VER} AS prepare-builder
ARG DEBIAN_FRONTEND
ARG APP_USER
ARG PASS
RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
    sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
    sed -i "s@http://ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install locales xz-utils tzdata sudo && \
    locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && DEBIAN_FRONTEND=noninteractive locale && \
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    useradd --groups sudo -m -s /bin/bash $APP_USER && echo "$APP_USER:$PASS" | chpasswd && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    apt install -y software-properties-common && add-apt-repository universe && \
    apt-get update -y && apt-get install -y curl gnupg lsb-release

FROM prepare-builder AS prepare-ros2-builder
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu focal main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt update -y && apt install -y \
    build-essential cmake git python3-colcon-common-extensions \
    python3-flake8 python3-pip python3-pytest-cov python3-rosdep python3-setuptools \
    python3-vcstool wget && \
    python3 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip install -U flake8-blind-except flake8-builtins \
    flake8-class-newline flake8-comprehensions flake8-deprecated flake8-docstrings \
    flake8-import-order flake8-quotes pytest-repeat pytest-rerunfailures pytest \
    setuptools

FROM prepare-ros2-builder AS prepare-ros2-source
ARG APP_USER
ARG PASS
USER $APP_USER
RUN mkdir -p ~/ros2_humble/src && \
    cd ~/ros2_humble && \
    while ! vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src; do echo retrying; done && \
    echo $PASS | sudo -S mkdir -p /etc/ros/rosdep/sources.list.d/ && \
    echo $PASS | sudo -S curl -o /etc/ros/rosdep/sources.list.d/20-default.list https://mirrors.tuna.tsinghua.edu.cn/github-raw/ros/rosdistro/master/rosdep/sources.list.d/20-default.list && \
    export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml && \
    rosdep update && \
    echo 'export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml' >> ~/.bashrc && \
    rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

FROM prepare-ros2-source AS builder
ARG APP_USER
ARG PASS
USER $APP_USER
RUN cd ~/ros2_humble/ && \
    colcon build --symlink-install --parallel-workers 16

FROM builder AS ros2-workshop-target
ARG APP_USER
ARG PASS
USER $APP_USER

ARG LIVENESS_PROBE

USER $APP_USER

ENV ROS2_WORKSHOP_TARGET_DIR /ros2_workshop_target
ENV ROS2_WORKSHOP_TARGET_INITIALIZED_MARK $ROS2_WORKSHOP_TARGET_DIR/patched
COPY --chown=$APP_USER docker/version $ROS2_WORKSHOP_TARGET_DIR/version
COPY --chown=$APP_USER docker/docker-entrypoint.sh $ROS2_WORKSHOP_TARGET_DIR/docker-entrypoint.sh

# initilization for the first time
ENTRYPOINT ["/ros2_workshop_target/docker-entrypoint.sh"]

CMD ["/usr/bin/bash"]