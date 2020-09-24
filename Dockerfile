FROM ubuntu:20.04 as build
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install build-essential gcc git liblua5.1-0 liblua5.1-dev ca-certificates -y --fix-missing --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/lneto/luadata.git && sed -i 's#llua#llua5.1#g; s#-fPIC#-fPIC -I/usr/include/lua5.1#g' /luadata/GNUmakefile /luadata/Makefile && mkdir mods && cd luadata && make
RUN git clone --depth=1 https://github.com/dievri/minetest-npcf.git && mv minetest-npcf/npcf mods/ && rm -rf minetest-npcf
RUN git clone --depth=1 https://github.com/9mine/npcf_p9.git mods/npcf_p9 && rm -rf ./mods/npcf_p9/.git
RUN git clone --depth=1 https://github.com/9mine/mine9-mod.git mods/mine9 && rm -rf ./mods/mine9-mod/.git
RUN git clone --depth=1 https://github.com/Uberi/Minetest-WorldEdit.git mt && mv mt/worldedit mods/worldedit && rm -rf mt
RUN git clone --depth=1 https://github.com/prestidigitator/minetest-mod-luaconfig.git mods/luaconfig && rm -rf ./minetest-mod-luaconfig.git
RUN git clone --depth=1 https://github.com/9mine/9mine-npc.git mods/9mine_npc && rm -rf ./mods/9mine_npc/.git
FROM ubuntu:groovy
RUN apt-get update && apt-get install -y minetest-server luarocks lua-socket --no-install-recommends --fix-missing && rm -rf /var/lib/apt/lists/*
COPY ./libs/ /usr/local/share/lua/5.1/
COPY --from=build /luadata/data.so /usr/local/lib/lua/5.1/data.so
ADD minetest.conf /root/.minetest/minetest.conf
COPY --from=build /mods /root/.minetest/mods/
RUN mkdir -p /root/.minetest/worlds/world && echo "enable_damage = true\ncreative_mode = false\nauth_backend = sqlite3\nplayer_backend = sqlite3\nbackend = sqlite3\ngameid = minetest" > /root/.minetest/worlds/world/world.mt
RUN echo "load_mod_worldedit = true\nload_mod_luaconfig = true\nload_mod_npcf = true\nload_mod_npcf_p9 = true\nload_mod_mine9 = true\nload_mod_9mine_npc = true" >> /root/.minetest/worlds/world/world.mt

ENTRYPOINT ["/usr/lib/minetest/minetestserver"]
