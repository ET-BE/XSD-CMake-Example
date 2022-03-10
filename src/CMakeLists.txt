set(SRC_FILES "main.cpp")

# Append generated XSD .cxx files to application source
xsd_schema(SRC_FILES
        XSD_FILES "${CMAKE_SOURCE_DIR}/xsd/library.xsd"
        OPTIONS --generate-ostream --generate-serialization
        INCLUDE_DIR_OUTPUT "XSD_SRC_INCLUDE_DIR")

add_executable(xsd_example ${SRC_FILES})

target_link_libraries(xsd_example
        XSD::XSD
        XercesC::XercesC)

target_include_directories(xsd_example PUBLIC ${XSD_SRC_INCLUDE_DIR})
