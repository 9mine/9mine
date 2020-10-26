FROM alpine:latest as compile 
ENV BRANCH master
RUN apk add --no-cache git build-base irrlicht-dev cmake bzip2-dev lua5.1       \
        libpng-dev jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev       \
        libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev            \
        gmp-dev jsoncpp-dev postgresql-dev ca-certificates lua5.1-dev           \
        luarocks5.1 && mkdir minetest_compiled &&                               \
        git clone --depth 1 https://github.com/minetest/minetest.git 

RUN cd minetest && export COMMIT_VERSION=$(git log --pretty=tformat:"%h" -n1 . ) && cd .. && \
    export DATE=$(date) && \
    sed -i "s#VERSION_EXTRA \"\" CACHE STRING \"Stuff to append to version string\"#VERSION_EXTRA \"${BRANCH} ${COMMIT_VERSION} ${DATE}\"#g" minetest/CMakeLists.txt && \
    sed -i "s#\${VERSION_STRING}-\${VERSION_EXTRA}#\"\${VERSION_STRING} \${VERSION_EXTRA}\"#g" minetest/CMakeLists.txt && \
    cmake ./minetest    -DCMAKE_INSTALL_PREFIX=/minetest_compiled   \
                        -DCMAKE_BUILD_TYPE=MinSizeRel               \
                        -DRUN_IN_PLACE=FALSE                        \
                        -DBUILD_UNITTESTS=FALSE                     \
                        -DBUILD_SERVER=TRUE                         \
                        -DBUILD_CLIENT=FALSE                        \
                        && make -j$(nproc) && make install         
    
RUN git clone https://github.com/lneto/luadata.git &&               \
    sed -i 's#-fPIC#-fPIC -I/usr/include/lua5.1#g'                  \
    /luadata/GNUmakefile /luadata/Makefile && cd luadata && make    

RUN git clone --depth 1 https://github.com/minetest/minetest_game.git 

RUN luarocks-5.1 install luasocket
RUN luarocks-5.1 install luabitop 
RUN luarocks-5.1 install lua-filesize
RUN apk add graphviz graphviz-dev
RUN luarocks-5.1 install luagraph
RUN luarocks-5.1 install md5

FROM alpine:latest

RUN apk add --no-cache sqlite-libs curl gmp libstdc++ libgcc libpq lua5.1-libs
RUN apk add --update graphviz graphviz-dev font-bitstream-type1 ghostscript-fonts ttf-freefont
RUN mkdir -p /root/.minetest/worlds/world && mkdir -p /root/.minetest/mods/default/textures && echo " " > /root/.minetest/mods/default/init.lua

COPY                    ./minetest.conf             /root/.minetest/minetest.conf
COPY                    ./world.mt     /root/.minetest/worlds/world/world.mt
COPY                    ./libs/                     /usr/local/share/lua/5.1/

COPY --from=compile     /usr/local/share/lua/5.1    /usr/local/share/lua/5.1/
COPY --from=compile     /usr/local/lib/lua/5.1      /usr/local/lib/lua/5.1/
COPY --from=compile     /luadata/data.so            /usr/local/lib/lua/5.1/data.so
COPY --from=compile     /minetest_compiled/bin      /usr/bin/
COPY --from=compile     /minetest_compiled/share    /usr/share/

COPY                    ./mods                      /root/.minetest/mods/



# COPY --from=compile     /usr/lib/libgvc.so.6    \
#                         /usr/lib/libcgraph.so.6 \
#                         /usr/lib/libltdl.so.7   \
#                         /usr/lib/libcdt.so.5    \
#                         /usr/lib/libcdt.so.5    \
#                         /usr/lib/libexpat.so.1  \
#                         /usr/lib/libpathplan.so.4  /usr/lib/


COPY --from=compile     /minetest_game/mods/default/textures /root/.minetest/mods/default/textures/

RUN mkdir /storage && rm -fr /usr/share/minetest/games/devtest/mods/

ENTRYPOINT [ "/usr/bin/minetestserver" ]