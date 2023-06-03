# -----------------------------------------------------------------------------
# Title  : Cmake makefile for stm32 compilation with cubeMX
# Author : Simone Ruffini <simone.ruffini.work@gmail.com>
# Date   : Wed May 17 10:37:43 PM CEST 2023
# Notes  :
#
# License:
#  "THE BEER-WARE LICENSE" (Revision 69):
#  Squadra Corse firmware team wrote this project. As long as you retain this
#  notice you can do whatever you want with this stuff. If we meet some day,
#  and you think this stuff is worth it, you can buy us a beer in return.
# Copyright squadracorsepolito.it
# -----------------------------------------------------------------------------

.PHONY: all build cmake flash clean

BUILD_DIR := build

PROJECT_NAME = tlb_battery

# Build type: Debug|Release
# By default = Debug
BUILD_TYPE ?= Debug

all: build

# Makefile generated by CMAKE
${BUILD_DIR}/Makefile:
    # -B: specify build directory where to store files/generate makefile
    # -D: cmake options when CMakeList.txt is evaluated
    #   - CMAKE_BUILD_DIR: where to put artifacts of the evaluation/buid
    #   - CMAKE_EXPORT_COMPILE_COMMANDS: export the compilation units compile
    #     commands in a file called "compile_commands.json" in the build directory
	cmake \
		-B${BUILD_DIR} \
		-DPROJECT_NAME=${PROJECT_NAME} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=true 

cmake: ${BUILD_DIR}/Makefile
	# Always touch the CMakeList so that it gets re-evaluated on the next build
	# Use this hack for GLOBS
	touch ./CMakeLists.txt

build: cmake
    # -C: change to BUILD_DIR directory
    # --no-print-directory: don't show the above directory change in the log
	$(MAKE) -C ${BUILD_DIR} --no-print-directory


#######################################
# flash
#######################################
# Generating the .elf/.hex/.bin depends on running CMAKE and generating the makefile

$(BUILD_DIR)/$(PROJECT_NAME).elf: build
$(BUILD_DIR)/$(PROJECT_NAME).hex: build
$(BUILD_DIR)/$(PROJECT_NAME).bin: build

# Flashing can happen only if the compile output is built
flash: $(BUILD_DIR)/$(PROJECT_NAME).elf
	"/run/current-system/sw/bin/openocd" -f ./openocd.cfg -c "program $(BUILD_DIR)/$(PROJECT_NAME).elf verify reset exit"

#######################################
# debug
#######################################
#debug: $(BUILD_DIR)/$(TARGET).elf
#	"/run/current-system/sw/bin/openocd" -f ./openocd.cfg -c "init; reset halt; stm32f4x mass_erase 0; exit"

#######################################
# clean
#######################################
clean:
	rm -rf -fR $(BUILD_DIR)
