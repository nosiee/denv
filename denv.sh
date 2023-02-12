#!/bin/bash

build () {
    docker build -f $1 . -t $2

    cmd="docker create"
    it="-it"
    p="-p 8080:8080"
    config_volumes="-v /home/nosiee/.config/nvim:/home/nosiee/.config/nvim
                    -v /home/nosiee/.local/share/nvim:/home/nosiee/.local/share/nvim
                    -v /home/nosiee/.local/state/nvim:/home/nosiee/.local/state/nvim
                    -v /home/nosiee/.tmux.conf:/home/nosiee/.tmux.conf
                    -v /home/nosiee/.ssh:/home/nosiee/.ssh
                    -v /home/nosiee/.gitconfig:/home/nosiee/.gitconfig"

    network="--network bridge"
    name="--name $3 $2"

    if [ "$4" = "gui" ]
    then
        env="-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} -e DISPLAY=${DISPLAY}"
        xorg_volume="-v /tmp/.X11-unix:/tmp/.X11-unix"
        network="--network host"
        p=""

        token=$(xauth list)
        echo -e "\nAdd xauth token to your container: xauth add ${token}"
    fi

    container_id=$($cmd $env $it $p $config_volumes $xorg_volume $network $name)
    echo "Use 'denv run $3/${container_id}' to run the container"
}

run () {
    docker start -i $1
}

prune() {
    echo "Are you sure you want to delete all stopped containers?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes) 
                docker rm $(docker ps --filter status=exited -q)
                break
                ;;
            No)
                exit
                ;;
        esac
    done
}

case $1 in
    build)
        build $2 $3 $4 $5
        ;;
    run)
        run $2
        ;;
    prune)
        prune
        ;;
esac
