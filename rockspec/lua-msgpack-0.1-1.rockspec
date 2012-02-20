package = "lua-msgpack"
version = "0.1-1"
source = {
   url = "git://github.com/antirez/lua-msgpack.git",
   branch = "0.1"
}
description = {
   summary = "MessagePack implementation and bindings for Lua 5.1",
   homepage = "http://github.com/antirez/lua-msgpack",
   license = "MIT/X11",
   maintainer = "Salvatore Sanfilippo <antirez@gmail.com>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      msgpack = {
         sources = {
            "lua_msgpack.c",
         }
      }
   }
}
