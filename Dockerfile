FROM alpine:latest as compile 
ENV BRANCH stable-5
RUN apk add --no-cache git build-base irrlicht-dev cmake bzip2-dev              \
        libpng-dev jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev       \
        libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev            \
        gmp-dev jsoncpp-dev postgresql-dev ca-certificates lua5.1-dev           \
        lua5.1 luarocks5.1 jq curl && git clone -b ${BRANCH} --depth 1          \
        https://github.com/minetest/minetest.git && mkdir minetest_compiled

RUN cd minetest && export COMMIT_VERSION=$(git log --pretty=tformat:"%h" -n1 . ) && \
    export DATE=$(date) && \
    sed -i "s#VERSION_EXTRA \"\" CACHE STRING \"Stuff to append to version string\"#VERSION_EXTRA \"${BRANCH} ${COMMIT_VERSION} ${DATE}\"#g" CMakeLists.txt && \
    sed -i "s#\${VERSION_STRING}-\${VERSION_EXTRA}#\"\${VERSION_STRING} \${VERSION_EXTRA}\"#g" CMakeLists.txt && \
    git checkout stable-5 && \
    cmake . -DCMAKE_INSTALL_PREFIX=/minetest_compiled   \
                        -DCMAKE_BUILD_TYPE=RELEASE                  \
                        -DRUN_IN_PLACE=FALSE                        \
                        -DBUILD_UNITTESTS=FALSE                     \
                        -DBUILD_SERVER=TRUE                         \
                        -DBUILD_CLIENT=FALSE                        \
                        && make -j$(nproc) && make install         

RUN curl -sL https://api.github.com/repos/vi/websocat/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("websocat_amd64-linux-static")).browser_download_url' | xargs -I{} curl -Lo /usr/local/bin/websocat {}
RUN chmod +x /usr/local/bin/websocat
    
RUN git clone https://github.com/lneto/luadata.git &&               \
    sed -i 's#-fPIC#-fPIC -I/usr/include/lua5.1#g'                  \
    /luadata/GNUmakefile /luadata/Makefile && cd luadata && make    

RUN git clone --depth 1 https://github.com/minetest/minetest_game.git 

RUN luarocks-5.1 install luasocket
RUN luarocks-5.1 install luabitop 
RUN luarocks-5.1 install lua-filesize

FROM alpine:latest

RUN apk add --update --no-cache sqlite-libs curl gmp libstdc++ libgcc libpq lua5.1-libs gawk

RUN mkdir -p /root/.minetest/worlds/world && mkdir -p /root/.minetest/mods/default/textures && echo " " > /root/.minetest/mods/default/init.lua


COPY                    ./minetest.conf             /root/.minetest/minetest.conf
#COPY                    ./mods                      /root/.minetest/mods/
COPY                    ./worlds/world/world.mt     /root/.minetest/worlds/world/world.mt
COPY                    ./libs/                     /usr/local/share/lua/5.1/

COPY --from=compile     /usr/local/share/lua/5.1    /usr/local/share/lua/5.1/
COPY --from=compile     /usr/local/lib/lua/5.1      /usr/local/lib/lua/5.1/
COPY --from=compile     /luadata/data.so            /usr/local/lib/lua/5.1/data.so
COPY --from=compile     /minetest_compiled/bin      /usr/bin/
COPY --from=compile     /minetest_compiled/share    /usr/share/

COPY --from=compile     /minetest_game/mods/default/textures /root/.minetest/mods/default/textures/

RUN rm -fr /usr/share/minetest/games/devtest/mods/
COPY --from=compile  /usr/local/bin/websocat /usr/local/bin/websocat 

RUN touch /tmp/minetest_input && chmod a+rw /tmp/minetest_input
RUN apk add coreutils netcat-openbsd

ENTRYPOINT [ "/usr/bin/minetestserver" ]
