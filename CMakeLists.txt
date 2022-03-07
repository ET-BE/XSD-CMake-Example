cmake_minimum_required(VERSION 3.20)
project(XSD_Example)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

find_package(XSD REQUIRED)
find_package(XercesC REQUIRED)

add_subdirectory(src)
