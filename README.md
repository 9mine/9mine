# Run minetest with inferno as authentication backend manually using provided containers

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

# Run minetest with inferno as authentication backend manually building docker images

## Server Image

1. Clone this branch with all it submodules and cd into directory 

        git clone --recurse-submodules --remote-submodules -b auth https://github.com/9mine/9mine.git

2. For build image with custom `auth.conf` file, uncomment COPY line in Dockerfile. Use can specify custom version string by replacing `${BRANCH} ${COMMIT_VERSION} ${DATE}` with your string. Build image

                docker image build -t <image_name> .

3. After build you can check build string:


                docker run <image_name> --version

## Client Image

1. Clone branch `client` and cd into directory 

        git clone -b client https://github.com/9mine/9mine.git

2. Build image 

         docker image build -t <image_name> .

## Certifying Authority Image

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

6. Use instructions from the [first section](https://github.com/9mine/9mine/tree/auth#run-minetest-with-inferno-as-authentication-backend-manually-using-provided-containers) substituting provided image names with your own image names.

# Run minetest with inferno as authentication backend without images 
## Compile and install minetest server and server
1. Install lua 5.1
2. Compile minetestserver using branch [stable-5](https://github.com/9mine/minetest/tree/stable-5) from 9mine/minetest repository. Follow instruction from there for build.
3. Compile minetest client using branch [plan_auth_method](https://github.com/9mine/minetest/tree/plan_auth_method) from 9mine/minetest repository. Follow instruction from there for build.
4. Clone this branch and cd into it
        git clone -b auth https://github.com/9mine/9mine.git

5. Copy content of `libs` to `/usr/local/share/lua/5.1/`
6. Copy `mods` to the `${HOME}/.minetest/`
7. Copy `minetest.conf` to the `${HOME}/.minetest/minetest.conf`
8. Copy `worlds` to the `${HOME}/.minetest/`

9. Compile [luadata](https://github.com/lneto/luadata) using [instructions](https://github.com/9mine/9mine/blob/57a340e81f16be3361d19c6a2ae593f25cf7d697/Dockerfile#L22) from Dockerfile. Copy compiled `data.so` to the `/usr/local/lib/lua/5.1/`

10. Install [luarocks](https://github.com/luarocks/luarocks)

11. With `luarocks` install `luasocket` `luabitop` `lua-filesize`

        luarocks install luasocket
        luarocks install luabitop 
        luarocks install lua-filesize

## Compile and configure inferno OS as Certifying authority (CA)
1. Configure inferno instance OS as certifying authority - clone branch `changelogin_noninteractive` from `inferno-os` repository  

        git clone -b changelogin_noninteractive https://github.com/9mine/inferno-os.git

2. Follow instructions from there to build inferno OS (you may use [Dockerfile](https://github.com/9mine/inferno-os/blob/changelogin_noninteractive/Dockerfile) as a reference)

3. copy [profile](https://github.com/9mine/9mine-auth/blob/master/profile) to the ${INFERNO_ROOT}/lib/sh/

4. Run CA (use [auth.sh](https://github.com/9mine/9mine-auth/blob/master/auth.sh) as a reference)

## Compile and configure local inferno instance
1. Clone branch `getauth` from `inferno-os` repository and follow instruction from there to build inferno os.

        git clone -b getauth https://github.com/9mine/inferno-os.git

2. Copy `profile` from root repository directory to the ${INFERNO_ROOT}/lib/sh/

## Run complete set
1. Run CA (certifying authority)
2. Run local inferno instance
3. Run `minetestserver`
4. Run `minetest`