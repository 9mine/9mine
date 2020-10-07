# Run Minetest with inferno as authentication manually using containers
0. Use latest images
    * server

            docker pull dievri/minetest:auth
    * client 

            docker pull dievri/minetest:client-x
    * inferno OS

            docker pull dievri/inferno-os:getauth

1. Create network for minetest 

        docker network create $NAME

2. Choose signing authority (CA). By default, this branch uses remote CA. For using local CA, please, follow instruction in https://github.com/9mine/9mine-auth

3. Run local inferno instance with cmdchan. This can be done by running container

        docker run --rm -ti --name --network $NAME getauth -p 1917:1917 --name local dievri/inferno-os:getauth 

    Image for container built from the branch https://github.com/9mine/inferno-os/tree/getauth For adding cmdchan to existing inferno OS, please, use as a reference https://github.com/9mine/inferno-os/blob/getauth/profile

4. Run minetest server with plain authentication mechanism and mods enabled (this branch) 

        docker run --rm -ti --network $NAME --name mt-server -p 30000:30000/udp dievri/minetest:auth 

    During startup auth mod will be loaded which will connect to local inferno OS and mount exposed files from CA. (curently cmdchan and newuser). 
    
    For overriding defaults for CA and local inferno, mount `auth.conf` to the `/root/.minetest/mods/auth/mod.conf`

        docker run --rm -ti --network $NAME -v /path/to/auth.conf:/root/.minetest/mods/auth/mod.conf --name mt-server -p 30000:30000/udp dievri/minetest:auth 

5. Run minetest client with X server and VNC enabled. VNC listening on port 5900

        docker run --rm -ti --network $NAME -p 5900:5900 dievri/minetest:client-x 

6. Connect to minetest using `mt-server` as hostname, and `30000` as port.
7. Run from host:

        vncviewer localhost:5900

