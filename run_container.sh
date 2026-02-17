docker rm -f latentfusion
DIR=$(pwd)/
xhost +local:1000 && docker run --name latentfusion --gpus all -it -v /home:/home latentfusion bash -c "cd $DIR && bash" -e DISPLAY="$DISPLAY" \
-v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    --network=host \
    --ipc=host