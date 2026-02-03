# Simulator Plugin
set(libs)
# OpenGL
find_package(OpenGL REQUIRED)
list(APPEND PROJECT_INCLUDE_DIRS ${OPENGL_INCLUDE_DIR})
list(APPEND libs ${OPENGL_LIBRARIES})

if (WIN32)
    ## if you have different Qt visions and CMake cannot link the right one
    #set(CMAKE_PREFIX_PATH D:/App/Qt/5.14.1/msvc2015_64/lib/cmake)

    set(thirdParty ${CMAKE_CURRENT_SOURCE_DIR}/../../../3rdParty)
endif()

# Qt5
find_package(Qt5 COMPONENTS Core Network Gui REQUIRED)
list(APPEND PROJECT_INCLUDE_DIRS
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Network_INCLUDE_DIRS}
    ${Qt5Gui_INCLUDE_DIRS}
)
list(APPEND libs Qt5::Core Qt5::Network Qt5::Gui)

# ODE
if (WIN32)
    list(APPEND libs Qt5::WinMain)
    set(ODE_INCLUDE_DIRS "${thirdParty}/ODE/include")
    set(ODE_LIBRARIES "${thirdParty}/ODE/lib/ode.lib")
else()
find_package(ODE REQUIRED)
endif()
list(APPEND PROJECT_INCLUDE_DIRS ${ODE_INCLUDE_DIRS})
list(APPEND libs ${ODE_LIBRARIES})
# add_definitions(-DdDOUBLE)

# Protobuf
find_package(Protobuf REQUIRED)
list(APPEND libs protobuf::libprotobuf)

list(APPEND PROJECT_INCLUDE_DIRS
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/proto
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/physics
    ${CMAKE_SOURCE_DIR}/share
)
include_directories(${PROJECT_INCLUDE_DIRS})

file(GLOB CPPFILES 
    "${CMAKE_SOURCE_DIR}/src/utils/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/physics/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_SOURCE_DIR}/share/*.cpp"
)
set(EXPORT_HEADERS
	sslworld.h
)
set(HEADERS
	${EXPORT_HEADERS}
)
set(SOURCES
	sslworld.cpp
)
set(srcs
    ${HEADERS}
    ${SOURCES}
    ${CPPFILES}
)
list(APPEND libs rocos_proto)

set(target_lib zss_simulator)

if(BUILD_PYTHON_PLUGINS)
	execute_process(COMMAND cling-config --cmake OUTPUT_VARIABLE CPYY_MODULE_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
	list(INSERT CMAKE_MODULE_PATH 0 ${CPYY_MODULE_PATH})
	find_package(Cppyy)
endif()

add_library(${target_lib} STATIC ${srcs})
add_dependencies(${target_lib} proto_gen)

set_target_properties(${target_lib} PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(${target_lib} PUBLIC ${PROJECT_INCLUDE_DIRS})

if(BUILD_PYTHON_PLUGINS)
	cppyy_add_bindings(
	   "${target_lib}" "0.0.1" "ZJUNlict" "zjunlict.ssl@gmail.com"
	   LANGUAGE_STANDARD "17"
	   GENERATE_OPTIONS "-D__PIC__;-Wno-macro-redefined"
	   INCLUDE_DIRS ${PROJECT_INCLUDE_DIRS}
	   LINK_LIBRARIES ${target_lib}
	   H_DIRS ${PROJECT_INCLUDE_DIRS}
	   H_FILES ${EXPORT_HEADERS})
endif()

target_link_libraries(${target_lib} ${libs})

install(TARGETS ${target_lib}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
