cmake_minimum_required(VERSION 3.22)
project(rocos LANGUAGES CXX)

set(BUILD_DOC FALSE CACHE BOOL "Build documentation")

set(VERSION "0.0.2")
set(VENDOR "Turing-zero")
set(MAINTAINER "Turing-zero <turingzero.robot@gmail.com>")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -pthread")
else()
    add_compile_options(/utf-8)
endif()
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)
include(${PROJECT_SOURCE_DIR}/cmake/Utils.cmake)
standard_config()
standard_paths(${PROJECT_SOURCE_DIR} ZBin lib)

set(libs)

find_package(Protobuf REQUIRED)

set(PROTO_META_BASE_DIR ${CMAKE_BINARY_DIR})
set(PROTO_FILE_DIR ${CMAKE_SOURCE_DIR}/share/proto)
file(MAKE_DIRECTORY ${PROTO_META_BASE_DIR})
list(APPEND PROTO_FLAGS -I${PROTO_FILE_DIR})
file(GLOB PROTO_FILES "${PROTO_FILE_DIR}/*.proto")

function(get_pb_file H CPP)
	list(APPEND PH ${ARGN})
	list(APPEND PC ${ARGN})
	list(TRANSFORM PH PREPEND ${PROTO_META_BASE_DIR}/)
	list(TRANSFORM PH APPEND .pb.h)
	list(TRANSFORM PC PREPEND ${PROTO_META_BASE_DIR}/)
	list(TRANSFORM PC APPEND .pb.cc)
	set(${H} ${PH} PARENT_SCOPE)
	set(${CPP} ${PC} PARENT_SCOPE)
endfunction()

set(PROTO_GEN_FILES)
set(PROTO_GEN_SOURCES)
FOREACH(FIL ${PROTO_FILES})
	GET_FILENAME_COMPONENT(ABS_FIL ${FIL} ABSOLUTE)
	GET_FILENAME_COMPONENT(FIL_WE ${ABS_FIL} NAME_WE)
	list(APPEND PROTO_GEN_FILES ${PROTO_META_BASE_DIR}/${FIL_WE}.pb.h ${PROTO_META_BASE_DIR}/${FIL_WE}.pb.cc)
	list(APPEND PROTO_GEN_SOURCES ${PROTO_META_BASE_DIR}/${FIL_WE}.pb.cc)
ENDFOREACH()

add_custom_command(
	OUTPUT ${PROTO_GEN_FILES}
	COMMAND ${Protobuf_PROTOC_EXECUTABLE} ${PROTO_FLAGS} --cpp_out=${PROTO_META_BASE_DIR} ${PROTO_FILES}
	# WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	DEPENDS ${PROTO_FILES}
)

add_library(rocos_proto STATIC ${PROTO_GEN_SOURCES})
set_target_properties(rocos_proto PROPERTIES AUTOMOC OFF AUTORCC OFF)
target_link_libraries(rocos_proto PUBLIC protobuf::libprotobuf)
target_include_directories(rocos_proto PUBLIC ${PROTO_META_BASE_DIR})

add_custom_target(
	proto_gen
	DEPENDS ${PROTO_GEN_FILES}
)

if(BUILD_DOC)
	find_package(Sphinx)
	if(Sphinx_FOUND)
		sphinx_add_docs(
			rocos-user-manual
			BUILDER singlehtml
			SOURCE_DIRECTORY doc)
	else()
		message(WARNING "Sphinx not found, not building documentation")
		set(BUILD_DOC FALSE)
	endif()
endif()

add_subdirectory(Client)
add_subdirectory(Core)
add_subdirectory(Controller)
