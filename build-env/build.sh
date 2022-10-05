
#!/bin/sh

set -ex

if [ "$#" -lt  "2" ]
  then
    echo "You have not input the user and image."
    exit
fi

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run

retry() {
    local -r -i max_attempts="$1"; shift
    local -i attempt_num=1
    until "$@"
    do
        if ((attempt_num==max_attempts))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $((attempt_num++))
        fi
    done
}

NAME=$1
IMAGE=$2

version=$(cat docker/version)
echo "version: $version"
DIR="$(dirname "$(readlink -f "$0")")"

docker build -t $NAME/$IMAGE -t $NAME/$IMAGE:$version -f ./docker/Dockerfile ./ --build-arg LIVENESS_PROBE="$(cat ${DIR}/tcp-port-wait.sh)"

if [ "$#" -ge  "2" ]
  then
    retry 100 docker login --username=c6supper@hotmail.com registry.cn-hangzhou.aliyuncs.com
    # retry 100 docker push $NAME/$IMAGE:latest
    # retry 100 docker push $NAME/$IMAGE:$version
    retry 100 docker tag $NAME/$IMAGE:latest registry.cn-hangzhou.aliyuncs.com/$NAME/$IMAGE:latest
    retry 100 docker tag $NAME/$IMAGE:$version registry.cn-hangzhou.aliyuncs.com/$NAME/$IMAGE:$version
    retry 100 docker push registry.cn-hangzhou.aliyuncs.com/$NAME/$IMAGE:$version
    retry 100 docker push registry.cn-hangzhou.aliyuncs.com/$NAME/$IMAGE:latest
fi

