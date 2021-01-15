FROM    ubuntu:20.10 as compile

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt-get update && apt-get install -y libluajit-5.1-dev  \
        git g++ make libc6-dev libirrlicht-dev libssl-dev       \
        cmake libbz2-dev libpng-dev libjpeg-dev libxxf86vm-dev  \
        libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev \
        libopenal-dev libcurl4-gnutls-dev libfreetype6-dev      \
        zlib1g-dev libgmp-dev libjsoncpp-dev luarocks graphviz  \
        graphviz-dev

# Build luadata libary 
RUN     git clone https://github.com/lneto/luadata.git &&                       \
        sed -i 's#-fPIC#-fPIC -I/usr/include/lua5.1#g; s#llua#lluajit-5.1#g'    \
        luadata/GNUmakefile && cd luadata && make

# Clone minetest game for extracting textures
RUN     git clone --depth 1 https://github.com/minetest/minetest_game.git 

# Specify branch or commit from which minetest should be built
ENV     BRANCH          master
#ENV     COMMIT          d2abdda12c8fceee5b20cd0d64e0d955b6ee5657

RUN     git clone https://github.com/minetest/minetest.git 
WORKDIR minetest 
#RUN git checkout $COMMIT

# Change version string of compiled binary 
RUN     export COMMIT_VERSION=$(git rev-parse --short HEAD) &&  \
        export DATE="$(date)" &&                                \
        sed -i "s#VERSION_EXTRA \"\" CACHE STRING \"Stuff to append to version string\"#VERSION_EXTRA \"${BRANCH} ${COMMIT_VERSION} ${DATE}\"#g ; s#\${VERSION_STRING}-\${VERSION_EXTRA}#\"\${VERSION_STRING} \${VERSION_EXTRA}\"#g" CMakeLists.txt 

# Build and install minetestserver 
RUN     cmake   -DBUILD_SERVER=TRUE             \
                -DBUILD_CLIENT=FALSE            \
                -DRUN_IN_PLACE=FALSE            \
                -DCMAKE_BUILD_TYPE=MinSizeRel &&\
                                                \    
        make    -j$(nproc)                    &&\
        make    install

# Install Lua libraries
RUN     luarocks install luafilesystem  &&\
        luarocks install luagraph       &&\
        luarocks install luasocket      &&\
        luarocks install luabitop       &&\    
        luarocks install lua-filesize   &&\
        luarocks install luagraph       &&\
        luarocks install md5            &&\
        luarocks install luafilesystem  &&\
        luarocks install lua-cjson      &&\
        luarocks install luaunit        &&\
        luarocks install luasec   


# Production image
FROM    ubuntu:20.10

ENV     DEBIAN_FRONTEND noninteractive

# Dependencies for minetestserver and mods
RUN     apt-get update && apt-get install -y sqlite3 libcurl4-gnutls-dev graphviz-dev libluajit-5.1-dev

# Create default mod (for default textures for minetest game)
RUN     mkdir -p /root/.minetest/worlds/world mkdir   \
        /root/.minetest/mods/default/textures       &&\ 
        echo " " > /root/.minetest/mods/default/init.lua 


# Copy minetest configuration file
COPY    ./minetest.conf                                 /root/.minetest/minetest.conf

# Copy minetest world configuration file
COPY    ./world.mt                                      /root/.minetest/worlds/world/world.mt

# Copy default textures from minetest game
COPY    --from=compile /minetest_game/mods/default/textures /root/.minetest/mods/default/textures/

# Copy luadata build artifacts
COPY    --from=compile /luadata/data.so        /usr/local/lib/lua/5.1/data.so  
# Copy minetest build artifacts
COPY    --from=compile /usr/local/share/minetest        /usr/local/share/minetest
COPY    --from=compile /usr/local/bin/minetestserver    /usr/local/bin/

# Copy local libraries
COPY    ./libs/                                         /usr/local/share/lua/5.1/

# Copy libraries installed with luarocks
COPY    --from=compile     /usr/local/share/lua/5.1    /usr/local/share/lua/5.1/
COPY    --from=compile     /usr/local/lib/lua/5.1      /usr/local/lib/lua/5.1/

EXPOSE  30000/udp

ENTRYPOINT ["minetestserver"]