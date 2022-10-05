#!/bin/bash
#set -e
set -o allexport
source "./.env"
set +o allexport

__usage="
Usage: $(basename $0) [OPTIONS]
Options(optional only for debug purpose):
"
echo "$__usage"

until [ $# -eq 0 ]
do
  name=${1:1}; shift;
  if [[ -z "$1" || $1 == -* ]] ; then eval "export $name=true"; else eval "export $name=$1"; shift; fi
done

env | while read line; do
  if [ ! -z "$line" ] ; then
    if [[ $line == *"_VOLUME="* ]]; then
      echo "$line" | awk 'BEGIN { FS = "=" } ; { system("mkdir -p \""$2"\"") }'
    fi
  fi
done

#generate the yaml file, and validate the configuration
cat ros2_workshop_target.template.yaml | DOLLAR='$' envsubst > docker-compose.yml
docker-compose -f docker-compose.yml config > /dev/null
if [ $? -eq 0 ]
then
    echo "docker-compose.yml passed validation."
else
    echo "Your docker-compose file got error, please check."
fi

#restart the services
docker stop `docker ps -aq -f name=ros2_workshop_target_*`
docker rm `docker ps -aq -f name=ros2_workshop_target_*`
docker network prune -f
docker-compose -p "ros2_workshop_target" up -d
