#!/usr/bin/env bash

main(){
    check
    if [[ "$(type -t "$2")" = function ]]; then
        $2 $@
    else
        show_help
    fi
}

check(){
    if [[ -z "$TARGET_HOST" ]]; then
        echo "\$TARGET_HOST environment variable not set"
        exit 1
    fi
}


rdo(){
    ssh $TARGET_HOST "cd $TARGET_PATH; $3"
}

copy(){
    if [[ -z "$3" ]]; then
        echo "Source is not set. Please check documentation"
        exit 1
    fi
    if [[ -z "$4" ]]; then
        echo "Destination is not set. Please check documentation"
        exit 1
    fi
    scp $3 "${TARGET_HOST}:${TARGET_PATH}${4}"
}

show_help(){
echo -e "
cibu compose <SUBCOMMAND> [args...]
docker-compose related commands
SUBCOMMANDS:
login <login> <password> <registry>
    Run docker login on remote server
    Example cibu compose login user password registry.gitlab.com
    Will run ssh \$TARGET_HOST docker login -u user -p password registry.gitlab.com
upload [suffix]
    Upload docker-compose file with target suffix (if provided) to remote server.
    Example: cibu compose upload qa
    Will run scp docker-compose-qa.yml \$TARGET_HOST:\$TARGET_PATH/docker-compose.yml
pull [docker-compose pull argumets]
    Perform a 'docker-compose pull' with arguments (if provided) on remote server in selected dir
    Example: cibu compose pull --parallel
    Will run ssh \$TARGET_HOST 'cd \$TARGET_PATH; docker-compose pull --parallel'
remove <service>
    Stop and remove selected service
    Example: cibu compose remove redis
    Will run ssh \$TARGET_HOST 'cd \$TARGET_PATH; docker-compose stop redis; docker-compose rm -f redis'
up [docker-compose up args...]
    Run docker-compose up command on target server
    Example: cibu compose up --force-recreate
    Will run ssh \$TARGET_HOST 'cd \$TARGET_PATH; docker-compose up --force-recreate'
update <service>
    Stop, remove and recreate selected service
    Example: cibu compose update redis
    Will run ssh \$TARGET_HOST 'cd \$TARGET_PATH; docker-compose stop redis; docker-compose rm -f redis; docker-compose up -d --force-recreate --remove-orphans --no-deps redis'
cleanup
    Run docker system prune and clean volumes marked to remove
    Example: cibu compose cleanup
    Will run ssh \$TARGET_HOST 'docker system prune -a -f; rm -rf /var/lib/docker/aufs/diff/*-removing'
"
}