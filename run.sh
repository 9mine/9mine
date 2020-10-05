docker stop -t0 minetest
docker rm -f minetest
rm -f worlds/world/map.sqlite

docker run --name minetest --rm -it --entrypoint /bin/sh -p 0.0.0.0:30000:30000/udp -p 0.0.0.0:30000:30000 \
  -v `pwd`/graphviz:/root/.minetest/mods/graphviz               \
  -v `pwd`/worlds/world/:/root/.minetest/worlds/world/          \
  minetest:bitcoin_transaction                                  \
  -c 'echo > /tmp/minetest_input; minetestserver'

  #-c 'echo > /tmp/minetest_input; minetestserver & sleep 5; websocat wss://apirone.com/ws | head -n1 | awk -F\| -f /usr/local/bin/parser.awk | tee >> /tmp/minetest_input'
  
