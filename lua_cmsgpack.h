#ifndef LUA_CMSGPACK_MAIN_HEADER_HPP
#define LUA_CMSGPACK_MAIN_HEADER_HPP

#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include "lua.h"
#include "lauxlib.h"

#define LUACMSGPACK_VERSION     "lua-cmsgpack 0.3.0"
#define LUACMSGPACK_COPYRIGHT   "Copyright (C) 2012, Salvatore Sanfilippo"
#define LUACMSGPACK_DESCRIPTION "MessagePack C implementation for Lua"

/* Allows defining as a preprocessor directive on compilation */
#ifndef LUACMSGPACK_MAX_NESTING 
#	define LUACMSGPACK_MAX_NESTING  16 /* Max tables nesting. */
#endif


/*
 * Allows compilation under Lua 5.1 and 5.2 and avoids use of functions which have been deprecated in 5.2.
 */
#if LUA_VERSION_NUM >= 502 /* If higher than Lua 5.2, hopes for compatibility */
#	define LUACOMPAT_REGISTER(L,l) luaL_setfuncs(L,l,0)
#	define lua_objlen(L, i) lua_rawlen(L, i)
#	define LUACOMPAT_PUSH_GLOBAL_ENVIRONMENT(L) lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS)
#else /* If lower than Lua 5.1, hopes for compatibility */
#	define LUACOMPAT_REGISTER(L,l) luaL_register(L,NULL,l)
#	define LUACOMPAT_PUSH_GLOBAL_ENVIRONMENT(L) lua_pushvalue(L, LUA_GLOBALSINDEX)
#endif

/*
 * Compatibility wrapper to determine whether a float/double x is finite.
 */
#if _XOPEN_SOURCE >= 600 || _ISOC99_SOURCE || _POSIX_C_SOURCE >= 200112L
#	define IS_FINITE(x) isfinite(x)
#else
#	define IS_FINITE(x) ((x) == (x) && (x) + 1 > (x))
#endif

/* Checks if a float or double value x can be represented as an integer of type T without loss of precision */
#define IS_INT_TYPE_EQUIVALENT(x, T) (IS_FINITE(x) && (T)(x) == (x))

#define IS_INT64_EQUIVALENT(x) IS_INT_TYPE_EQUIVALENT(x, int64_t)
#define IS_INT_EQUIVALENT(x) IS_INT_TYPE_EQUIVALENT(x, int)

#endif // lua_cmsgpack.h
