# If Lua is installed in a non-standard location, please set the LUA_DIR
# environment variable to point to prefix for the install. Eg:
#       Unix: export LUA_DIR=/home/user/pkg
#       Windows: set LUA_DIR=c:\lua51

project(lua-cmsgpack C)
cmake_minimum_required(VERSION 2.6)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
        FORCE)
endif()

find_package(Lua51 REQUIRED)
include_directories(${LUA_INCLUDE_DIR})

if(APPLE)
    set(CMAKE_SHARED_MODULE_CREATE_C_FLAGS
        "${CMAKE_SHARED_MODULE_CREATE_C_FLAGS} -undefined dynamic_lookup")
endif()

if(WIN32)
    # Win32 modules need to be linked to the Lua library.
    set(_MODULE_LINK ${LUA_LIBRARY} ${_MODULE_LINK})
    set(_lua_module_dir "${_lua_lib_dir}")
else()
    set(_lua_module_dir "${_lua_lib_dir}/lua/5.1")
endif()

option(Build32Bit "Build 32-bit Library" OFF)

set(CMAKE_C_FLAGS "-O2 -g -ggdb -Wall -pedantic -std=c99")
add_library(cmsgpack MODULE lua_cmsgpack.c)
set_target_properties(cmsgpack PROPERTIES PREFIX "")

if(Build32Bit)
    set_target_properties(cmsgpack
                          PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
endif()

target_link_libraries(cmsgpack ${_MODULE_LINK})
install(TARGETS cmsgpack DESTINATION "${_lua_module_dir}")

# vi:ai et sw=4 ts=4:
