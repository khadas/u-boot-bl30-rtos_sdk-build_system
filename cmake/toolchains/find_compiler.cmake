# Copyright (c) 2021-2022 Amlogic, Inc. All rights reserved.

# SPDX-License-Identifier: MIT

# Attempting to retrieve the toolchain path parameter defined in the SoC.
if("$ENV{SPLIT_ARCH_DIR}" STREQUAL "")
    set(SOC_DIR $ENV{SDK_BASE}/soc/$ENV{ARCH}/$ENV{SOC})
else()
    set(SOC_DIR $ENV{SDK_BASE}/soc/$ENV{ARCH}/$ENV{SPLIT_ARCH_DIR}/$ENV{SOC})
endif()

message(STATUS "Compiler parameter storage path: ${SOC_DIR}")

if(EXISTS ${SOC_DIR}/compiler_options.cmake)
    include(${SOC_DIR}/compiler_options.cmake)
endif()

# Toolchain file is processed multiple times, however, it cannot access CMake cache on some runs.
# We store the search path in an environment variable so that we can always access it.
if("$ENV{TOOLCHAIN_PATH}" STREQUAL "")
    set(TOOLCHAIN_PATH $ENV{SDK_BASE}/output/toolchains)
else()
    set(TOOLCHAIN_PATH "$ENV{TOOLCHAIN_PATH}")
endif()

# Find the compiler executable and store its path in a cache entry ${compiler_path}.
# If not found, issue a fatal message and stop processing. TOOLCHAIN_PATH can be provided from
# commandline as additional search path.
function(aml_find_compiler compiler_path compiler_exe)
    # Search user provided path first.
    find_program(
        ${compiler_path} ${compiler_exe}
        PATHS ${TOOLCHAIN_PATH} PATH_SUFFIXES bin
        NO_DEFAULT_PATH
    )
    # If not then search system paths.
    if("${${compiler_path}}" STREQUAL "${compiler_path}-NOTFOUND")
        find_program(${compiler_path} ${compiler_exe})
    endif()
    if("${${compiler_path}}" STREQUAL "${compiler_path}-NOTFOUND")
        set(TOOLCHAIN_PATH "" CACHE PATH "Path to search for compiler.")
        message(FATAL_ERROR "${compiler_exe} not found, you can specify search path with\
            \"TOOLCHAIN_PATH\".")
    endif()
endfunction()