package = "lua-msgpack"
version = "scm-1"
source = {
   url = "git://github.com/antirez/lua-msgpack.git",
   branch = "master"
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
