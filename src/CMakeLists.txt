set(SRC_FILES "main.cpp")

# Append generated XSD .cxx files to application source
xsd_schema(SRC_FILES
        "${CMAKE_SOURCE_DIR}/xsd/library.xsd"
        OPTIONS --generate-ostream --generate-serialization)

message(STATUS "SRC_FILES: ${SRC_FILES}")

add_executable(xsd_example ${SRC_FILES})

target_link_libraries(xsd_example
        XSD::XSD
        XercesC::XercesC)

target_include_directories(xsd_example PUBLIC ${XSD_SCHEMA_INCLUDE_DIR})
