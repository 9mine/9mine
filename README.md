# Run Minetest with inferno as authentication manually using containers

0.  Use latest images

    - server

            docker pull dievri/minetest:auth

    - client

            docker pull dievri/minetest:client

    - inferno OS

            docker pull dievri/inferno-os:getauth

1.  Create network for minetest

        docker network create $NETWORK_NAME

2.  Choose signing authority (CA). By default, this branch uses remote CA. For using local CA, please, follow instruction in https://github.com/9mine/9mine-auth

3.  Run local inferno instance with cmdchan. This can be done by running container

        docker run --rm -ti --name --network $NETWORK_NAME getauth -p 1917:1917 --name local dievri/inferno-os:getauth

    Image for container built from the branch https://github.com/9mine/inferno-os/tree/getauth For adding cmdchan to existing inferno OS, please, use as a reference https://github.com/9mine/inferno-os/blob/getauth/profile

4.  Run minetest server with plain authentication mechanism and mods enabled (this branch)

        docker run --rm -ti --network $NETWORK_NAME --name mt-server -p 30000:30000/udp dievri/minetest:auth

    During startup auth mod will be loaded which will connect to local inferno OS and mount exposed files from CA. (curently cmdchan and newuser).

    For overriding defaults for CA and local inferno, mount `auth.conf` to the `/root/.minetest/mods/auth/mod.conf`

        docker run --rm -ti --network $NAME -v /path/to/auth.conf:/root/.minetest/mods/auth/mod.conf --name mt-server -p 30000:30000/udp dievri/minetest:auth

5.  Allow local xhost and run minetest client

        xhost +local: && docker run --rm -ti --network $NETWORK_NAME -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix dievri/minetest:client

# Automated run with remote CA
1. Use [docker-compose](https://docs.docker.com/compose/)

2.  Update images 
        
        docker-compose pull

3. Run local inferno, client and server. Following command will create docker images with names: 

        docker-compose up

