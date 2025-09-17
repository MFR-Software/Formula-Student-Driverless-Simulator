FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
USER root

# CMake
RUN apt update &&\
    apt install -y \
        sudo \
        curl \
        wget &&\
    wget -O kitware-cmake.sh https://apt.kitware.com/kitware-archive.sh &&\
    bash kitware-cmake.sh &&\
    apt update &&\
    sudo apt purge --auto-remove cmake &&\
    apt install -y cmake

# Install ROS Jazzy
RUN apt update && apt install locales -y &&\
    locale-gen en_US en_US.UTF-8 &&\
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 &&\
    export LANG=en_US.UTF-8 &&\
    apt install software-properties-common -y &&\
    add-apt-repository universe &&\ 
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg &&\
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null &&\
    apt update && apt upgrade -y &&\
    apt install -y \
        ros-jazzy-desktop \
        python3-colcon-common-extensions \
        python3-pip &&\
    pip3 install rosdep --break-system-packages &&\
    rosdep init && rosdep update

RUN apt-get update && apt-get install -y \
    libyaml-cpp-dev\
    rsync

RUN useradd -m -s /bin/bash -G video,audio ue4 &&\
    echo 'ue4 ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ue4 &&\
    chmod 440 /etc/sudoers.d/ue4

USER ue4    
COPY --chown=ue4:ue4 . /home/ue4/Formula-Student-Driverless-Simulator/
RUN /home/ue4/Formula-Student-Driverless-Simulator/AirSim/setup.sh &&\
    /home/ue4/Formula-Student-Driverless-Simulator/AirSim/build.sh

WORKDIR /home/ue4/Formula-Student-Driverless-Simulator/ros2
RUN source /opt/ros/jazzy/setup.bash &&\
    rosdep update &&\
    rosdep install --from-paths src --ignore-src -ry &&\
    colcon build

RUN sudo apt-get update && sudo apt-get install -y \
    vulkan-tools \
    vulkan-validationlayers \
    mesa-vulkan-drivers \
    vulkan-utility-libraries-dev \
    libvulkan1 \
    libvulkan-dev

RUN sudo apt install tmuxinator tmux xvfb btop -y
WORKDIR /home/ue4/Formula-Student-Driverless-Simulator/