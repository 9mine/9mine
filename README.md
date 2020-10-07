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

2.  Choose certifying authority (CA). By default, this branch uses remote CA - `signer.metacoma.io`. For using local CA, please, follow instruction in https://github.com/9mine/9mine-auth

3.  Run local inferno instance with cmdchan. This can be done by running container

        docker run --rm -ti --name --network $NETWORK_NAME getauth -p 1917:1917 --name local dievri/inferno-os:getauth

    Image for container built from the branch https://github.com/9mine/inferno-os/tree/getauth For adding cmdchan to existing inferno OS, please, use as a reference https://github.com/9mine/inferno-os/blob/getauth/profile

4.  Run minetest server with plain authentication mechanism and mods enabled (this branch)

        docker run --rm -ti --network $NETWORK_NAME --name mt-server -p 30000:30000/udp dievri/minetest:auth

    During startup auth mod will be loaded which will connect to local inferno OS and mount exposed files from CA. (curently cmdchan and newuser).

    For overriding defaults for CA and local inferno, mount `auth.conf` to the `/root/.minetest/mods/auth/mod.conf`

        docker run --rm -ti --network $NAME -v /path/to/auth.conf:/root/.minetest/mods/auth/mod.conf --name mt-server -p 30000:30000/udp dievri/minetest:auth

5.  Allow local xhost and run minetest client. Use `mt-server` for hostname and `30000` for port.  

        xhost +local: && docker run --rm -ti --network $NETWORK_NAME -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix dievri/minetest:client

# Automated run with remote CA
0. Use [docker-compose](https://docs.docker.com/compose/)

1. Download [docker-compose.yml](https://github.com/9mine/9mine/blob/auth/docker-compose.yml)

2. Allow localhost to make connections to the X server

        xhost +local:

3.  Update images 
        
        docker-compose pull

4. Run local inferno, client and server 

        docker-compose up

5. In minetest client use `mt-server` for hostname and `30000` for port.  

# Build images manually 

## Server

1. Clone this branch with all it submodules and cd into directory 

        git clone --recurse-submodules --remote-submodules -b auth https://github.com/9mine/9mine.git

2. For build image with custom `auth.conf` file, uncomment COPY line in Dockerfile. Use can specify custom version string by replacing `${BRANCH} ${COMMIT_VERSION} ${DATE}` with your string. Build image

                docker image build -t <image_name> .

3. After build you can check build string:


                docker run <image_name> --version

## Client

1. Clone branch `client` and cd into directory 

        git clone -b client https://github.com/9mine/9mine.git

2. Build image 

         docker image build -t <image_name> .

## Certyfing Authority

1. Clone `changelogin_noninteractive` branch from [inferno-os](https://github.com/9mine/inferno-os) repository and cd into directory

        git clone -b changelogin_noninteractive https://github.com/9mine/inferno-os.git

2. Image to be built could be used with [script](https://github.com/9mine/9mine-auth).

    For using with script cd into directory and run

        docker image build -t <image_name> .

    Clone [9mine-auth](https://github.com/9mine/9mine-auth) repository and cd into directory 

        git clone https://github.com/9mine/9mine-auth.git

   Change `dievri/inferno-os:changelogin_noninteractive` to `<image_name>` and follow instructions in that repository

3. For using without script add the following line to the Dockerfile
        
        COPY profile /usr/inferno-os/lib/sh/profile

4. Copy https://github.com/9mine/9mine-auth/blob/master/profile into current directory.

5. Build image 

        docker image build -t <image_name> .

6. Use instructions from the [first section](https://github.com/9mine/9mine/tree/auth#run-minetest-with-inferno-as-authentication-manually-using-containers) substituting provided image names with your own image names.