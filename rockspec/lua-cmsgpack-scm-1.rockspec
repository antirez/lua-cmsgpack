package = "lua-cmsgpack"
version = "scm-1"
source = {
   url = "git://github.com/antirez/lua-cmsgpack.git",
   branch = "master"
}
description = {
   summary = "MessagePack C implementation and bindings for Lua 5.1",
   homepage = "http://github.com/antirez/lua-msgpack",
   license = "Two-clause BSD",
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
            "lua_cmsgpack.c",
         }
      }
   }
}
