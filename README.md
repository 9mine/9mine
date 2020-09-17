# Run Minetest with Inferno 

1. Run `docker-compose up`

InfernoOS exporting own file system at root level `/` on port `:31000`. 

Puth your `traceroute.txt` in same directory with `docker-compose`

Inside inferno container `traceroute.txt` located at `/usr/inferno/traceroute.txt`

Minetest server working on port `:30000/udp`.

To explore InfernoOS file system use `connect` tool from inventory and the enter following string:
`tcp!inferno!31000`
