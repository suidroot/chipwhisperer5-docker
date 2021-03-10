# chipwhisperer5-docker
A dockerized chipwhisperer 5 for easy installation.

## Disclaimer

This docker image is running in privileged mode and can pwn the host machine.

The dockerized chipwhisperer should only be run on a trusted machine. The password to Jupyter is currently passed in cleartext via the environment. Also note that the default `run.sh` exposes the Jupyter notebook on the network, and not just locally. The notebook is also served via *HTTP*, so authentication tokens are sent *unencrypted*.

## Install

To install, simply copy and load the newae udev rules and build the docker image:

```
sudo cp 99-newae.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
docker build -t <yourtagname> .
```

Edit the `run.sh` and change the DOCKER_IMAGE variable to the tag you chose when building the container

## Run

To run, simply run `run.sh` with a supplied authentication token and a directory that should be used as the workspace. Make sure that you supply an *absolute* path.

```
./run.sh start testpassword /home/chipwhisperer/chipwhisperer
```

## Open Container Shell
To access a bash shell in the conatiner run the command:
```
./run.sh connect
```

## Use

The Jupyter Notebook should then be running on port 8888. You can visit it by simply going to

http://127.0.0.1:8888/

## Full installation example:

```
sudo cp 99-newae.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
docker build -t suidroot/cw .

# Clone example projects
git clone --recursive https://github.com/newaetech/chipwhisperer.git
./run.sh start testpassword ${PWD}/chipwhisperer

# Now go to http://127.0.0.1:8888/ in a browser!
```
