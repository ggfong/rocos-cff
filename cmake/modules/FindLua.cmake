# Locate LUA include paths and libraries
# This module defines
# LUA_INCLUDE_DIR, where to find lua.h, etc.
# LUA_LIBRARIES, the libraries to link against to use lua.
# LUA_FOUND, If false, don't try to use lua.

FIND_PATH(LUA_INCLUDE_DIR lua.h
  PATHS
  "$ENV{LUA_DIR}/include"
  "${CMAKE_SOURCE_DIR}/3rdParty/lua/include"
  /usr/local/include
  /usr/include
  /usr/include/lua5.1
  /usr/include/lua51
)

FIND_LIBRARY(LUA_LIBRARIES NAMES lua lua5.1 lua51
  PATHS
  "$ENV{LUA_DIR}/lib"
  "${CMAKE_SOURCE_DIR}/3rdParty/lua/lib"
  /usr/local/lib
  /usr/lib
)

SET(LUA_FOUND 0)
IF(LUA_INCLUDE_DIR AND LUA_LIBRARIES)
  SET(LUA_FOUND 1)
  MESSAGE(STATUS "Found LUA: ${LUA_LIBRARIES}")
ENDIF()

MARK_AS_ADVANCED(
  LUA_INCLUDE_DIR
  LUA_LIBRARIES
)
