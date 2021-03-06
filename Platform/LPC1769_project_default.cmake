add_definitions(
  -D__NEWLIB__
  -D__CODE_RED
  -D__USE_CMSIS=CMSISv2p00_LPC17xx

  -Wall
  -Wshadow
  -Wcast-qual
  -Wwrite-strings
  -Winline

  -fmessage-length=80
  -ffunction-sections
  -fdata-sections

  -std=gnu99

  -mcpu=cortex-m3
  -mthumb
)

if(DEFINED CMAKE_RELEASE)
  add_definitions(-O2 -Os)
else()
  add_definitions(-O0 -g3 -DDEBUG)
endif()

set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/../Platform/LPC1769.ld")

if(DEFINED SEMIHOSTING_ENABLED)
  set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/../Platform/LPC1769_semihosting.ld")
endif()

# May break if split for 80 character line
set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -Xlinker --gc-sections -mcpu=cortex-m3 -mthumb -T ${LINKER_SCRIPT}")

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
set(OUTPUT_NAME ${CMAKE_PROJECT_NAME}.axf)
set(FULL_OUTPUT_NAME ${EXECUTABLE_OUTPUT_PATH}/${CMAKE_PROJECT_NAME}.axf)

add_executable(${OUTPUT_NAME} ${SOURCES})
set_target_properties(${OUTPUT_NAME} PROPERTIES LINKER_LANGUAGE C)
target_link_libraries(${OUTPUT_NAME} CMSISv2p00_LPC17xx )

# Separate debug symbols into their own file
add_custom_command(
  TARGET ${OUTPUT_NAME}
  POST_BUILD
  COMMAND ${LPCXPRESSO_OBJCOPY} --only-keep-debug ${FULL_OUTPUT_NAME}
                                ${FULL_OUTPUT_NAME}.debug
  COMMAND ${LPCXPRESSO_STRIP} -g ${FULL_OUTPUT_NAME}
)
