Format lua files using [LuaFormatter](https://github.com/Koihik/LuaFormatter) and configurations for mod:

    lua-format -i mods/core/*.lua mods/core/**/*.lua  --config mods/core/.lua-format 

Lint:

    luacheck mods/core/ --config mods/core/.luacheckrc 