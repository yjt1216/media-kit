# This file is a part of media_kit (https://github.com/media-kit/media-kit).
#
# Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
# All rights reserved.
# Use of this source code is governed by MIT license that can be found in the LICENSE file.

cmake_minimum_required(VERSION 3.14)
cmake_policy(SET CMP0175 NEW)

# This option is read by the other packages which are part of package:media_kit.
option(MEDIA_KIT_LIBS_AVAILABLE "package:media_kit libraries are available." ON)

set(PROJECT_NAME "media_kit_libs_windows_video")
project(${PROJECT_NAME} LANGUAGES CXX)

# Deal with MSVC incompatiblity
add_compile_definitions(_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR)

# Offline native libraries are vendored under windows/vendor/ (see README + scripts/).
set(MEDIA_KIT_WINDOWS_VIDEO_VENDOR_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/vendor")

# ------------------------------------------------------------------------------
function(check_directory_exists_and_not_empty dir result_var)
  if(EXISTS "${dir}")
    file(GLOB dir_contents "${dir}/*")

    if(dir_contents)
      set(${result_var} TRUE PARENT_SCOPE)
    else()
      set(${result_var} FALSE PARENT_SCOPE)
      message(STATUS "Directory ${dir} exists but is empty!")
    endif()
  else()
    set(${result_var} FALSE PARENT_SCOPE)
    message(STATUS "Directory ${dir} does not exist!")
  endif()
endfunction()

function(ensure_archive_from_vendor vendor_archive expected_md5 dest_archive)
  if(EXISTS "${dest_archive}")
    file(MD5 "${dest_archive}" actual_md5)

    if(expected_md5 STREQUAL actual_md5)
      return()
    endif()

    file(REMOVE "${dest_archive}")
    message(STATUS "MD5 mismatch. Removed ${dest_archive}.")
  endif()

  if(NOT EXISTS "${vendor_archive}")
    message(FATAL_ERROR
      "Offline vendor archive not found: ${vendor_archive}\n"
      "Run: libs/windows/media_kit_libs_windows_video/scripts/download_vendor.ps1"
    )
  endif()

  file(MD5 "${vendor_archive}" vendor_md5)

  if(NOT expected_md5 STREQUAL vendor_md5)
    message(FATAL_ERROR
      "Vendor archive integrity check failed: ${vendor_archive}\n"
      "Expected MD5 ${expected_md5}, got ${vendor_md5}."
    )
  endif()

  message(STATUS "Using offline vendor archive: ${vendor_archive}")
  file(COPY "${vendor_archive}" DESTINATION "${CMAKE_BINARY_DIR}")
endfunction()

function(copy_vendor_tree_if_present vendor_dir dest_dir)
  check_directory_exists_and_not_empty("${vendor_dir}" vendor_tree_valid)

  if(NOT vendor_tree_valid)
    return()
  endif()

  check_directory_exists_and_not_empty("${dest_dir}" dest_valid)

  if(dest_valid)
    return()
  endif()

  message(STATUS "Copying pre-extracted vendor tree ${vendor_dir} -> ${dest_dir}")
  file(MAKE_DIRECTORY "${dest_dir}")
  file(COPY "${vendor_dir}/" DESTINATION "${dest_dir}")
endfunction()

# Detect architecture and set appropriate libmpv archive
if(${FLUTTER_TARGET_PLATFORM} STREQUAL "windows-x64")
  set(LIBMPV_ARCH "x86_64")
  set(LIBMPV "mpv-dev-x86_64-20241021-git-0f78584.7z")
  set(LIBMPV_MD5 "6ecf18e85b093c3f7edb16f3ee6603f3")
else()
  set(LIBMPV_ARCH "aarch64")
  set(LIBMPV "mpv-dev-aarch64-20241021-git-0f78584.7z")
  set(LIBMPV_MD5 "5b507a35db13eee6cb7eb21e8be7c83d")
endif()

set(LIBMPV_VENDOR_DIR "${MEDIA_KIT_WINDOWS_VIDEO_VENDOR_ROOT}/${LIBMPV_ARCH}")
set(LIBMPV_VENDOR_ARCHIVE "${LIBMPV_VENDOR_DIR}/${LIBMPV}")
set(LIBMPV_VENDOR_SRC "${LIBMPV_VENDOR_DIR}/libmpv")

set(LIBMPV_ARCHIVE "${CMAKE_BINARY_DIR}/${LIBMPV}")
set(LIBMPV_SRC "${CMAKE_BINARY_DIR}/libmpv")

copy_vendor_tree_if_present("${LIBMPV_VENDOR_SRC}" "${LIBMPV_SRC}")

check_directory_exists_and_not_empty(${LIBMPV_SRC} LIBMPV_SRC_VALID)

if(NOT LIBMPV_SRC_VALID)
  ensure_archive_from_vendor(
    "${LIBMPV_VENDOR_ARCHIVE}"
    "${LIBMPV_MD5}"
    "${LIBMPV_ARCHIVE}"
  )
endif()

check_directory_exists_and_not_empty(${LIBMPV_SRC} LIBMPV_SRC_VALID)

find_program(SEVENZ_EXECUTABLE NAMES 7z 7za)

if(NOT LIBMPV_SRC_VALID)
  message(STATUS "Extracting ${LIBMPV}...")
  make_directory("${LIBMPV_SRC}")
  add_custom_target("${PROJECT_NAME}_LIBMPV_EXTRACT" ALL)

  if(SEVENZ_EXECUTABLE)
    message(STATUS "Using 7zip for extraction: ${SEVENZ_EXECUTABLE}")
    add_custom_command(
      TARGET "${PROJECT_NAME}_LIBMPV_EXTRACT"
      POST_BUILD
      COMMAND "${SEVENZ_EXECUTABLE}" x -y "\"${LIBMPV_ARCHIVE}\""
      COMMAND xcopy "\"${LIBMPV_SRC}/include/mpv\"" "\"${LIBMPV_SRC}/mpv\"" /E /H /C /I
      COMMAND rmdir "\"${LIBMPV_SRC}/include\"" /S /Q
      COMMAND ren "\"${LIBMPV_SRC}/mpv\"" "\"include\""
      WORKING_DIRECTORY "${LIBMPV_SRC}"
    )
  else()
    message(STATUS "7zip not found, falling back to CMake tar")
    add_custom_command(
      TARGET "${PROJECT_NAME}_LIBMPV_EXTRACT"
      POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E tar xzf "\"${LIBMPV_ARCHIVE}\""
      COMMAND xcopy "\"${LIBMPV_SRC}/include/mpv\"" "\"${LIBMPV_SRC}/mpv\"" /E /H /C /I
      COMMAND rmdir "\"${LIBMPV_SRC}/include\"" /S /Q
      COMMAND ren "\"${LIBMPV_SRC}/mpv\"" "\"include\""
      WORKING_DIRECTORY "${LIBMPV_SRC}"
    )
  endif()
endif()

# ------------------------------------------------------------------------------

set(ANGLE "ANGLE.7z")
set(ANGLE_MD5 "e866f13e8d552348058afaafe869b1ed")

set(ANGLE_VENDOR_DIR "${MEDIA_KIT_WINDOWS_VIDEO_VENDOR_ROOT}/common")
set(ANGLE_VENDOR_ARCHIVE "${ANGLE_VENDOR_DIR}/${ANGLE}")
set(ANGLE_VENDOR_SRC "${ANGLE_VENDOR_DIR}/ANGLE")

set(ANGLE_ARCHIVE "${CMAKE_BINARY_DIR}/${ANGLE}")
set(ANGLE_SRC "${CMAKE_BINARY_DIR}/ANGLE")

copy_vendor_tree_if_present("${ANGLE_VENDOR_SRC}" "${ANGLE_SRC}")

check_directory_exists_and_not_empty(${ANGLE_SRC} ANGLE_SRC_VALID)

if(NOT ANGLE_SRC_VALID)
  ensure_archive_from_vendor(
    "${ANGLE_VENDOR_ARCHIVE}"
    "${ANGLE_MD5}"
    "${ANGLE_ARCHIVE}"
  )
endif()

check_directory_exists_and_not_empty(${ANGLE_SRC} ANGLE_SRC_VALID)

if(NOT ANGLE_SRC_VALID)
  message(STATUS "Extracting ${ANGLE}...")
  make_directory("${ANGLE_SRC}")
  add_custom_target("${PROJECT_NAME}_ANGLE_EXTRACT" ALL)

  if(SEVENZ_EXECUTABLE)
    message(STATUS "Using 7zip for extraction: ${SEVENZ_EXECUTABLE}")
    add_custom_command(
      TARGET "${PROJECT_NAME}_ANGLE_EXTRACT"
      POST_BUILD
      COMMAND "${SEVENZ_EXECUTABLE}" x -y "\"${ANGLE_ARCHIVE}\""
      WORKING_DIRECTORY "${ANGLE_SRC}"
    )
  else()
    message(STATUS "7zip not found, falling back to CMake tar")
    add_custom_command(
      TARGET "${PROJECT_NAME}_ANGLE_EXTRACT"
      POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E tar xzf "\"${ANGLE_ARCHIVE}\""
      WORKING_DIRECTORY "${ANGLE_SRC}"
    )
  endif()
endif()

# ------------------------------------------------------------------------------
set(PLUGIN_NAME "media_kit_libs_windows_video_plugin")

add_library(
  ${PLUGIN_NAME} SHARED
  "include/media_kit_libs_windows_video/media_kit_libs_windows_video_plugin_c_api.h"
  "media_kit_libs_windows_video_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(
  ${PLUGIN_NAME}
  PROPERTIES
  CXX_VISIBILITY_PRESET
  hidden
)
target_compile_definitions(
  ${PLUGIN_NAME}
  PRIVATE
  FLUTTER_PLUGIN_IMPL
)

target_include_directories(
  ${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_link_libraries(
  ${PLUGIN_NAME}
  PRIVATE
  flutter
  flutter_wrapper_plugin
)

set(
  media_kit_libs_windows_video_bundled_libraries
  "${LIBMPV_SRC}/libmpv-2.dll"
  "${ANGLE_SRC}/d3dcompiler_47.dll"
  "${ANGLE_SRC}/libEGL.dll"
  "${ANGLE_SRC}/libGLESv2.dll"
  "${ANGLE_SRC}/vk_swiftshader.dll"
  "${ANGLE_SRC}/vulkan-1.dll"
  "${ANGLE_SRC}/zlib.dll"
  PARENT_SCOPE
)
