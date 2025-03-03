# This file is intended to be included in end-user CMakeLists.txt
# This file is NOT designed (on purpose) to be used as cmake
# subdir via add_subdirectory()
# The intention is to provide greater flexibility to users to
# create their own targets using the set variables.

function (tinyuf2_add TARGET)
  target_sources(${TARGET} PUBLIC
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/ghostfat.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/images.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/main.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/msc.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/screen.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/usb_descriptors.c
    )

  # tinyusb source
  set(TINYUSB_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../lib/tinyusb/src)

  target_sources(${TARGET} PUBLIC
    ${TINYUSB_DIR}/tusb.c
    ${TINYUSB_DIR}/common/tusb_fifo.c
    ${TINYUSB_DIR}/device/usbd.c
    ${TINYUSB_DIR}/device/usbd_control.c
    ${TINYUSB_DIR}/class/cdc/cdc_device.c
    ${TINYUSB_DIR}/class/dfu/dfu_rt_device.c
    ${TINYUSB_DIR}/class/hid/hid_device.c
    ${TINYUSB_DIR}/class/msc/msc_device.c
    ${TINYUSB_DIR}/class/vendor/vendor_device.c
    )

  target_include_directories(${TARGET} PUBLIC
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/favicon
    ${TINYUSB_DIR}
    )

  execute_process(COMMAND git describe --dirty --always --tags OUTPUT_VARIABLE GIT_VERSION)
  string(STRIP ${GIT_VERSION} GIT_VERSION)

  get_target_property(deps_repo ${TARGET} DEPS_SUBMODULES)
  set(deps_repo "${deps_repo} ${TINYUSB_DIR}/..")

  execute_process(COMMAND bash "-c" "git -C ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.. submodule status ${deps_repo} | cut -d\" \" -f3,4 | paste -s -d\" \" -"
    OUTPUT_VARIABLE GIT_SUBMODULE_VERSIONS)
  string(REPLACE ../../../../lib/ "" GIT_SUBMODULE_VERSIONS ${GIT_SUBMODULE_VERSIONS})
  string(STRIP ${GIT_SUBMODULE_VERSIONS} GIT_SUBMODULE_VERSIONS)

  target_compile_definitions(${TARGET} PUBLIC
    UF2_VERSION_BASE="${GIT_VERSION}"
    UF2_VERSION="${GIT_VERSION} - ${GIT_SUBMODULE_VERSIONS}"
    )
endfunction()