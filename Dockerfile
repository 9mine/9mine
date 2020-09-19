FROM ubuntu:latest as luadata
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN git clone https://github.com/lneto/luadata.git
RUN apt-get install -y lua5.1
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y liblua5.1-dev
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y liblua5.1-0
WORKDIR luadata
RUN apt-get install -y wget
RUN wget -c http://www.lua.org/ftp/lua-5.1.1.tar.gz -O - | tar -xz && cp -r lua-5.1.1/src/* .
RUN ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/x86_64-linux-gnu/liblua.so 
RUN make

FROM ubuntu:latest
#RUN apt-get update && apt-get install -y software-properties-common
RUN echo "deb http://archive.ubuntu.com/ubuntu groovy main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y minetest-server
RUN apt-get update --fix-missing && DEBIAN_FRONTEND="noninteractive" apt-get install -y luarocks --no-install-recommends
RUN apt-get install -y gcc --no-install-recommends
RUN luarocks install luafilesystem
RUN mkdir /users
COPY --from=luadata /luadata/data.so /usr/local/lib/lua/5.1
COPY ./libs/ /usr/share/lua/5.1/
RUN luarocks install luasocket
RUN apt-get --purge remove -y gcc
RUN apt autoremove -y
RUN echo "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list
RUN apt-get update	
RUN apt-get install git -y --fix-missing
ADD minetest.conf /root/.minetest/minetest.conf
ADD minetest.conf /etc/minetest/minetest.conf
# RUN git clone -b packets https://github.com/9mine/9mine.git 
RUN cp -r cdmod /usr/share/games/minetest/games/minetest_game/mods/cdmod
RUN git clone https://github.com/dievri/minetest-npcf.git
RUN cp -r minetest-npcf /usr/share/games/minetest/games/minetest_game/mods/
RUN git clone https://github.com/9mine/npcf_p9.git
RUN cp -r npcf_p9 /usr/share/games/minetest/games/minetest_game/mods/minetest-npcf/npcf_p9
ENTRYPOINT ["/usr/lib/minetest/minetestserver"]

