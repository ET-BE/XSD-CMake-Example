set(SRC_FILES "main.cpp")

# Append generated XSD .cxx files to application source
xsd_schema(SRC_FILES "${CMAKE_SOURCE_DIR}/xsd/library.xsd" --generate-inline --generate-ostream --generate-serialization)

add_executable(xsd_example ${SRC_FILES})

target_link_libraries(xsd_example
        XSD::XSD
        XercesC::XercesC)

target_include_directories(xsd_example PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
