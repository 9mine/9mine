![Discord](https://img.shields.io/discord/337985133569114113?style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/9mine/9mine/Minetest%20Container%20Image?style=for-the-badge)
[![GitHub issues](https://img.shields.io/github/issues/9mine/9mine?style=for-the-badge)](https://github.com/9mine/9mine/issues)
[![GitHub license](https://img.shields.io/github/license/9mine/9mine?style=for-the-badge)](https://github.com/9mine/9mine/blob/master/LICENSE)
# Start 9mine

This repository provides minetest mod for 9mine project

1. Clone this branch and cd into directory

        git clone --depth=1 https://github.com/9mine/9mine.git

2. Set environment variables in `.env` file.

    `INFERNO_AFRESS` - full adress of the 9p filesystem. Minetest will connect to this host during login process. By default it will connect to the inferno instance started by docker-compose.

    `REFRESH_TIME` - time period (in seconds) on which platform content will be read again an new entities will be spawn if needed. By default equals to 0, which mean no refresh of the content will be maid.

### To start just backend:

2. Update Docker Images

        docker-compose pull

3. Run backend services - `minetest server` and `inferno` instance. 
        
        docker-compose up

### To start backend & client

2. Update Docker Images 

        docker-compose -f docker-compose.yml -f docker-compose.client.yml pull

3. Run backend & client 

        docker-compose -f docker-compose.yml -f docker-compose.client.yml up

      
Use `minetest` client to connect to server. `minetest server` listening on default `:30000/udp` port, and `inferno` export its filesystem on port `:1917`. For `minetest server` the `inferno` instance is visible as `mt-local` (they are inside one docker network). For example, when using connect tools, the connection string should look like following `tcp!mt-local!1917`. For `minetest client` container the `minetest server` visible simply  `mt-server:30000`. If `minetest client` is local, then `minetest server` visible as `localhost:30000`.
