# Start youtube2text
This repository provides minetest mod for converting youtube video to text

To start:

1. Clone this branch and cd into directory

        git clone --depth=1 https://github.com/9mine/9mine.git && cd 9mine

2. Update Docker Images

        docker-compose pull

3. Run backend services - `minetest server` and `inferno` instance. 
        
        docker-compose up

      
Use `minetest` client to connect to server. `minetest server` listening on default `:30000/udp` port, and `inferno` export its filesystem on port `:1917`. For `minetest server` the `inferno` instance is visible as `mt-local` (they are inside one docker network). For example, when using connect tools, the connection string should look like following `tcp!mt-local!1917`. For `minetest client` the `minetest server` visible simply as `localhost:30000`.
