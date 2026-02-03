set(TARGET_NAME Client)
# Client
if (WIN32)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup")

    # muti-processors build for VS
    include(ProcessorCount)
    ProcessorCount(N)
    if(NOT N EQUAL 0)
        SET(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /MP${N} ")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${N} ")
    endif()

    ## if you have different Qt visions and CMake cannot link the right one
    #set(CMAKE_PREFIX_PATH D:/App/Qt/5.14.1/msvc2015_64/lib/cmake)

    set(thirdParty ${CMAKE_CURRENT_SOURCE_DIR}/../3rdParty)
endif()

if (NOT UNIX AND NOT APPLE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS")
endif()

add_subdirectory(plugins)

set(libs)

# define protobuf generater
find_package(Protobuf REQUIRED)
list(APPEND libs protobuf::libprotobuf)

## find Zlib
find_package(ZLIB REQUIRED)
list(APPEND libs ZLIB::ZLIB)

## fmt
find_package(fmt REQUIRED)
include_directories(${fmt_INCLUDE_DIRS})
list(APPEND libs fmt::fmt)

## find Qt
find_package(Qt5 COMPONENTS Core Quick SerialPort REQUIRED)
list(APPEND libs Qt5::Core Qt5::Quick Qt5::SerialPort)
if (WIN32)
    list(APPEND libs Qt5::WinMain)
endif()
# project files
set(PROJECT_INCLUDE_DIRS
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/proto
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vision
    ${CMAKE_CURRENT_SOURCE_DIR}/src/vision/log
    ${CMAKE_CURRENT_SOURCE_DIR}/plugins
    ${CMAKE_SOURCE_DIR}/share
)
include_directories(${PROJECT_INCLUDE_DIRS})
## core cpp files
file(GLOB CPPFILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/utils/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/vision/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/vision/log/*.cpp"
    "${CMAKE_SOURCE_DIR}/share/*.cpp"
)
set(SRC
    ${HEADERS}
    ${SOURCES}
    ${CPPFILES}
)
set(zss_libs
    zss_simulator
    rocos_proto
)
add_executable(${TARGET_NAME} ${SRC} "Client.qrc" "Client.rc")
target_compile_definitions(${TARGET_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${TARGET_NAME} PRIVATE ${libs} ${zss_libs})
add_dependencies(${TARGET_NAME} proto_gen)