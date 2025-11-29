# Windows toolchain file for modern CMake with vcpkg
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x64)

# Set vcpkg toolchain if available
if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT $ENV{VCPKG_ROOT})
elseif(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../vcpkg/vcpkg.cmake")
    set(VCPKG_ROOT "${CMAKE_CURRENT_LIST_DIR}/../vcpkg")
endif()

if(EXISTS "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
else()
    message(WARNING "vcpkg toolchain not found at ${VCPKG_ROOT}")
endif()

# Compiler settings for MSVC
if(MSVC)
    # Use C++17 standard
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    
    # Disable warnings that are too verbose
    add_compile_options(/wd4251 /wd4275 /wd4996)
    
    # Enable Multi-processor compilation
    add_compile_options(/MP)
    
    # Set Windows target version
    add_compile_definitions(_WIN32_WINNT=0x0601) # Windows 7+
endif()

# Find programs
find_program(CMAKE_RC_COMPILER NAMES rc.exe HINTS "${CMAKE_VS_WINDOWS_TOOLS_DIR}/bin/Hostx64/x64")

# Bypass broken vcpkg zlib wrapper by defining the variables it looks for
# This prevents the "Broken installation of vcpkg port zlib" error
set(ZLIB_INCLUDE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
set(ZLIB_LIBRARY_RELEASE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/zlib.lib")
set(ZLIB_LIBRARY_DEBUG "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/zlibd.lib")
