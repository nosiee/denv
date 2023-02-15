#!/bin/bash

args=()
file=""
image=""
name=""
gui=false
port=""

for v in "$@"; do
    args+=($v)
done

for (( i=1; i <= ${#args[@]}; i++ )); do
    case ${args[$i]} in
        --file)
            file=${args[$i+1]}
            ;;
        --image)
            image=${args[$i+1]}
            ;;
        --name)
            name=${args[$i+1]}
            ;;
        --gui)
            gui=true
            ;;
        --port)
            port=${args[$i+1]}
            ;;
    esac
done

build() {
    if [[ $file == *"/"* ]]
    then
        filename=$(echo $file | rev | cut -d '/' -f 1 | rev)
        fullpath=${file%"$filename"}

        docker build --file $file $fullpath -t $name
    else
        docker build --file $file . -t $name
    fi
}

add() {
    cmd="docker create"
    it="-it"

    if [[ $port == "" ]]
    then
        port="-p 8080:8080"
    fi

    config_volumes="-v /home/nosiee/.config/nvim:/home/nosiee/.config/nvim
                    -v /home/nosiee/.local/share/nvim:/home/nosiee/.local/share/nvim
                    -v /home/nosiee/.local/state/nvim:/home/nosiee/.local/state/nvim
                    -v /home/nosiee/.tmux.conf:/home/nosiee/.tmux.conf
                    -v /home/nosiee/.ssh:/home/nosiee/.ssh
                    -v /home/nosiee/.gitconfig:/home/nosiee/.gitconfig"

    network="--network bridge"
    container_name="--name $name $image"

    if [ $gui == true ]
    then
        env="-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} -e DISPLAY=${DISPLAY}"
        xorg_volume="-v /tmp/.X11-unix:/tmp/.X11-unix"
        network="--network host"
        port=""

        echo -e "Add xauth token to your container: xauth add $(xauth list)"
    fi

    container_id=$($cmd $env $it $port $config_volumes $xorg_volume $network $container_name)
    echo "Use 'denv run $name/${container_id}' to run the container"
}

run() {
    docker container start -i $1
}

case ${args[0]} in
    build)
        build
        ;;
    add)
        add
        ;;
    run)
        run $2
        ;;
esac
