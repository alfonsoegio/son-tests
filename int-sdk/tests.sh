#!/bin/bash

# run sdk-catalogue services in docker containers
cd int-sdk-catalogue
docker-compose down
docker-compose up -d
cd ..

# run son-emu in a docker container in the background, expose fake GK and management API
sudo docker stop son-emu-int-test
sudo docker rm son-emu-int-test
sudo docker run -d -i --name 'son-emu-int-test' --net='host' --pid='host' --privileged='true' \
    -v '/var/run/docker.sock:/var/run/docker.sock' \
    -p 5000:5000 \
    -p 4242:4242 \
    registry.sonata-nfv.eu:5000/son-emu 'python src/emuvim/examples/sonata_y1_demo_topology_1.py'


# run son-cli in a docker container
sudo docker stop son-cli-int-test
sudo docker rm son-cli-int-test
sudo docker run -d -i --name 'son-cli-int-test' --net='host' --pid='host' --privileged='true' \
    -v '/var/run/docker.sock:/var/run/docker.sock' \
    registry.sonata-nfv.eu:5000/son-cli

# prepare son-cli-int-test container for tests
docker cp int-sdk son-cli-int-test:/
docker exec son-cli-int-test apt-get install -y curl unzip

# execute tests
docker exec son-cli-int-test /bin/bash -c 'cd /int-sdk; ./run-tests.sh'