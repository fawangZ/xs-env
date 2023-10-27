# if fsdb is considered
# CONSIDER_FSDB ?= 0
ifeq ($(CONSIDER_FSDB),1)
EXTRA = +define+CONSIDER_FSDB
# if VERDI_HOME is not set automatically after 'module load', please set manually.
ifndef VERDI_HOME
$(error VERDI_HOME is not set. Try whereis verdi, abandon /bin/verdi and set VERID_HOME manually)
else
NOVAS_HOME = $(VERDI_HOME)
NOVAS = $(NOVAS_HOME)/share/PLI/VCS/LINUX64
EXTRA += -P $(NOVAS)/novas.tab $(NOVAS)/pli.a
endif
endif

ABS_WORK_DIR = $(shell pwd)
ENV_FILELIST = $(ABS_WORK_DIR)/env.f

ifndef DUT_FILELIST
$(error DUT_FILELIST not set)
endif

VCS_CXXFLAGS += -std=c++11 -static -Wall -I$(CFG_DIR) -I$(GEN_CSRC_DIR) -I$(VCS_CSRC_DIR)
VCS_CXXFLAGS += -I$(SIM_CSRC_DIR) -I$(PLUGIN_CSRC_DIR) -I$(DIFFTEST_CSRC_DIR)
VCS_CXXFLAGS += -I$(PLUGIN_CHEAD_DIR) -DNUM_CORES=$(NUM_CORES) -O3
VCS_LDFLAGS  += -Wl,--no-as-needed -lpthread -lSDL2 -ldl -lz -lsqlite3

ifneq ($(REF),)
ifneq ($(wildcard $(REF)),)
VCS_CXXFLAGS += -DREF_PROXY=LinkedProxy -DLINKED_REFPROXY_LIB=\\\"$(REF)\\\"
VCS_LDFLAGS  += $(REF)
else
VCS_CXXFLAGS += -DREF_PROXY=$(REF)Proxy -DSELECTED$(REF)
REF_HOME_VAR = $(shell echo $(REF)_HOME | tr a-z A-Z)
ifneq ($(origin $(REF_HOME_VAR)), undefined)
VCS_CXXFLAGS += -DREF_HOME=\\\"$(shell echo $$$(REF_HOME_VAR))\\\"
endif
endif
endif

VCS_FLAGS += -full64 +v2k -timescale=1ns/1ns -sverilog -debug_access+all +lint=TFIPC-L
VCS_FLAGS += -l comp.log -top tb_top -fgp -lca -kdb +nospecify +notimingcheck -xprop
VCS_FLAGS += +define+DIFFTEST +define+ASSERT_VERBOSE_COND_=1 +define+PRINTF_COND_=1
VCS_FLAGS += +define+STOP_COND_=1 +define+VCS
VCS_FLAGS += -CFLAGS "$(VCS_CXXFLAGS)" -LDFLAGS "$(VCS_LDFLAGS)" -j200
VCS_FLAGS += $(EXTRA)

flist:$(ALL_SRC_FILES)
	$(shell find $(SIM_CSRC_DIR) -name "*.cpp" > $(ENV_FILELIST))
	$(shell find $(PLUGIN_CSRC_DIR) -name "*.cpp" >> $(ENV_FILELIST))
	$(shell find $(DIFFTEST_CSRC_DIR) -name "*.cpp" >> $(ENV_FILELIST))
	$(shell find $(GEN_CSRC_DIR) -name "*.cpp" >> $(ENV_FILELIST))
	$(shell find $(VCS_CSRC_DIR) -name "*.cpp" -or -name "*.c" >> $(ENV_FILELIST))
	$(shell find $(SIM_VSRC_COMMON_DIR) -name "*.v" -or -name "*.sv" >> $(ENV_FILELIST))
	$(shell find $(SIMTOP_DIR) -name "*.v" -or -name "*.sv" >> $(ENV_FILELIST))
	$(shell find $(VCS_TOP_DIR) -name "*.v" -or -name "*.sv" >> $(ENV_FILELIST))
	
simv:flist
	$(shell if [ ! -e $(VCS_SIM_DIR)/comp ];then mkdir -p $(VCS_SIM_DIR)/comp; fi)
	cd $(VCS_SIM_DIR)/comp && vcs $(VCS_FLAGS) -f $(DUT_FILELIST) -f $(ENV_FILELIST)
	rm $(ENV_FILELIST)
