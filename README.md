# Run Minetest with Inferno 

1. In file `.env` specify the follow environment variables
- `GITHUB_BRANCH`
- `MINETEST_PORT`
- `INFERNO_PORT`

2. Run `docker-compose up`


InfernoOS exporting own file system at root level `/` on port `:{INFERNO_PORT}`. 

Puth your `traceroute.txt` in same directory with `docker-compose`

Inside inferno container `traceroute.txt` located at `/usr/inferno/traceroute.txt`

Minetest server working on port `:${MINETEST_PORT}/udp`.

To explore InfernoOS file system use `connect` tool from inventory and the enter following string:
`tcp!inferno!{$INFERNO_PORT`
