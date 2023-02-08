#!/bin/bash

build () {
    docker build -f $1 . -t $2

    if [ "$3" = "gui" ] 
    then
        docker create \
            -e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
            -e DISPLAY=${DISPLAY} \
            -it \
            -v /home/nosiee/.config/nvim:/home/nosiee/.config/nvim \
            -v /home/nosiee/.local/share/nvim:/home/nosiee/.local/share/nvim \
            -v /home/nosiee/.local/state/nvim:/home/nosiee/.local/state/nvim \
            -v /home/nosiee/.tmux/plugins/:/home/nosiee/.tmux/plugins \
            -v /home/nosiee/.tmux.conf:/home/nosiee/.tmux.conf \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            --network host \
            --name $2 \
            $2

        echo "Add the following xauth token to your container: xauth add <token>"
        xauth list
    else
        docker create \
            -p 8080:8080 \
            -it \
            -v /home/nosiee/.config/nvim:/home/nosiee/.config/nvim \
            -v /home/nosiee/.local/share/nvim:/home/nosiee/.local/share/nvim \
            -v /home/nosiee/.local/state/nvim:/home/nosiee/.local/state/nvim \
            -v /home/nosiee/.tmux/plugins/:/home/nosiee/.tmux/plugins \
            -v /home/nosiee/.tmux.conf:/home/nosiee/.tmux.conf \
            --name $2 \
            $2
    fi
}

run () {
    docker start -i $1
}

prune() {
    docker rm $1
}

case $1 in
    build)
        build $2 $3 $4
        ;;
    run)
        run $2
        ;;
    prune)
        prune $2
        ;;
esac
