#
# No official FindXSD script is available.
#
# Attempt to find the xsd application in various places. If found, the full
# path will be in XSD_EXECUTABLE. Look in the usual locations, as well as in
# the 'bin' directory in the path given in the XSD_ROOT environment variable.
# Will also find and set XSD_INCLUDE_DIR. The find command will fail if the
# include was not found.
#
# Will import the `XSD::XSD` header-only target and the `XSD_SCHEMA` macro.
#
# As a bonus this script will append the library directory of XercesC to the
# search, since on Windows XercesC is installed together with XSD.
#

find_program(XSD_EXECUTABLE
        NAMES
        xsd
        xsdcxx
        HINTS
        ${RWSL_DEPS}/xsd/bin
        ${XSD_ROOT}/bin
        $ENV{XSD_ROOT}/bin
        "C:/Program Files\ (x86)/CodeSynthesis\ XSD\ 4.0/bin"
        ENV PATH
        DOC "XSD executable path")
mark_as_advanced(XSD_EXECUTABLE)

find_path(XSD_INCLUDE_DIR
        NAMES "xsd/cxx/config.hxx"
        DOC "XSD C++ include directory")
mark_as_advanced(XSD_INCLUDE_DIR)

#
# General CMake package configuration.

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(XSD
        REQUIRED_VARS XSD_INCLUDE_DIR)

if(XSD_FOUND)
    set(XSD_INCLUDE_DIRS "${XSD_INCLUDE_DIR}")

    # For header-only libraries
    if(NOT TARGET XSD::XSD)
        add_library(XSD::XSD INTERFACE IMPORTED)
        if(XSD_INCLUDE_DIRS)
            set_target_properties(XSD::XSD PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${XSD_INCLUDE_DIRS}")
        endif()
    endif()

    # Create a hint for finding XercesC later
    if(NOT XercesC_LIBRARY)
        get_filename_component(_xsd_root ${XSD_INCLUDE_DIR} DIRECTORY)
        set(_xerces_lib_dir "${_xsd_root}/lib64/vc-12.0")

        if(EXISTS ${_xerces_lib_dir})
            # Add to search paths
            list(APPEND CMAKE_PREFIX_PATH "${_xerces_lib_dir}")
        endif()
    endif()
endif()

#
# Macro that attempts to generate C++ files from an XML schema. The SRC_FILES_OUTPUT
# argument is the name of the CMake variable to use to store paths to the
# derived C++ source file. The FILE argument is the path of the schema file to
# process. Additional arguments should be XSD command-line options.
#
# Example:
#
# XSD_SCHEMA( FOO_SRCS Foo.xsd --root-element-first --generate-serialization )
#
# On return, FOO_SRCS will contain Foo.cxx.
#
# Another variable called XSD_SCHEMA_INCLUDE_DIR will point to the include directory of the new .hxx files.

function(parse_xsd_schema_args _xsd_files _xsd_options)

    # Function to split the list of XSD files and XSD CLI options

    foreach(current_arg ${ARGN})

        if(${current_arg} STREQUAL "OPTIONS")
            set(_XSD_DOING_OPTIONS TRUE)
        else()
            if(_XSD_DOING_OPTIONS)
                set(_xsd_options_p ${_xsd_options_p} ${current_arg})
            else()
                set(_xsd_files_p ${_xsd_files_p} ${current_arg})
            endif()
        endif()

    endforeach()

    set(${_xsd_files} ${_xsd_files_p} PARENT_SCOPE)
    set(${_xsd_options} ${_xsd_options_p} PARENT_SCOPE)

endfunction()

macro(xsd_schema SRC_FILES_OUTPUT)

    parse_xsd_schema_args(XSD_FILES OPTIONS ${ARGN})

    #
    # Make a full path from the source directory

    set(XSD_SCHEMA_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/xsd")

    file(MAKE_DIRECTORY ${XSD_SCHEMA_INCLUDE_DIR})

    #
    # Allow for list of XSD files
    foreach(xs_SRC ${XSD_FILES})

        #
        # XSD will generate two or three C++ files (*.cxx,*.hxx,*.ixx). Get the
        # destination file path sans any extension and then build paths to the
        # generated files.

        get_filename_component(xs_FILE "${xs_SRC}" NAME_WE)
        set(xs_CXX "${XSD_SCHEMA_INCLUDE_DIR}/${xs_FILE}.cxx")
        set(xs_HXX "${XSD_SCHEMA_INCLUDE_DIR}/${xs_FILE}.hxx")
        set(xs_IXX "${XSD_SCHEMA_INCLUDE_DIR}/${xs_FILE}.ixx")

        #
        # Add the source files to the SRC_FILES variable, which presumably will be used to
        # define the source of another target.

        list(APPEND ${SRC_FILES_OUTPUT} ${xs_CXX})

        #
        # Set up a generator for the output files from the given schema file using
        # the XSD cxx-tree command.

        add_custom_command(OUTPUT "${xs_CXX}" "${xs_HXX}" "${xs_IXX}"
                COMMAND ${XSD_EXECUTABLE}
                ARGS "cxx-tree" --output-dir ${XSD_SCHEMA_INCLUDE_DIR} ${OPTIONS} ${xs_SRC}
                DEPENDS ${xs_SRC})

        #
        # Don't fail if a generated file does not exist.

        set_source_files_properties("${xs_CXX}" "${xs_HXX}" "${xs_IXX}"
                PROPERTIES GENERATED TRUE)

    endforeach()

endmacro()
