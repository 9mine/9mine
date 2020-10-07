# Run Minetest with inferno as authentication manually using containers

1. Create network for minetest `docker network create $NAME`
2. Choose signing authority (CA). By default, this branch uses remote CA. For using local CA, please, follow instruction in https://github.com/9mine/9mine-auth
3. Run local inferno instance with cmdchan. This can be done with, by running container
`docker run --rm -ti --name --network $NAME getauth -p 1917:1917 --name local dievri/inferno-os:getauth` Image for container built from this branch https://github.com/9mine/inferno-os/tree/getauth For adding cmdchan to existing inferno OS, please, use as a reference https://github.com/9mine/inferno-os/blob/getauth/profile
4. Run minetest server with plain authentication mechanism and mods enabled (this branch) `docker run --rm -ti --network $NAME --name mt-server -p 30000:30000/udp dievri/minetest:auth` During startup auth mod will be loaded which will connect to local inferno OS and mount exposed files from CA. (curently cmdchan and newuser). For overriding defaults for CA and local inferno, mount `auth.conf` to the `/root/.minetest/mods/auth/mod.conf`
5. Run minetest client with X server and VNC enabled. Connect to minetest with using `mt-server` as hostname, and `30000` as port.
