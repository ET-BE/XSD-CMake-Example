# XSD CMake Example

This project shows a basic example of using CodeSynthesis XSD with CMake and Git.

## XSD

XSD is a tool to parse XML files. It works by letting the developer define .xsd
files, which determine the layout of XML files that will be provided during 
runtime.  
The .xsd files need to be processed by XSD to generate .cxx, .hxx and .ixx files.
These files are then build with the rest of the application.

The generated files are not part of the maintained source code and should
therefore not be part of the software package, neither should they be committed
under version control tools.

## CMake and XSD

This can be neatly combined in a custom macro, based on CMake's
`add_custom_command`. This is defined in `cmake/FindXSD.cmake`. While configuring
CMake, you can mark an .xsd file. Before compilation the XSD file will be
processed and the generated files will be stored inside the build directory.

Copy the `FindXSD.cmake` file to your own project to get started.

The find script is modified from http://wiki.codesynthesis.com/Using_XSD_with_CMake, 
originally made by Brad Howes.

## Build and Run

With as a regular cmake project:

```shell
mkdir build && cd build
cmake ..
cmake --build .
```

Now run the example with:

```shell
build/xsd_example xsd/library.xml
```

It seems the .xml file must be in the same directory as the appropriate .xsd file.
