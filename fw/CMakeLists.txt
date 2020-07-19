cmake_minimum_required(VERSION 3.17.3)

project(fw)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(AddHDLFile)

add_subdirectory(src)
