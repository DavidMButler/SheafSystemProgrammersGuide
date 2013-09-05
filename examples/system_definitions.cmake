
#
# Copyright (c) 2013 Limit Point Systems, Inc. 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# This file is the system level counterpart to the component_definitions file
# found in the top level of any component. Functions and variables
# that need to have system scope should be declared and/or defined here.
#

#
# Establish the list of components in this system
#
set(COMPONENTS sheaf fiber_bundle field CACHE STRING "List of components in this system" FORCE)

#
# Establish the version number for this build.
# This is only relevant for releases. 0.0.0 is chosen here
# simply as an identifier for non-release builds.
#
set(LIB_VERSION 0.0.0.0 CACHE STRING "Library version number for release purposes")
mark_as_advanced(LIB_VERSION)

#
# Set the default value for install location
#
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND LIB_VERSION MATCHES "0.0.0.0" )
    if(LINUX64GNU OR LINUX64INTEL)
      set(CMAKE_INSTALL_PREFIX
        "$ENV{HOME}/${PROJECT_NAME}" CACHE PATH "${PROJECT_NAME} install prefix" FORCE
        )
    else()
      set(CMAKE_INSTALL_PREFIX
        "$ENV{USERPROFILE}/${PROJECT_NAME}" CACHE PATH "${PROJECT_NAME} install prefix" FORCE
        )
    endif()
endif()

#
# Platform definitions
#
# OS is 64 bit Windows, compiler is cl 
if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows" AND MSVC AND CMAKE_SIZEOF_VOID_P MATCHES "8")
    set(WIN64MSVC ON CACHE BOOL "MS compiler in use.")
# OS is 64 bit Windows, compiler is icl
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows" AND CMAKE_CXX_COMPILER_ID MATCHES "Intel" AND CMAKE_SIZEOF_VOID_P MATCHES "8")
    set(WIN64INTEL ON CACHE BOOL "Intel compiler in use.")
# OS is 64 bit linux, compiler is g++
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux" AND CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SIZEOF_VOID_P MATCHES "8")
    set(LINUX64GNU ON CACHE BOOL "GNU compiler in use.")
# OS is 64 bit linux, compiler is icpc
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux" AND CMAKE_CXX_COMPILER_ID MATCHES "Intel" AND CMAKE_SIZEOF_VOID_P MATCHES "8")
    set(LINUX64INTEL ON CACHE BOOL "Intel compiler in use.")
    message(STATUS "Using Intel compiler")    
else()
    message(FATAL_ERROR "A 64 bit Windows or Linux environment was not detected; exiting")
endif()

#
# Set the cmake module path.
#
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake_modules CACHE STRING "Location of Cmake modules")

#
# Define the exports files
#
#set(EXPORTS_FILE ${PROJECT_NAME}-exports.cmake CACHE STRING "System exports file name")
#set(INSTALL_CONFIG_FILE ${PROJECT_NAME}-install.cmake CACHE STRING "Install config file name")

#
# Delete the exports file at the start of each cmake run
#
#execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/${EXPORTS_FILE})
#execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/${INSTALL_CONFIG_FILE})

#
# Set the default build type.
#
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug-contracts" CACHE STRING "Choose the type of build, options are: ${CMAKE_CONFIGURATION_TYPES}." FORCE)
endif(NOT CMAKE_BUILD_TYPE)

#
# Tell Cmake which configurations it should see and "Debug"
#
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS "Debug-contracts" "Debug-no-contracts" ) 

#
# Debug lib has "_d" appended to filename for Win32, "_debug" for Linux.
#
if(WIN32)
    set(CMAKE_DEBUG-CONTRACTS_POSTFIX "_d" CACHE STRING "Debug libs suffix")
    set(CMAKE_DEBUG-NO-CONTRACTS_POSTFIX "_d" CACHE STRING "Debug libs suffix")
else()
    set(CMAKE_DEBUG-CONTRACTS_POSTFIX "_debug" CACHE STRING "Debug libs suffix")
    set(CMAKE_DEBUG-NO-CONTRACTS_POSTFIX "_debug" CACHE STRING "Debug libs suffix")
