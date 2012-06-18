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

/* Allows defining as a preprocessor directive on the command line */
#ifndef LUACMSGPACK_MAX_NESTING 
#	define LUACMSGPACK_MAX_NESTING  16 /* Max tables nesting. */
#endif


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