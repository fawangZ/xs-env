ABS_WORK_DIR = $(shell pwd)

NUM_CORES ?= 1
VCS_SIM_DIR ?= ../sim

SIM_CSRC_DIR = $(abspath ./difftest/src/test/csrc/common)
SIM_CXXFILES = $(shell find $(SIM_CSRC_DIR) -name "*.cpp")

GEN_CSRC_DIR = $(abspath ./difftest/src/test/csrc/artifacts)
GEN_CXXFILES = $(shell find $(GEN_CSRC_DIR) -name "*.cpp")

PLUGIN_CSRC_DIR =  $(abspath ./difftest/src/test/csrc/plugin/spikedasm)
PLUGIN_CXXFILES = $(shell find $(PLUGIN_CSRC_DIR) -name "*.cpp")

DIFFTEST_CSRC_DIR = $(abspath ./difftest/src/test/csrc/difftest)
DIFFTEST_CXXFILES = $(shell find $(DIFFTEST_CSRC_DIR) -name "*.cpp")

CFG_DIR      = $(abspath ./difftest/config)
CFG_HEADERS = $(shell find $(CFG_DIR) -name "*.h")

PLUGIN_CHEAD_DIR = $(abspath ./difftest/src/test/csrc/plugin/include)

VCS_CSRC_DIR = $(abspath ./difftest/src/test/csrc/vcs)
VCS_CSRC_FILES = $(shell find $(VCS_CSRC_DIR) -name "*.c" -or -name "*.cpp")

SIM_VSRC_COMMON_DIR = $(abspath ./difftest/src/test/vsrc/common)
SIM_VSRC_COMMON_FILES = $(shell find $(SIM_VSRC_COMMON_DIR) -name "*.v" -or -name "*.sv")

VCS_TOP_DIR = $(abspath ./difftest/src/test/vsrc/vcs)
VCS_TOP_FILES = $(shell find $(VCS_TOP_DIR) -name "*.v" -or -name "*.sv")

SIMTOP_DIR = $(abspath ./SimTop)
SIMTOP_FILES = $(shell find $(SIMTOP_DIR) -name "*.v" -or -name "*.sv")

ALL_SRC_FILES = $(SIM_CXXFILES) $(GEN_CXXFILES) $(PLUGIN_CXXFILES)
ALL_SRC_FILES += $(DIFFTEST_CXXFILES) $(VCS_CSRC_FILES) $(SIM_VSRC_COMMON_FILES)
ALL_SRC_FILES += $(VCS_TOP_FILES) $(CFG_HEADERS) $(SIMTOP_FILES)

include vcs.mk