endif()


set(ALL_BIN_TARGETS CACHE STRING "Aggregate list of component bin targets")
    
#
# Toggle intel compiler warnings.
#
set(INTELWARN CACHE BOOL "Toggle Intel compiler warnings")

#
# Define the exports files
#
#set(EXPORTS_FILE ${PROJECT_NAME}-exports.cmake CACHE STRING "System exports file name")
#set(INSTALL_CONFIG_FILE ${PROJECT_NAME}-install.cmake CACHE STRING "Install config file name")

#
# True if we want kd_lattice to link against VTK
#
#set(USE_VTK ON CACHE BOOL "Set to link geometry against VTK libs.")

#
# Toggle multi-process compilation in win32.
#
set(ENABLE_WIN32_MP ON CACHE BOOL "Toggle win32 compiler MP directive. Works for MS and Intel. Default is ON.")

#   
#  Type of system documentation to build: Dev or User
#
if(NOT LPS_DOC_STATE)
    set(LPS_DOC_STATE User CACHE STRING "Type of documentation to build: [Dev|User]")
endif()

#
# Default linux installation location is /usr/local
# Set a default where the user has write permission ; in this
# case, the top of the components source tree.
# "lib", "include", and "bin" will be appended to this location.
# See "add_install_target" in cmake_modules/LPSCommon.cmake for source.
#
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR} CACHE STRING "System install location")

#
# Targets with global scope are declared and optionally defined in 
# target_declarations.cmake; otherwise defined at first use.
#
include(${CMAKE_MODULE_PATH}/target_declarations.cmake)

#
# Prerequisite discovery
#
include(${CMAKE_MODULE_PATH}/find_prerequisites.cmake)

#
# C++11 features
#
message(STATUS " ")
message(STATUS "Checking for C++11 Compliance - ")
message(STATUS " ")

include(${CMAKE_MODULE_PATH}/CheckCXX11Features.cmake)

# If SHEAFSYSTEM_HOME contains white space, escape it.
file(TO_NATIVE_PATH "${SHEAFSYSTEM_HOME}" SHEAFSYSTEM_HOME)

# When we are dealing with an install, the hdf and tetgen include files are
# in the release include dir. If it's a build directory, then we need to know where
# the prereqs are. The includes below are defind in SheafSystem-exports.cmake
# If there's a RELEASE file in SHEAFSYSTEM_HOME, then we are dealing with a release.
if(NOT EXISTS ${SHEAFSYSTEM_HOME}/RELEASE)
    include_directories(${HDF_INCLUDE_DIR})
    include_directories(${TETGEN_INCLUDE_DIR})
endif()

#
# Clear cached variables at the start of each cmake run.
#
function(clear_component_variables comp)

    string(TOUPPER ${comp} COMP)

    # clear the srcs vars so consecutive cmake runs don't
    # list the same sources n times.
    unset(${COMP}_SRCS CACHE)
    
    # clear the unit tests var so consecutive cmake runs don't
    # list the same sources n times.
    unset(${COMP}_UNIT_TEST_SRCS CACHE)

    # clear the example binaries var so consecutive cmake runs don't
    # list the same sources n times.
    unset(${COMP}_EXAMPLE_SRCS CACHE)
    
    # clear the unit tests var so consecutive cmake runs don't
    # list the same unit tests n times.
    unset(${COMP}_UNIT_TESTS CACHE)
    
    # clear the unit tests var so consecutive cmake runs don't
    # list the same includes n times.
    unset(${COMP}_INCS CACHE)
    
    # clear the ipath var so consecutive cmake runs don't
    # list the same include paths n times.
    unset(${COMP}_IPATH CACHE)

        
endfunction(clear_component_variables)

# 
#  Make emacs tags
#
function(add_tags_target)

    if(LINUX64GNU OR LINUX64INTEL)
        add_custom_target(tags
            COMMAND find ${CMAKE_CURRENT_SOURCE_DIR} -name build -prune -o -name "*.cc" -print -o -name "*.h" -print -o -name "*.t.cc" -print | etags --c++ --members -
        )
    endif()

endfunction(add_tags_target) 
