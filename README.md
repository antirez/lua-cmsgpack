README for lua-cmsgpack.c
===

Lua-cmsgpack is a [MessagePack](http://msgpack.org) implementation and bindings for
Lua 5.1/5.2 in a self contained C file without external dependencies.

This library is open source software licensed under the BSD two-clause license.

INSTALLATION
---

Using LuaRocks (http://luarocks.org):

* Install current stable release:

    sudo luarocks install lua-cmsgpack

* Install current Git master head from GitHub:

    sudo luarocks install lua-cmsgpack --from=rocks-cvs

* Install from current working copy

    cd lua-cmsgpack/
    sudo luarocks make rockspec/lua-cmsgpack-scm-1.rockspec

If you embed Lua and all modules into your C project, just add the
`lua_cmsgpack.c` file and call the following function after creating the Lua
interpreter:

    luaopen_cmsgpack(L);

USAGE
---

The exported API is very simple, consisting in two functions:

    msgpack = cmsgpack.pack(lua_object)
    lua_object = cmsgpack.unpack(msgpack)

However because of the nature of Lua numerical and table type a few behavior
of the library must be well understood to avoid problems:

* A table is converted into a MessagePack array type only if *all* the keys are
composed of incrementing integers starting at 1 end ending at N, without holes,
without additional non numerical keys. All the other tables are converted into
maps.
* An empty table is always converted into a MessagePack array, the rationale is that empty lists are much more common than empty maps (usually used to represent objects with fields).
* A Lua number is converted into an integer type if floor(number) == number, otherwise it is converted into the MessagePack float or double value.
* When a Lua number is converted to float or double, the former is preferred if there is no loss of precision compared to the double representation.
* When a MessagePack big integer (64 bit) is converted to a Lua number it is possible that the resulting number will not represent the original number but just an approximation. This is unavoidable because the Lua numerical type is usually a double precision floating point type.

NESTED TABLES
---
Nested tables are handled correctly up to `LUACMSGPACK_MAX_NESTING` levels of
nesting (that is set to 16 by default).
Every table that is nested at a greater level than the maxium is encoded
as MessagePack nil value.

It is worth to note that in Lua it is possible to create tables that mutually
refer to each other, creating a cycle. For example:

    a = {x=nil,y=5}
    b = {x=a}
    a['x'] = b

This condition will simply make the encoder reach the max level of nesting,
thus avoiding an infinite loop.

CREDITS
---

This library was written by Salvatore Sanfilippo for Redis, but is maintained as a separated project by the author.

Some of the test vectors in "test.lua" are obtained from the Javascript [MessagePack-JS library](https://github.com/cuzic/MessagePack-JS).
