# ros2_workshop_target
Building Environment & Target Machine
       
* Build docker
    1.docker buildx build --add-host=raw.githubusercontent.com:185.199.111.133 --progress=plain -t c6supper/ros2_workshop_target -f docker/Dockerfile ./
    
* Build release docker
    1. change the version
    2. ./build-env/build.sh c6supper ros2_workshop_target release

